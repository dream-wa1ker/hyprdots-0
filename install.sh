#!/usr/bin/env bash
# hyprdots installer for Arch Linux and Arch-based systems.
# Run as your normal user (not root) from the clone at ~/.dotfiles. Safe to re-run.
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_ROOT="$ROOT/dots"
PROFILES_DIR="$ROOT/profiles"
PACMAN_MANIFEST="$ROOT/packages/arch-desktop.txt"
AUR_MANIFEST="$ROOT/packages/aur-optional.txt"
STATE_DIR="$HOME/.local/state/hyprdots"

# The repository was authored under this home directory. Every occurrence in the
# tracked configuration is rewritten to the installing user's $HOME (rewrite_home).
OLD_HOME="/home/rev"
# First Hyprland release that reads hyprland.lua.
MIN_HYPRLAND="0.55.0"

# Needed by the config but not in the manifest (Neovim parsers, C tooling).
EXTRA_PKGS=(base-devel tree-sitter-cli clang)
BOOTSTRAP_PKGS=(git chezmoi)

WITH_AUR=0
ASSUME_YES=0
SKIP_SERVICES=0
WARNINGS=()

usage() {
    cat <<'USAGE'
Usage: ./install.sh [--with-aur] [--yes] [--no-services]

  --with-aur     Also install packages from packages/aur-optional.txt using an
                 already-installed yay or paru (no AUR helper is installed for you).
  --yes          Answer "yes" to every prompt (non-interactive). The chezmoi diff
                 is still printed before dotfiles are applied.
  --no-services  Do not offer to enable NetworkManager/Bluetooth/power-profiles.

Steps: sanity checks -> full upgrade + packages -> Hyprland version gate -> user
directories -> services -> home-path rewrite -> backup + chezmoi diff/apply ->
fish login shell -> validation.
The repository must live at ~/.dotfiles.
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
    B=$'\e[1m' R=$'\e[31m' Y=$'\e[33m' G=$'\e[32m' N=$'\e[0m'
else
    B='' R='' Y='' G='' N=''
fi
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
trap 'die "Failed at line $LINENO: $BASH_COMMAND"' ERR

ask_yes() {
    local prompt="$1" answer
    if ((ASSUME_YES)); then
        printf '%s [auto-yes]\n' "$prompt"
        return 0
    fi
    read -r -p "$prompt [y/N] " answer || true
    [[ "$answer" =~ ^([yY]|[yY][eE][sS])$ ]]
}

read_manifest() { grep -Ev '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]*#.*$//; s/^[[:space:]]*//; s/[[:space:]]*$//'; }

is_arch_based() {
    [[ -f /etc/arch-release ]] && return 0
    local ids
    ids="$(
        # shellcheck disable=SC1091
        . /etc/os-release 2>/dev/null
        printf '%s %s' "${ID:-}" "${ID_LIKE:-}"
    )" || return 1
    [[ " $ids " == *" arch "* ]]
}

