-- OmarKEYS Hyprland activation.
-- Loaded from ~/.config/hypr/bindings.lua:
--   dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/romills.omarkeys/hyprland.lua")

local PLUGIN_ID = "romills.omarkeys"
local NAMESPACE = "romills-omarkeys"
local DOUBLE_TAP_MS = 400
local CONFIG_PATH = (os.getenv("HOME") or "") .. "/.config/omarchy/omarkeys.json"

local function clamp(n, lo, hi)
  if n < lo then
    return lo
  end
  if n > hi then
    return hi
  end
  return n
end

local function read_config()
  local cfg = { doubleTap = true, holdSeconds = 5 }
  local f = io.open(CONFIG_PATH, "r")
  if not f then
    return cfg
  end
  local raw = f:read("*a") or ""
  f:close()
  if raw:match('"doubleTap"%s*:%s*false') then
    cfg.doubleTap = false
  end
  local hold = tonumber(raw:match('"holdSeconds"%s*:%s*(%d+)'))
  if hold then
    cfg.holdSeconds = clamp(hold, 1, 10)
  end
  return cfg
end

-- Linux KEY_LEFTMETA/RIGHTMETA and XKB Super_L/Super_R.
local SUPER = { [125] = true, [126] = true, [133] = true, [134] = true }

local st = {
  super_down = false,
  chorded = false,
  overlay_open = false,
  close_tap = false,
  tap_armed = false,
  hold_timer = nil,
  tap_timer = nil,
}

local function stop_timer(name)
  local timer = st[name]
  if not timer then
    return
  end
  pcall(function()
    timer:set_enabled(false)
  end)
  st[name] = nil
end

local function named_super_down()
  local down = false
  pcall(function()
    down = hl.is_key_down("Super_L") or hl.is_key_down("Super_R")
  end)
  return down
end

local function grab_keys()
  hl.dispatch(hl.dsp.exec_cmd("omarchy-shell shell call " .. PLUGIN_ID .. " grab 1"))
end

local function hide_overlay()
  st.overlay_open = false
  st.close_tap = false
  st.tap_armed = false
  stop_timer("hold_timer")
  stop_timer("tap_timer")
  hl.dispatch(hl.dsp.exec_cmd("omarchy-shell shell hide " .. PLUGIN_ID))
end

local function show_overlay()
  st.overlay_open = true
  st.close_tap = false
  st.tap_armed = false
  stop_timer("tap_timer")
  hl.dispatch(hl.dsp.exec_cmd("omarchy-shell shell summon " .. PLUGIN_ID .. " '{}'"))
end

local function on_key(keycode, _, state)
  if state == 2 then
    return
  end

  local code = tonumber(keycode) or keycode
  local is_super = SUPER[code] == true
  if not is_super then
    local named = named_super_down()
    if state == 1 and named and not st.super_down then
      is_super = true
    elseif state == 0 and st.super_down and not named then
      is_super = true
    end
  end

  if state == 1 then
    if is_super then
      if st.super_down then
        return
      end
      st.super_down = true
      st.chorded = false
      st.close_tap = st.overlay_open
      stop_timer("hold_timer")
      if not st.overlay_open then
        local hold_ms = math.floor((read_config().holdSeconds or 5) * 1000)
        if hold_ms > 0 then
          st.hold_timer = hl.timer(function()
            st.hold_timer = nil
            if st.chorded or st.overlay_open or not st.super_down then
              return
            end
            show_overlay()
          end, { timeout = hold_ms, type = "oneshot" })
        end
      end
    elseif st.super_down then
      st.chorded = true
      st.close_tap = false
      st.tap_armed = false
      stop_timer("hold_timer")
      stop_timer("tap_timer")
    end
  elseif state == 0 and is_super then
    if not st.super_down then
      return
    end
    st.super_down = false
    stop_timer("hold_timer")
    if st.chorded then
      -- Super+K (and other Super chords). If OmarKEYS just opened, Super
      -- is now up — take keyboard focus so typing/filter works.
      if st.overlay_open then
        st.close_tap = false
        grab_keys()
      end
      return
    elseif st.overlay_open and st.close_tap then
      hide_overlay()
    elseif st.overlay_open then
      st.close_tap = false
      grab_keys()
    elseif read_config().doubleTap and st.tap_armed then
      st.tap_armed = false
      stop_timer("tap_timer")
      show_overlay()
      grab_keys()
    elseif read_config().doubleTap then
      st.tap_armed = true
      stop_timer("tap_timer")
      st.tap_timer = hl.timer(function()
        st.tap_armed = false
        st.tap_timer = nil
      end, { timeout = DOUBLE_TAP_MS, type = "oneshot" })
    end
  end
end

hl.unbind("SUPER + K")
o.bind("SUPER + K", "OmarKEYS", function()
  if st.overlay_open then
    hide_overlay()
  else
    show_overlay()
    -- Super is still held for this chord. Grab as soon as it is up so
    -- filter typing matches double-tap / hold.
    hl.timer(function()
      if st.overlay_open and not st.super_down then
        grab_keys()
      end
    end, { timeout = 50, type = "oneshot" })
  end
end)

hl.on("input.keyboard.key", function(keycode, timestamp, state)
  local ok, err = pcall(on_key, keycode, timestamp, state)
  if not ok then
    print("[OmarKEYS] key handler: " .. tostring(err))
  end
end)

hl.layer_rule({
  match = { namespace = NAMESPACE },
  no_anim = true,
  animation = "none",
})
