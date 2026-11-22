# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Factorio mod (`enemy-reskins`, targets Factorio 2.1) that swaps vanilla biter, spitter, worm and spawner graphics for skins picked in startup settings. Pure Lua with no build step. The repo folder is the live mod folder (`%APPDATA%/Factorio/mods/enemy-reskins`), so whatever is on disk is what the game loads.

## Releasing

- Every push to `main` runs [.github/workflows/release.yml](.github/workflows/release.yml), which runs semantic-release. It bumps `info.json`, writes `changelog.txt` and **uploads the mod to the Factorio mod portal**. Never edit the version or the changelog by hand.
- The commit type sets the release level ([.releaserc](.releaserc)). `feat`/`feature` gives a minor release. `fix`, `compat`, `graphics`, `locale`, `balance`, `perf`, `control`, `other` and a few others give a patch. Breaking changes give a major. `docs`/`chore` do not release.

## Testing

- `python tests/check_assets.py` checks [helpers/constants.lua](helpers/constants.lua) against `graphics/`. It confirms every skin has its png and corpse png at the sheet sizes below, every default is an allowed value, every list has `'default'`, and no png goes unused.
- `bash tests/headless.sh [--space-age]` loads the mod headless (`factorio --create`) once with stock settings, then once per skin with every default overridden to that skin. It uses its own scratch mod dir and write-data dir, so it leaves `mod-list.json` alone and works while the game is open. Factorio 2.1 (Steam) is at `D:/SteamLibrary/steamapps/common/Factorio/bin/x64/factorio.exe` (override with `FACTORIO=`).
- The headless load never loads sprites, so a missing png only shows up in `check_assets.py` or in game. Neither script covers looks or the RampantFixed / ArmouredBiters compat.
- `tests/` and this file are `export-ignore`d, so they stay out of the release zip.

## Architecture

- Everything happens in **data-final-fixes** ([data-final-fixes.lua](data-final-fixes.lua)). It calls `set_all` on the spawner, worm and unit modules, then applies compat patches when `RampantFixed` / `ArmouredBiters` are loaded. Those mods add their own enemy prototypes, and [compatability/](compatability/) reskins them with the same `update_*` functions.
- The files in [helpers/](helpers/) are modules (`local M = {} ... return M`), never globals, because the data stage shares one Lua state with every other mod. `update_unit` / `update_worm` / `update_spawner` replace a prototype's animations and its corpse's, and do nothing (return false) for the `'default'` skin. The `tint_*` functions in [helpers/common.lua](helpers/common.lua) recolour each size tier and are no-ops when `enable-tint-setting` is off. Scale is a per-tier base value multiplied by the `<kind>-scale-setting` startup setting.
- Skin choices come from [helpers/constants.lua](helpers/constants.lua). It holds the skin name lists and per-tier defaults, and [settings.lua](settings.lua) builds the `<tier>-<kind>-skin-setting` settings from them. A skin name is its png name: `graphics/units/<skin>.png` plus `<skin>_corpse.png`, except that every `*titan*` skin shares `titan_corpse.png`. Worms and spawners follow the same scheme under `graphics/worms` / `graphics/spawners`. `'default'` keeps vanilla graphics and must stay in every list.
- **Adding a skin:** drop the png(s) in the right `graphics/` folder, add the name to the list in `constants.lua`, and run both tests. Dropdowns show the raw skin name, so there are no per-skin locale strings.
- Sprite sheet layout is fixed in code:
  - Units: 162×162 cells, 8 directions, `line_length` 3. The walk animation is 1 frame per direction, and the attack animation reuses the sheet as an 8-frame spin.
  - Unit and worm corpses: 128×128, 4 directions, `line_length` 2.
  - Worms: 128×128, 8 directions, `line_length` 3, used for every worm animation state. `energy_glow_animation` is cleared.
  - Spawners: 64×64, single frame.
  - New art must match these layouts. The author's [sprite-sheet-reorganizer](https://github.com/austinrobichaux18/sprite-sheet-reorganizer) arranges sprites into this order.
- Vanilla `alternative_attacking_frame_sequence` and corpse `direction_shuffle` must stay nil after a reskin. They index frames the new sheets don't have, which crashes the game.
- [control.lua](control.lua) only prints a one-time welcome message per player, tracked in `storage` and gated by the runtime-global `startup-message-setting`. Handlers are registered unconditionally. Registering or unregistering them mid-game breaks multiplayer joins.
