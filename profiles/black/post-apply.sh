#!/usr/bin/env bash
set -Eeuo pipefail

readonly NOCTALIA_LUA="${HOME}/.config/hypr/noctalia.lua"

sed -i \
    -e 's/local primary = "rgb(ffffff)"/local primary = "rgba(ffffff60)"/' \
    -e '/^[[:space:]]*inactive_border[[:space:]]*=/ s/=[[:space:]]*[^,]*/ = on_secondary/' \
    "$NOCTALIA_LUA"
