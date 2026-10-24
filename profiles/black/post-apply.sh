#!/usr/bin/env bash
#
# profiles/black/post-apply.sh: read-only checks, run by scripts/profile-switch after
# Noctalia has regenerated its templates, and again at login by scripts/profile-init.
#
# It no longer edits ~/.config/hypr/noctalia.lua: the black profile's border colour is
# applied in Lua by ~/.config/hypr/custom/colors.lua. This hook only checks that
#   1. the generated theme file is valid Lua (a broken file makes Hyprland skip it), and
#   2. the generated colours still match what the override in colors.lua expects.
#
# Exit status: 1 only if the theme file is missing or not valid Lua; a colour mismatch
# is reported as a notice because it does not break anything.
set -Eeuo pipefail

readonly THEME="${HOME}/.config/hypr/noctalia.lua"
readonly EXPECTED_PRIMARY='local primary = "rgb(ffffff)"'

if [[ ! -f "$THEME" ]]; then
    printf 'post-apply (black): theme file not found: %s\n' "$THEME" >&2
    exit 1
fi

luac_bin=''
for candidate in luac5.4 luac luac5.3; do
    if command -v "$candidate" >/dev/null 2>&1; then
        luac_bin="$candidate"
        break
    fi
done

if [[ -n "$luac_bin" ]]; then
    if ! "$luac_bin" -p "$THEME"; then
        printf 'post-apply (black): %s is not valid Lua\n' "$THEME" >&2
        exit 1
    fi
else
    printf 'post-apply (black): luac not installed (pacman -S lua); skipped the syntax check\n' >&2
fi

if ! grep -Fq -- "$EXPECTED_PRIMARY" "$THEME"; then
    printf 'post-apply (black): primary is not rgb(ffffff); the black override in custom/colors.lua will not apply\n' >&2
fi