# Rewrite OLD_HOME/ to $HOME/ in every tracked text file of dots/ and profiles/.
# Plain `sed`, idempotent, and a no-op when the home directory is unchanged.
# NOTE: this edits tracked files; do not commit them from a machine whose home
# directory differs from OLD_HOME.
rewrite_home() {
    local new_home="$HOME" repl pattern f
    local -a files=()
    if [[ "$new_home" == "$OLD_HOME" ]]; then
        info "Home directory is $OLD_HOME; no path rewrite needed."
        return 0
    fi
    mapfile -d '' -t files < <(grep -rlIFZ --exclude-dir=.git -- "$OLD_HOME/" "$SOURCE_ROOT" "$PROFILES_DIR" 2>/dev/null || true)
    ((${#files[@]})) || {
        info "No files contain $OLD_HOME/; nothing to rewrite."
        return 0
    }
    # Escape the replacement for sed (\ & and the | delimiter).
    repl="${new_home//\\/\\\\}"
    repl="${repl//&/\\&}"
    repl="${repl//|/\\|}"
    pattern="${OLD_HOME//./\\.}/"
    for f in "${files[@]}"; do
        sed -i "s|${pattern}|${repl}/|g" "$f"
        ok "Rewrote paths in ${f#"$ROOT"/}"
    done
    if grep -rqIF --exclude-dir=.git -- "$OLD_HOME/" "$SOURCE_ROOT" "$PROFILES_DIR" 2>/dev/null; then
        warn "Some files still contain $OLD_HOME/ after the rewrite."
    fi
}

# Archive the files chezmoi is about to overwrite (private, restorable with
# `tar -xzf <archive> -C /`).
backup_existing() {
    local managed_out p backup
    local -a managed=() existing=()
    if ! managed_out="$("${CZ[@]}" managed --include=files --path-style=absolute 2>&1)"; then
        warn "chezmoi managed failed, so no backup was made: ${managed_out}"
        return 0
    fi
    mapfile -t managed <<<"$managed_out"
    for p in "${managed[@]}"; do
        if [[ -f "$p" ]]; then existing+=("$p"); fi
    done
    if ((${#existing[@]} == 0)); then
        info 'No existing managed files to back up.'
        return 0
    fi
    mkdir -p -- "$STATE_DIR"
    backup="$STATE_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    if (umask 077 && tar -czf "$backup" -- "${existing[@]}" 2>/dev/null); then
        ok "Backed up ${#existing[@]} existing files to $backup"
    else
        warn 'Could not create the backup archive.'
    fi
}

# ---------- 1. sanity checks ----------
step 'Checking the system'
((EUID != 0)) || die 'Run as your normal user, not root. sudo is used where needed.'
is_arch_based || die 'This installer targets Arch Linux and Arch-based distributions.'
command -v pacman >/dev/null 2>&1 || die 'pacman was not found.'
command -v sudo >/dev/null 2>&1 || die 'sudo is required. As root: pacman -S sudo, then add your user to wheel.'
command -v curl >/dev/null 2>&1 || die 'curl is required (pacman -S curl).'
sudo -v || die 'sudo authentication failed.'
curl -fsI --max-time 10 https://archlinux.org >/dev/null 2>&1 ||
    die 'No network connection. Connect first (iwctl / nmcli) and re-run.'

[[ "$ROOT" == "$(cd -- "$HOME/.dotfiles" 2>/dev/null && pwd -P || true)" ]] ||
    die "The repository must be cloned to ~/.dotfiles (this copy is at $ROOT)."
[[ "$(tr -d '[:space:]' <"$ROOT/.chezmoiroot" 2>/dev/null)" == dots ]] ||
    die '.chezmoiroot at the repository root must contain exactly: dots'
[[ -d "$SOURCE_ROOT/dot_config/hypr" ]] || die 'Expected dots/dot_config/hypr in this repository.'
[[ -f "$PACMAN_MANIFEST" ]] || die "Missing $PACMAN_MANIFEST"

wallpaper_dir="$SOURCE_ROOT/Pictures/Wallpapers"
find "$wallpaper_dir" -type f -print -quit 2>/dev/null | grep -q . ||
    die "No wallpapers in $wallpaper_dir. On the source computer run scripts/import-wallpapers.sh, commit, and pull here."

# git does not always keep the executable bit (zip downloads, odd filesystems).
chmod +x "$ROOT/install.sh" "$ROOT/post-install.sh" "$ROOT"/scripts/* "$ROOT"/profiles/*/post-apply.sh 2>/dev/null || true

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
for p in "${packages[@]}"; do
    pacman -Si -- "$p" >/dev/null 2>&1 || missing+=("$p")
done
if ((${#missing[@]})); then
    die "Not found in the enabled repositories: ${missing[*]}. Fix packages/arch-desktop.txt (AUR packages belong in aur-optional.txt)."
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

# Version gate: an older Hyprland cannot read hyprland.lua and would start with no config.
step 'Hyprland version'
hypr_ver="$(pacman -Q hyprland 2>/dev/null | awk '{print $2}' || true)"
[[ -n "$hypr_ver" ]] || die 'hyprland is not installed.'
hypr_ver="${hypr_ver#*:}" # drop epoch
hypr_ver="${hypr_ver%-*}" # drop pkgrel
if (($(vercmp "$hypr_ver" "$MIN_HYPRLAND") < 0)); then
    die "Hyprland $hypr_ver is older than $MIN_HYPRLAND, the first release with Lua configuration. Update your mirrors/distribution and re-run."
fi
ok "Hyprland $hypr_ver (>= $MIN_HYPRLAND)"

# ---------- 3. directories ----------
step 'User directories'
command -v xdg-user-dirs-update >/dev/null 2>&1 && xdg-user-dirs-update || true
mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots" "$HOME/Videos/Recordings" \
    "$HOME/Documents/Notes" "$HOME/.local/bin" "$HOME/.cache" "$STATE_DIR"

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

# ---------- 5. home paths ----------
step 'Personalizing configuration paths'
rewrite_home

# ---------- 6. chezmoi ----------
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
backup_existing
"${CZ[@]}" apply -v

command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null 2>&1 || true
if command -v fc-list >/dev/null 2>&1 && ! fc-list | grep -qi 'Google Sans Flex'; then
    warn 'Font "Google Sans Flex" (used by fuzzel.ini) is not installed; fuzzel will fall back to a default font.'
fi

# ---------- 7. login shell ----------
step 'Login shell'
fish_path="$(command -v fish || true)"
if [[ -n "$fish_path" && "$(getent passwd "$USER" | cut -d: -f7)" != "$fish_path" ]]; then
    grep -qx "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    if ask_yes "Set fish as your login shell (needed for the tty1 Hyprland autostart)?"; then
        sudo chsh -s "$fish_path" "$USER" || warn 'chsh failed; run: chsh -s /usr/bin/fish'
    fi
fi

# ---------- 8. validation ----------
step 'Validation'
if command -v noctalia >/dev/null 2>&1; then
    noctalia config validate || warn 'noctalia config validate reported errors; inspect before logging in.'
else
    warn 'noctalia is not installed or not on PATH.'
fi
[[ -f "$HOME/.config/hypr/hyprland.lua" ]] || warn "$HOME/.config/hypr/hyprland.lua is missing after apply."
current_profile=''
[[ -f "$PROFILES_DIR/.current" ]] && IFS= read -r current_profile <"$PROFILES_DIR/.current" || true
if [[ ! "$current_profile" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ || ! -d "$PROFILES_DIR/$current_profile" ]]; then
    warn "profiles/.current does not name an existing profile ('$current_profile'). Run: $ROOT/scripts/profile-switch"
fi

# ---------- summary ----------
step 'Done'
if ((${#WARNINGS[@]})); then
    printf '%sWarnings (%d):%s\n' "$Y" "${#WARNINGS[@]}" "$N"
    printf '  - %s\n' "${WARNINGS[@]}"
fi

cat <<DONE

Next:
  1. Reboot (or log out), then log in on tty1: fish starts Hyprland via start-hyprland.
     Log: ~/.cache/hyprland.log
  2. Inside Hyprland, run once:  $ROOT/post-install.sh
     (enables and fetches the Noctalia plugins; re-run if one fails)
  3. Sign into Google again if the calendar asks.
  4. Open nvim once and let lazy.nvim install plugins.
Backups of replaced files: $STATE_DIR
DONE
