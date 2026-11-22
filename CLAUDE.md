# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Factorio mod (`enemy-reskins`, targets Factorio 2.1) that swaps vanilla biter, spitter, worm and spawner graphics for skins picked in startup settings. Pure Lua with no build step. The repo folder is the live mod folder (`%APPDATA%/Factorio/mods/enemy-reskins`), so whatever is on disk is what the game loads.

## Releasing

- Every push to `main` runs [.github/workflows/release.yml](.github/workflows/release.yml), which runs semantic-release. It bumps `info.json`, writes `changelog.txt` and **uploads the mod to the Factorio mod portal**. Never edit the version or the changelog by hand.
- The commit type sets the release level ([.releaserc](.releaserc)). `feat`/`feature` gives a minor release. `fix`, `compat`, `graphics`, `locale`, `balance`, `perf`, `control`, `other` and a few others give a patch. Breaking changes give a major. `docs`/`chore` do not release.

## Testing (headless load)

Factorio 2.1 (Steam) is at `D:/SteamLibrary/steamapps/common/Factorio/bin/x64/factorio.exe`. Test in a scratch mod directory so the user's `mod-list.json` stays untouched:

1. Copy `info.json *.lua helpers compatability graphics locale thumbnail.png` into `<scratch>/mods/enemy-reskins/`.
2. Write `<scratch>/mods/mod-list.json` enabling `base` and `enemy-reskins`. To include Space Age, also enable `space-age`, `quality` and `elevated-rails`.
3. Run `factorio.exe --mod-directory <scratch>/mods --create <scratch>/t.zip`. Exit code 0 with no `Error` lines means the prototypes loaded and the control script ran.

This only exercises the default settings. Non-default skins need `mod-settings.dat` or an in-game check.

## Architecture

- Everything happens in **data-final-fixes** ([data-final-fixes.lua](data-final-fixes.lua)). It calls `set_spawners`, `set_all_worms`, `set_biters` and `set_spitters`, then applies compat patches when `RampantFixed` / `ArmouredBiters` are loaded. Those mods add their own enemy prototypes, and [compatability/](compatability/) reskins them with the same helpers.
- The helpers in [helpers/](helpers/) are globals, not modules. `update_unit` / `update_spawner` / worm updaters replace the prototype's animations and its corpse's animations. `tint*` in [helpers/common.lua](helpers/common.lua) recolours each size tier and is a no-op when `enable-tint-setting` is off. Scale is a per-tier base value multiplied by the `<type>-scale-setting` startup setting.
- Skin choices come from [helpers/constants.lua](helpers/constants.lua). It holds the skin name lists and the defaults, and [settings.lua](settings.lua) uses them as `allowed_values`. A skin name is its png name: `graphics/units/<skin>.png` plus `<skin>_corpse.png`, except that every `*titan*` skin shares `titan_corpse.png`. Worms and spawners follow the same scheme under `graphics/worms` / `graphics/spawners`. `'default'` keeps vanilla graphics.
- **Adding a skin:** drop the png(s) in the right `graphics/` folder, add the name to the list in `constants.lua`, and add its locale string in [locale/en/settings.cfg](locale/en/settings.cfg).
- Sprite sheet layout is fixed in code:
  - Units: 162×162 cells, 8 directions, `line_length` 3. The walk animation is 1 frame per direction, and the attack animation reuses the sheet as an 8-frame spin.
  - Unit corpses: 128×128, 4 directions, `line_length` 2.
  - Spawners: 64×64, single frame.
  - New art must match these layouts. The author's [sprite-sheet-reorganizer](https://github.com/austinrobichaux18/sprite-sheet-reorganizer) arranges sprites into this order.
- Vanilla `alternative_attacking_frame_sequence` and corpse `direction_shuffle` must stay nil after a reskin. They index frames the new sheets don't have, which crashes the game.
- [control.lua](control.lua) only prints a one-time welcome message, gated by the runtime-global `startup-message-setting`.
