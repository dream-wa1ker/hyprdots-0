#!/usr/bin/env bash
# hyprdots-0 installer for a fresh Arch Linux install.
# Run as your normal user (not root) from anywhere inside the cloned repo.
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_ROOT="$ROOT/dots"
PACMAN_MANIFEST="$ROOT/packages/arch-desktop.txt"
AUR_MANIFEST="$ROOT/packages/aur-optional.txt"

# Needed by the config but not in the manifest (Neovim parsers, C tooling).
EXTRA_PKGS=(base-devel tree-sitter-cli clang)
BOOTSTRAP_PKGS=(git chezmoi)

WITH_AUR=0
ASSUME_YES=0
SKIP_SERVICES=0

usage() {
    cat <<'USAGE'
Usage: ./install.sh [--with-aur] [--yes] [--no-services]

  --with-aur     Also install packages from packages/aur-optional.txt using an
                 already-installed yay or paru (no AUR helper is installed for you).
  --yes          Answer "yes" to every prompt (non-interactive). The chezmoi diff
                 is still printed before dotfiles are applied.
  --no-services  Do not offer to enable NetworkManager/Bluetooth/power-profiles.

Steps: sanity checks -> full upgrade + packages -> user directories -> services ->
chezmoi diff + apply -> fish login shell -> Noctalia validation.
Safe to re-run.
USAGE
}

for arg in "$@"; do
    case "$arg" in
    --with-aur) WITH_AUR=1 ;;
    --yes | -y) ASSUME_YES=1 ;;
    --no-services) SKIP_SERVICES=1 ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        printf 'Unknown argument: %s\n' "$arg" >&2
        usage >&2
        exit 2
        ;;
    esac
done

# ---------- helpers ----------
if [[ -t 1 ]]; then
    B=$'\e[1m'
    R=$'\e[31m'
    Y=$'\e[33m'
    G=$'\e[32m'
    N=$'\e[0m'
else B= R= Y= G= N=; fi
step() { printf '\n%s==> %s%s\n' "$B" "$*" "$N"; }
info() { printf '%s\n' "$*"; }
ok() { printf '%s%s%s\n' "$G" "$*" "$N"; }
warn() {
    printf '%sWARNING: %s%s\n' "$Y" "$*" "$N" >&2
    WARNINGS+=("$*")
}
die() {
    printf '%sERROR: %s%s\n' "$R" "$*" "$N" >&2
    exit 1
}
WARNINGS=()
trap 'die "Failed at line $LINENO: $BASH_COMMAND"' ERR

ask_yes() {
    local prompt="$1" answer
    ((ASSUME_YES)) && {
        printf '%s [auto-yes]\n' "$prompt"
        return 0
    }
    read -r -p "$prompt [y/N] " answer || true
    [[ "$answer" =~ ^([yY]|[yY][eE][sS])$ ]]
}
read_manifest() { grep -Ev '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]*#.*$//; s/^[[:space:]]*//; s/[[:space:]]*$//'; }

# ---------- 1. sanity checks ----------
step 'Checking the system'
((EUID != 0)) || die 'Run as your normal user, not root. sudo is used where needed.'
[[ -f /etc/arch-release ]] || die 'This installer targets Arch Linux.'
command -v pacman >/dev/null 2>&1 || die 'pacman was not found.'
command -v sudo >/dev/null 2>&1 || die 'sudo is required. As root: pacman -S sudo, then add your user to wheel.'
sudo -v || die 'sudo authentication failed.'
curl -fsI --max-time 10 https://archlinux.org >/dev/null 2>&1 ||
    die 'No network connection. Connect first (iwctl / nmcli) and re-run.'

[[ "$(tr -d '[:space:]' <"$ROOT/.chezmoiroot" 2>/dev/null)" == dots ]] ||
    die '.chezmoiroot at the repository root must contain exactly: dots'
[[ -d "$SOURCE_ROOT/dot_config/hypr" ]] || die 'Expected dots/dot_config/hypr in this repository.'
[[ -f "$PACMAN_MANIFEST" ]] || die "Missing $PACMAN_MANIFEST"

