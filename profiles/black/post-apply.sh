#!/usr/bin/env bash
set -Eeuo pipefail

readonly NOCTALIA_LUA="${HOME}/.config/hypr/noctalia.lua"

sed -i -E \
    -e '/^[[:space:]]*active_border[[:space:]]*=/ s/=[[:space:]]*primary([[:space:]]*,?)/= none\1/' \
    -e '/^[[:space:]]*inactive_border[[:space:]]*=/ s/=[[:space:]]*surface([[:space:]]*,?)/= on_secondary\1/' \
    "$NOCTALIA_LUA"
