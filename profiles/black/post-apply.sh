#!/usr/bin/env bash
set -Eeuo pipefail

readonly NOCTALIA_LUA="${HOME}/.config/hypr/noctalia.lua"

sed -i -E \
    '/^[[:space:]]*inactive_border[[:space:]]*=/ s/=[[:space:]]*surface([[:space:]]*,?)/= tertiary\1/' \
    "$NOCTALIA_LUA"
