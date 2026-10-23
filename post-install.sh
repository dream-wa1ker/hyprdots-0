#!/usr/bin/env bash
# Run ONCE after your first login to Hyprland (Noctalia must be running).
# Enabling a plugin fetches it if needed; the result is stored by Noctalia.
set -uo pipefail

PLUGINS=(
    dotnetrob/cat
    blackbartblues/keymap
    thepunkoff/pomodoro
    jamesfeeder/special-workspaces
    yuuto/arch-updater
    aristides/udiskie
    fel/ocr
    h-jangra/region-recorder
    andrewdems/vpn-manager
    noctalia/notes
)

command -v noctalia >/dev/null 2>&1 || {
    echo 'noctalia not found.' >&2
    exit 1
}

echo 'Waiting for Noctalia...'
for _ in $(seq 1 30); do
    noctalia msg plugins list >/dev/null 2>&1 && break
    sleep 1
done
noctalia msg plugins list >/dev/null 2>&1 ||
    {
        echo 'Noctalia is not running. Log in to Hyprland first, then re-run.' >&2
        exit 1
    }

failed=0
listing="$(noctalia msg plugins list)"
for id in "${PLUGINS[@]}"; do
    if grep -q "^$id .*enabled" <<<"$listing"; then
        echo "ok       $id"
    elif noctalia msg plugins enable "$id"; then
        echo "enabled  $id"
    else
        echo "FAILED   $id" >&2
        failed=1
    fi
done

echo
noctalia msg plugins list | grep -E "$(
    IFS='|'
    echo "${PLUGINS[*]}"
)"
noctalia config validate || failed=1
exit "$failed"
