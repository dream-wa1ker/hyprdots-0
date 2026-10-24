#!/usr/bin/env bash
# Run ONCE after your first login to Hyprland (Noctalia must be running).
# Enabling a plugin fetches it if needed; Noctalia stores the result.
#
#   Usage: ~/.dotfiles/post-install.sh [--yes]
#
# SECURITY: community plugins run with your user's privileges inside the shell.
# Read each plugin's source before you enable it; remove entries you do not use.
set -uo pipefail

# Format: <author>/<plugin>
PLUGINS=(
    dotnetrob/cat
    blackbartblues/keymap # flagged deprecated; drop it if you do not use it
    thepunkoff/pomodoro
    jamesfeeder/special-workspaces
    yuuto/arch-updater
    aristides/udiskie
    fel/ocr
    h-jangra/region-recorder
    andrewdems/vpn-manager
    noctalia/notes
)

ASSUME_YES=0
for arg in "$@"; do
    case "$arg" in
    --yes | -y) ASSUME_YES=1 ;;
    -h | --help)
        sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
    *)
        echo "Unknown argument: $arg" >&2
        exit 2
        ;;
    esac
done

command -v noctalia >/dev/null 2>&1 || {
    echo 'noctalia not found.' >&2
    exit 1
}

printf 'Plugins to enable (%d):\n' "${#PLUGINS[@]}"
printf '  %s\n' "${PLUGINS[@]}"
if ((!ASSUME_YES)); then
    read -r -p 'These are third-party plugins. Enable them? [y/N] ' answer || answer=''
    [[ "$answer" =~ ^([yY]|[yY][eE][sS])$ ]] || {
        echo 'Cancelled.'
        exit 0
    }
fi

echo 'Waiting for Noctalia...'
for _ in $(seq 1 30); do
    noctalia msg plugins list >/dev/null 2>&1 && break
    sleep 1
done
noctalia msg plugins list >/dev/null 2>&1 || {
    echo 'Noctalia is not running. Log in to Hyprland first, then re-run.' >&2
    exit 1
}

# A plugin download can fail on a flaky network, so try a few times.
enable_plugin() {
    local id="$1"
    for _ in 1 2 3; do
        noctalia msg plugins enable "$id" && return 0
        sleep 3
    done
    return 1
}

failed=0
listing="$(noctalia msg plugins list)"
for id in "${PLUGINS[@]}"; do
    if grep -Eq "^${id} .*enabled" <<<"$listing"; then
        echo "ok       $id"
    elif enable_plugin "$id"; then
        echo "enabled  $id"
    else
        echo "FAILED   $id" >&2
        failed=1
    fi
done

echo
noctalia msg plugins list | grep -E "^($(
    IFS='|'
    echo "${PLUGINS[*]}"
))( |\$)" || true
noctalia config validate || failed=1
exit "$failed"
