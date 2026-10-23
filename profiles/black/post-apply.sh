#!/usr/bin/env bash
set -Eeuo pipefail

readonly NOCTALIA_LUA="${HOME}/.config/hypr/noctalia.lua"

if [[ ! -f "$NOCTALIA_LUA" ]]; then
    printf 'Error: Noctalia config not found: %s\n' "$NOCTALIA_LUA" >&2
    exit 1
fi

sed -i \
    -e 's/local primary = "rgb(ffffff)"/local primary = "rgba(ffffff60)"/' \
    -e '/^[[:space:]]*inactive_border[[:space:]]*=/ s/=.*/= on_secondary/' \
    "$NOCTALIA_LUA"
