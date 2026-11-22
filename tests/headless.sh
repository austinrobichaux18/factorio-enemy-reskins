#!/usr/bin/env bash
# Headless load sweep: copies the mod into a scratch mod directory (leaving the real mod-list.json alone)
# and runs `factorio --create` once with stock settings, then once per skin index with every default
# overridden to that skin. Catches Lua/prototype errors; sprites are not loaded, so run check_assets.py too.
# Usage: bash tests/headless.sh [--space-age]
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FACTORIO="${FACTORIO:-D:/SteamLibrary/steamapps/common/Factorio/bin/x64/factorio.exe}"
SCRATCH="$(mktemp -d)"
command -v cygpath >/dev/null && SCRATCH="$(cygpath -m "$SCRATCH")"
trap 'rm -rf "$SCRATCH"' EXIT

MODS='{"name":"base","enabled":true},{"name":"enemy-reskins","enabled":true}'
if [ "${1:-}" = "--space-age" ]; then
    MODS="$MODS"',{"name":"space-age","enabled":true},{"name":"quality","enabled":true},{"name":"elevated-rails","enabled":true}'
fi

UNITS=$(grep -A3 'constants.unit_skins' "$ROOT/helpers/constants.lua" | grep -o '"[^"]*"' | tr -d '"')
WORMS=$(grep 'constants.worm_skins' "$ROOT/helpers/constants.lua" | grep -o '"[^"]*"' | tr -d '"')
SPAWNERS=$(grep 'constants.spawner_skins' "$ROOT/helpers/constants.lua" | grep -o '"[^"]*"' | tr -d '"')
pick() { echo "$1" | sed -n "$(( ($2 - 1) % $(echo "$1" | wc -l) + 1 ))p"; }

# Own write-data dir, so the sweep runs even while the game is open (it holds the default dir's lock).
mkdir -p "$SCRATCH/write"
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s\n' "$SCRATCH/write" > "$SCRATCH/config.ini"

failed=0
run() {  # $1 = label, $2 = Lua appended to constants.lua before its return
    local mod="$SCRATCH/mods/enemy-reskins"
    rm -rf "$SCRATCH/mods" && mkdir -p "$mod"
    (cd "$ROOT" && cp -r info.json ./*.lua helpers compatability graphics locale thumbnail.png "$mod/")
    echo "{\"mods\":[$MODS]}" > "$SCRATCH/mods/mod-list.json"
    if [ -n "$2" ]; then
        sed -i "s/^return constants/$2\nreturn constants/" "$mod/helpers/constants.lua"
    fi
    "$FACTORIO" --config "$SCRATCH/config.ini" --mod-directory "$SCRATCH/mods" --create "$SCRATCH/t.zip" > "$SCRATCH/out.txt" 2>&1
    local code=$?
    if [ $code -ne 0 ] || grep -q "Error" "$SCRATCH/out.txt"; then
        echo "FAIL $1 (exit $code)"; grep -m5 "Error" "$SCRATCH/out.txt"; failed=1
    else
        echo "ok   $1"
    fi
}

run "stock settings" ""
count=$(echo "$UNITS" | wc -l)
for i in $(seq 1 "$count"); do
    u=$(pick "$UNITS" "$i"); w=$(pick "$WORMS" "$i"); s=$(pick "$SPAWNERS" "$i")
    lua="for _, t in ipairs(constants.tiers) do constants.biter_defaults[t] = '$u'; constants.spitter_defaults[t] = '$u'; constants.worm_defaults[t] = '$w' end; constants.spawner_defaults = { biter = '$s', spitter = '$s' }"
    run "units=$u worms=$w spawners=$s" "$lua"
done
exit $failed
