#!/usr/bin/env python3
"""Unit tests for apply-edit helpers that do not need Hyprland."""

from __future__ import annotations

import types
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
_src = ROOT / "apply-edit"
mod = types.ModuleType("apply_edit")
mod.__file__ = str(_src)
exec(compile(_src.read_text(), str(_src) + ".py", "exec"), mod.__dict__)


class ChordRules(unittest.TestCase):
    def test_protected_summons(self) -> None:
        self.assertTrue(mod.is_protected_chord("SUPER + K"))
        self.assertTrue(mod.is_protected_chord("Super + K"))
        self.assertTrue(mod.is_protected_chord("Hold Super 5s"))
        self.assertTrue(mod.is_protected_chord("Double-tap Super"))
        self.assertFalse(mod.is_protected_chord("SUPER + RETURN"))

    def test_exec_stanza_reuses_the_command(self) -> None:
        text = mod.bind_stanza(
            "SUPER + RETURN", "Terminal",
            "SUPER + T", "Terminal",
            "exec", "ghostty",
        )
        self.assertIn('hl.unbind("SUPER + RETURN")', text)
        self.assertIn('hl.dsp.exec_cmd("ghostty")', text)
        self.assertIn('description = "Terminal"', text)
        self.assertIn('hl.bind("SUPER + T"', text)
        self.assertNotIn("o.bind", text)

    def test_lua_stanza_reuses_the_recovered_expr(self) -> None:
        expr = 'hl.dsp.workspace({ workspace = 3 })'
        text = mod.bind_stanza(
            "SUPER + 3", "Switch to workspace 3",
            "SUPER + F3", "Switch to workspace 3",
            "lua", expr,
        )
        self.assertIn(expr, text)

    def test_refuses_to_invent_an_action(self) -> None:
        with self.assertRaises(ValueError):
            mod.bind_stanza("SUPER + A", "X", "SUPER + B", "X", "exec", "")
        with self.assertRaises(ValueError):
            mod.bind_stanza("SUPER + A", "X", "SUPER + B", "X", "lua", "os.execute('rm')")
        self.assertIsNone(mod.lua_dispatcher("lua", "print(1)"))


if __name__ == "__main__":
    unittest.main()
