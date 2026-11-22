"""Static check of helpers/constants.lua against graphics/: every skin has its pngs at the
sheet sizes the code assumes, and every default is an allowed value. Run: python tests/check_assets.py
(The headless load can't catch these: it never loads sprites.)"""
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = (ROOT / "helpers" / "constants.lua").read_text(encoding="utf-8")

# Expected png size per (folder, is_corpse). Units: 3x3 grid of 162px; corpses: 2x2 of 128px.
SIZES = {
    ("units", False): (486, 486), ("units", True): (256, 256),
    ("worms", False): (384, 384), ("worms", True): (256, 256),
    ("spawners", False): (64, 64), ("spawners", True): (64, 64),
}


def table(name):
    m = re.search(r"constants\." + name + r"\s*=\s*\{(.*?)\}", SRC, re.S)
    if not m:
        sys.exit(f"constants.{name} not found")
    body = m.group(1)
    pairs = re.findall(r"(\w+)\s*=\s*\"([^\"]+)\"", body)
    return dict(pairs) if pairs else re.findall(r"[\"']([^\"']+)[\"']", body)


def png_size(path):
    with open(path, "rb") as f:
        head = f.read(24)
    return struct.unpack(">II", head[16:24])


errors = []


def check_png(folder, file, corpse):
    path = ROOT / "graphics" / folder / file
    if not path.exists():
        errors.append(f"missing {path.relative_to(ROOT)}")
    elif png_size(path) != SIZES[(folder, corpse)]:
        errors.append(f"{path.relative_to(ROOT)} is {png_size(path)}, expected {SIZES[(folder, corpse)]}")


def check_group(folder, skins_name, default_names):
    skins = table(skins_name)
    if "default" not in skins:
        errors.append(f"constants.{skins_name} lacks 'default'")
    for skin in skins:
        if skin == "default":
            continue
        check_png(folder, skin + ".png", False)
        corpse = "titan" if folder == "units" and "titan" in skin else skin
        check_png(folder, corpse + "_corpse.png", True)
    for defaults_name in default_names:
        for key, value in table(defaults_name).items():
            if value not in skins:
                errors.append(f"constants.{defaults_name}.{key} = {value!r} is not in {skins_name}")


check_group("units", "unit_skins", ["biter_defaults", "spitter_defaults"])
check_group("worms", "worm_skins", ["worm_defaults"])
check_group("spawners", "spawner_skins", ["spawner_defaults"])

# Every shipped png should be used by some skin.
used = set()
for folder, skins_name in [("units", "unit_skins"), ("worms", "worm_skins"), ("spawners", "spawner_skins")]:
    for skin in table(skins_name):
        used.add(f"{folder}/{skin}.png")
        used.add(f"{folder}/{'titan' if 'titan' in skin else skin}_corpse.png")
for png in (ROOT / "graphics").rglob("*.png"):
    rel = png.relative_to(ROOT / "graphics").as_posix()
    if rel not in used:
        errors.append(f"unused graphics/{rel}")

if errors:
    print("\n".join(errors))
    sys.exit(1)
print("assets ok")
