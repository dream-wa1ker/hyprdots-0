#!/usr/bin/env bash
# Search live Hyprland shortcuts. Enter copies; Escape closes.
# Dependencies: bash, jq, hyprctl, fuzzel, wl-copy (wl-clipboard).
set -euo pipefail

usage() {
    printf '%s\n' 'Usage: keybinds.sh [--list | --search TEXT]' \
        'Without options: open fuzzel. --list prints the current shortcuts.'
}
fail() {
    printf 'keybinds: %s\n' "$*" >&2
    if command -v notify-send >/dev/null 2>&1; then
        notify-send 'Shortcut viewer' "$*" || true
    fi
    exit 1
}

list_only=false
query=
case "${1:-}" in
    --list) [[ $# == 1 ]] || { usage >&2; exit 2; }; list_only=true ;;
    --search) [[ $# == 2 ]] || { usage >&2; exit 2; }; query=$2 ;;
    --help|-h) usage; exit 0 ;;
    '') ;;
    *) usage >&2; exit 2 ;;
esac
for dependency in hyprctl jq; do
    command -v "$dependency" >/dev/null 2>&1 || fail "Missing dependency: $dependency"
done
if ! "$list_only"; then
    for dependency in fuzzel wl-copy; do
        command -v "$dependency" >/dev/null 2>&1 || fail "Missing dependency: $dependency"
    done
fi

bindings=$(hyprctl -j binds) || fail 'Could not read bindings from Hyprland.'
# Lua dispatchers expose opaque IDs, not their arguments. Associate the existing
# geometry submap with its entry description; resolve the actual key live.
# Unknown submaps remain searchable with an explicit [submap] prefix.
if ! rows=$(jq -r '
    def clean: tostring | gsub("[\u0000-\u001f\u007f]"; " ");
    def bit($n): ((. / $n | floor) % 2) == 1;
    def keyname:
        if . == "Return" then "Enter"
        elif . == "space" or . == "Space" then "Space"
        elif . == "Escape" then "Esc"
        elif . == "BackSpace" then "Backspace"
        elif . == "mouse:272" then "Mouse Left"
        elif . == "mouse:273" then "Mouse Right"
        elif . == "mouse:274" then "Mouse Middle"
        elif . == "mouse_up" then "Wheel Up"
        elif . == "mouse_down" then "Wheel Down"
        elif . == "mouse_left" then "Wheel Left"
        elif . == "mouse_right" then "Wheel Right"
        elif length == 1 then ascii_upcase
        else . end;
    def shortcut:
        (.modmask // 0) as $m |
        ([if $m | bit(64) then "Super" else empty end,
          if $m | bit(4) then "Ctrl" else empty end,
          if $m | bit(8) then "Alt" else empty end,
          if $m | bit(1) then "Shift" else empty end,
          if $m | bit(2) then "CapsLock" else empty end,
          if $m | bit(16) then "Mod2" else empty end,
          if $m | bit(32) then "Mod3" else empty end,
          if $m | bit(128) then "Mod5" else empty end,
          (if (.key // "") != "" then .key | keyname
           else "code:" + ((.keycode // 0) | tostring) end)] | join(" + "));
    if type != "array" then error("expected a binding array") else . end |
    . as $all |
    ([$all[] | select((.submap // "") == "" or .submap == "reset") |
       select(.description == "Enter Window Placement Mode") | shortcut] | unique) as $geometry_entries |
    [ .[] | select(.catch_all != true and .enabled != false) |
      (.submap // "") as $scope |
      {shortcut: (
          if $scope == "" or $scope == "reset" then shortcut
          elif $scope == "geometry" and ($geometry_entries | length) > 0 then
              ($geometry_entries | join(" / ")) + " → " + shortcut
          else "[" + $scope + "] " + shortcut end),
       description: (
          if (.description // "") != "" then .description
          elif (.dispatcher // "") | startswith("function:") then "Lua action"
          else (.dispatcher // "Undescribed action") end |
          if $scope == "geometry" then gsub("_"; " ") else . end),
       flags: ([if .release then "release" else empty end,
                if .repeat then "hold to repeat" else empty end,
                if .longPress then "long press" else empty end,
                if .mouse then "drag" else empty end,
                if .locked then "works when locked" else empty end] | join(", "))
      } |
      .shortcut |= clean | .description |= clean
    ] | unique_by([.shortcut, .description, .flags]) |
    sort_by([(.description | ascii_downcase), .shortcut]) |
    .[] | [.shortcut, (.description + if .flags == "" then "" else " [" + .flags + "]" end)] | @tsv
' <<< "$bindings"); then
    fail 'Could not decode Hyprland bindings.'
fi
[[ -n "$rows" ]] || fail 'No shortcuts are registered.'

declare -a shortcuts=() descriptions=() menu=()
width=0
while IFS=$'\t' read -r shortcut description; do
    shortcuts+=("$shortcut")
    descriptions+=("$description")
    (( ${#shortcut} <= width )) || width=${#shortcut}
done <<< "$rows"
for i in "${!shortcuts[@]}"; do
    printf -v padding '%*s' "$((width - ${#shortcuts[i]}))" ''
    menu+=("${shortcuts[i]}$padding  ${descriptions[i]}")
done
if "$list_only"; then
    printf '%s\n' "${menu[@]}"
    exit 0
fi

status=0
selected=$(printf '%s\n' "${menu[@]}" | fuzzel --dmenu --index --only-match \
    --match-mode=fzf --no-icons --counter --override=main.font=monospace \
    --lines=15 --width=110 --prompt='Shortcuts > ' \
    --placeholder='Search an action or key · Enter copies · Esc closes' \
    --search="$query") || status=$?
case "$status" in
    0) ;;
    1|2) exit 0 ;; # fuzzel cancellation
    *) fail "Fuzzel exited with status $status." ;;
esac
[[ "$selected" =~ ^[0-9]+$ ]] || fail 'Fuzzel returned an invalid selection.'
(( selected < ${#shortcuts[@]} )) || fail 'Fuzzel returned an out-of-range selection.'
printf '%s' "${shortcuts[selected]}" | wl-copy || fail 'Could not copy the shortcut.'
