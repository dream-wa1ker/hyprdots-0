#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_ROOT="$ROOT/dots"
PACMAN_MANIFEST="$ROOT/packages/arch-desktop.txt"
AUR_MANIFEST="$ROOT/packages/aur-optional.txt"
WITH_AUR=0

for arg in "$@"; do
    case "$arg" in
        --with-aur) WITH_AUR=1 ;;
        -h|--help)
            cat <<'USAGE'
Usage: ./install.sh [--with-aur]

Installs the curated desktop packages, creates the directories used by the
configuration, previews and applies chezmoi dotfiles, then validates Noctalia.

--with-aur  Also install packages listed in packages/aur-optional.txt using an
            already-installed yay or paru. No AUR helper is installed automatically.
USAGE
            exit 0
            ;;
        *) printf 'Unknown argument: %s\n' "$arg" >&2; exit 2 ;;
    esac
done

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
ask_yes() {
    local prompt="$1" answer
    read -r -p "$prompt [y/N] " answer || true
    case "$answer" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

[[ -f /etc/arch-release ]] || die 'This installer targets Arch Linux.'
command -v pacman >/dev/null 2>&1 || die 'pacman was not found.'
command -v chezmoi >/dev/null 2>&1 || die 'Install chezmoi first: sudo pacman -S --needed chezmoi git'
[[ -f "$ROOT/.chezmoiroot" ]] || die 'Missing repository-root .chezmoiroot. It must contain: dots'
[[ "$(tr -d '[:space:]' < "$ROOT/.chezmoiroot")" == dots ]] || die '.chezmoiroot must contain exactly: dots'
[[ -d "$SOURCE_ROOT/dot_config/hypr" ]] || die 'Expected dots/dot_config/hypr in this repository.'
[[ -f "$PACMAN_MANIFEST" ]] || die "Missing $PACMAN_MANIFEST"

# For the author's local checkout and a friend's chezmoi clone, this must be
# the same source tree. Avoid applying the wrong repository by accident.
actual_source="$(chezmoi source-path 2>/dev/null || true)"
if [[ -z "$actual_source" ]]; then
    die 'chezmoi has no initialized source. Run: chezmoi init <repository-url>'
fi
actual_source="$(realpath -- "$actual_source")"
expected_source="$(realpath -- "$SOURCE_ROOT")"
[[ "$actual_source" == "$expected_source" ]] || die "chezmoi source mismatch. Expected '$expected_source', but 'chezmoi source-path' reports '$actual_source'. Run chezmoi init on this repository before installing."

wallpaper_dir="$SOURCE_ROOT/Pictures/Wallpapers"
if [[ ! -d "$wallpaper_dir" ]] || ! find "$wallpaper_dir" -type f -print -quit | grep -q .; then
    die "No wallpapers are stored in the dotfiles source. On the source computer, run '$ROOT/scripts/import-wallpapers.sh' and commit the files under dots/Pictures/Wallpapers before installing on another machine."
fi

mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' "$PACMAN_MANIFEST")
((${#packages[@]} > 0)) || die 'The official package manifest is empty.'

printf '\nRepository: %s\nChezmoi source: %s\n' "$ROOT" "$actual_source"
printf '\nOfficial Arch packages to install (%d):\n' "${#packages[@]}"
printf '  %s\n' "${packages[@]}"
printf '\nThis runs a full Arch upgrade (pacman -Syu) before installing the listed packages.\n'
ask_yes 'Proceed with system upgrade and package installation?' || { printf 'Cancelled.\n'; exit 0; }
sudo pacman -Syu --needed "${packages[@]}"

if (( WITH_AUR )); then
    [[ -f "$AUR_MANIFEST" ]] || die "Missing $AUR_MANIFEST"
    mapfile -t aur_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$AUR_MANIFEST")
    if ((${#aur_packages[@]})); then
        if command -v yay >/dev/null 2>&1; then
            aur_helper=(yay -S --needed)
        elif command -v paru >/dev/null 2>&1; then
            aur_helper=(paru -S --needed)
        else
            die '--with-aur requested, but neither yay nor paru is installed. Install and review an AUR helper yourself, then rerun.'
        fi
        printf '\nOptional AUR packages (%d):\n' "${#aur_packages[@]}"
        printf '  %s\n' "${aur_packages[@]}"
        ask_yes 'Install these optional AUR appearance packages?' && "${aur_helper[@]}" "${aur_packages[@]}"
    fi
fi

# These directories are referenced by Noctalia settings and plugins. Do not
# copy user data here; only create the directories.
mkdir -p \
    "$HOME/Pictures/Wallpapers" \
    "$HOME/Pictures/Screenshots" \
    "$HOME/Videos/Recordings" \
    "$HOME/Documents/Notes" \
    "$HOME/.local/bin"

if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl is-active --quiet NetworkManager.service; then
        printf '\nThe enabled andrewdems/vpn-manager plugin needs NetworkManager (nmcli).\n'
        printf 'Enabling NetworkManager may change how the laptop manages Wi-Fi; do not enable it if the existing network stack should remain untouched.\n'
        if ask_yes 'Enable and start NetworkManager now?'; then
            sudo systemctl enable --now NetworkManager.service
        else
            printf 'Skipped NetworkManager activation. VPN Manager will need it enabled to function.\n'
        fi
    fi

    if systemctl list-unit-files bluetooth.service >/dev/null 2>&1 && ! systemctl is-active --quiet bluetooth.service; then
        if ask_yes 'Enable and start Bluetooth?'; then
            sudo systemctl enable --now bluetooth.service
        fi
    fi

    if systemctl list-unit-files power-profiles-daemon.service >/dev/null 2>&1 && ! systemctl is-active --quiet power-profiles-daemon.service; then
        if ask_yes 'Enable power-profiles-daemon for Noctalia power-profile controls?'; then
            sudo systemctl enable --now power-profiles-daemon.service
        fi
    fi
fi

printf '\nPreviewing chezmoi changes. Review the diff carefully before continuing.\n\n'
chezmoi diff
chezmoi status
ask_yes 'Apply the dotfiles now?' || { printf 'Dotfiles were not applied. Run chezmoi diff and chezmoi apply when ready.\n'; exit 0; }
chezmoi apply -v

if command -v noctalia >/dev/null 2>&1; then
    printf '\nValidating Noctalia configuration...\n'
    if ! noctalia config validate; then
        printf 'WARNING: Noctalia validation reported errors. Inspect them before logging into this configuration.\n' >&2
    fi
fi

cat <<'DONE'

Base deployment complete.

Next:
  1. Log into the Hyprland session.
  2. The startup hook waits for Noctalia IPC and enables/fetches the ten configured plugins.
  3. Inspect the session log at ~/.local/state/hyprdots/noctalia-plugins.log if plugin setup reports an error.
  4. Run 'noctalia msg plugins list' and 'noctalia config validate' after the first login.

The Google Calendar account configuration is copied, but credentials in the desktop
Secret Service are not portable; sign into Google on the new machine if prompted.
DONE