wallpaper_dir="$SOURCE_ROOT/Pictures/Wallpapers"
find "$wallpaper_dir" -type f -print -quit 2>/dev/null | grep -q . ||
    die "No wallpapers in $wallpaper_dir. On the source computer run scripts/import-wallpapers.sh, commit, and pull here."

# ---------- 2. packages ----------
step 'Packages'
mapfile -t packages < <(
    read_manifest "$PACMAN_MANIFEST"
    printf '%s\n' "${EXTRA_PKGS[@]}" "${BOOTSTRAP_PKGS[@]}"
)
mapfile -t packages < <(printf '%s\n' "${packages[@]}" | awk '!seen[$0]++')
((${#packages[@]} > 0)) || die 'The package list is empty.'

printf 'Packages to install (%d):\n' "${#packages[@]}"
printf '  %s\n' "${packages[@]}"
info 'This runs a FULL system upgrade (pacman -Syu) first.'
ask_yes 'Proceed with system upgrade and package installation?' || {
    info 'Cancelled.'
    exit 0
}

PACFLAGS=()
((ASSUME_YES)) && PACFLAGS=(--noconfirm)
sudo pacman -Syu "${PACFLAGS[@]}"
missing=()
for p in "${packages[@]}"; do pacman -Si -- "$p" >/dev/null 2>&1 || missing+=("$p"); done
if ((${#missing[@]})); then
    die "Not found in the official repositories: ${missing[*]}. Fix packages/arch-desktop.txt (AUR packages belong in aur-optional.txt)."
fi
sudo pacman -S --needed "${PACFLAGS[@]}" "${packages[@]}"

if ((WITH_AUR)); then
    [[ -f "$AUR_MANIFEST" ]] || die "Missing $AUR_MANIFEST"
    mapfile -t aur_packages < <(read_manifest "$AUR_MANIFEST")
    if ((${#aur_packages[@]})); then
        if command -v yay >/dev/null 2>&1; then
            aur_helper=(yay -S --needed)
        elif command -v paru >/dev/null 2>&1; then
            aur_helper=(paru -S --needed)
        else die '--with-aur needs yay or paru already installed. Install and review one yourself, then re-run.'; fi
        printf '\nOptional AUR packages (%d):\n' "${#aur_packages[@]}"
        printf '  %s\n' "${aur_packages[@]}"
        info 'AUR packages are unreviewed user submissions: check each PKGBUILD.'
        if ask_yes 'Install these optional AUR packages?'; then
            "${aur_helper[@]}" "${aur_packages[@]}" || warn 'Some AUR packages failed to install.'
        fi
    fi
fi

# ---------- 3. directories ----------
step 'User directories'
command -v xdg-user-dirs-update >/dev/null 2>&1 && xdg-user-dirs-update || true
mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots" "$HOME/Videos/Recordings" \
    "$HOME/Documents/Notes" "$HOME/.local/bin" "$HOME/.cache" "$HOME/.local/state/hyprdots"

# ---------- 4. services ----------
if ((!SKIP_SERVICES)) && command -v systemctl >/dev/null 2>&1; then
    step 'Services'
    enable_unit() { # unit, prompt
        local unit="$1" prompt="$2"
        systemctl list-unit-files "$unit" 2>/dev/null | grep -q "^$unit" || return 0
        systemctl is-active --quiet "$unit" && return 0
        ask_yes "$prompt" && sudo systemctl enable --now "$unit" || info "Skipped $unit."
    }
    if systemctl is-active --quiet iwd.service || systemctl is-active --quiet systemd-networkd.service; then
        warn 'iwd/systemd-networkd is active. Enabling NetworkManager too can conflict; VPN Manager needs NetworkManager.'
    fi
    enable_unit NetworkManager.service 'Enable NetworkManager (needed by the VPN Manager plugin; may change how Wi-Fi is managed)?'
    enable_unit bluetooth.service 'Enable Bluetooth?'
    enable_unit power-profiles-daemon.service 'Enable power-profiles-daemon (Noctalia power profile controls)?'
    systemctl --user enable --now mpd.service 2>/dev/null || true
fi

# ---------- Replace installer-specific home paths ----------
step 'Personalizing configuration paths'

OLD_HOME="/home/rev"
NEW_HOME="$HOME"

for file in \
    "$SOURCE_ROOT/dot_config/fuzzel/fuzzel.ini" \
    "$SOURCE_ROOT/dot_local/state/noctalia/settings.toml"; do

    [[ -f "$file" ]] || continue

    if grep -Fq "$OLD_HOME/" "$file"; then
        sed -i "s|${OLD_HOME}|${NEW_HOME}|g" "$file"
        ok "Updated paths in ${file#"$ROOT"/}"
    fi
done

# ---------- 5. chezmoi ----------
step 'Dotfiles (chezmoi)'
CZ=(chezmoi --source "$ROOT" --no-pager)
actual_source="$(realpath -- "$("${CZ[@]}" source-path)")"
[[ "$actual_source" == "$(realpath -- "$SOURCE_ROOT")" ]] ||
    die "chezmoi source is '$actual_source', expected '$SOURCE_ROOT'. Check .chezmoiroot."

# Make plain `chezmoi diff/apply/add` use this repository from now on.
cz_conf="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"
if [[ ! -e "$cz_conf" ]]; then
    mkdir -p "$(dirname "$cz_conf")"
    printf 'sourceDir = "%s"\n' "$ROOT" >"$cz_conf"
    ok "Wrote $cz_conf (sourceDir = $ROOT)"
elif [[ "$(realpath -- "$(chezmoi source-path 2>/dev/null || echo /nonexistent)")" != "$actual_source" ]]; then
    warn "Plain 'chezmoi' does not use this repo. Add: sourceDir = \"$ROOT\" to $cz_conf"
fi

info 'Previewing changes. Review carefully:'
"${CZ[@]}" diff || true
"${CZ[@]}" status || true
ask_yes 'Apply the dotfiles now?' || {
    info 'Not applied. Later: chezmoi diff && chezmoi apply'
    exit 0
}
"${CZ[@]}" apply -v

command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null 2>&1 || true
if command -v fc-list >/dev/null 2>&1 && ! fc-list | grep -qi 'Google Sans Flex'; then
    warn 'Font "Google Sans Flex" (used by fuzzel.ini) is not installed; fuzzel will fall back to a default font.'
fi

# ---------- 6. login shell ----------
step 'Login shell'
fish_path="$(command -v fish || true)"
if [[ -n "$fish_path" && "$(getent passwd "$USER" | cut -d: -f7)" != "$fish_path" ]]; then
    grep -qx "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    if ask_yes "Set fish as your login shell (needed for the tty1 Hyprland autostart)?"; then
        sudo chsh -s "$fish_path" "$USER" || warn 'chsh failed; run: chsh -s /usr/bin/fish'
    fi
fi

# ---------- 7. validation ----------
step 'Validation'
if command -v noctalia >/dev/null 2>&1; then
    noctalia config validate || warn 'noctalia config validate reported errors; inspect before logging in.'
else
    warn 'noctalia is not installed or not on PATH.'
fi
[[ -f "$HOME/.config/hypr/hyprland.lua" ]] || warn '~/.config/hypr/hyprland.lua is missing after apply.'

# ---------- summary ----------
step 'Done'
if ((${#WARNINGS[@]})); then
    printf '%sWarnings (%d):%s\n' "$Y" "${#WARNINGS[@]}" "$N"
    printf '  - %s\n' "${WARNINGS[@]}"
fi

cat <<'DONE'

Next:
  1. Reboot (or log out), then log in on tty1: fish starts Hyprland via start-hyprland.
     Log: ~/.cache/hyprland.log
  2. Inside Hyprland, run once:  ~/.local/share/chezmoi/post-install.sh
     (enables and fetches the ten Noctalia plugins; re-run if one fails)
  3. Sign into Google again if the calendar asks.
  4. Open nvim once and let lazy.nvim install plugins.
DONE
