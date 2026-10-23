#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
SOURCE="${1:-$HOME/Pictures/Wallpapers}"
DEST="$ROOT/dots/Pictures/Wallpapers"

[[ -d "$SOURCE" ]] || { printf 'Wallpaper source directory not found: %s\n' "$SOURCE" >&2; exit 1; }
mkdir -p "$DEST"

# Keep existing repository versions; add all source files without replacing any.
cp -an -- "$SOURCE"/. "$DEST"/
count="$(find "$DEST" -type f | wc -l | tr -d '[:space:]')"
size="$(du -sh "$DEST" | awk '{print $1}')"
printf 'Wallpaper assets now in %s\nFiles: %s\nSize: %s\n\nReview and commit these files:\n  git add dots/Pictures/Wallpapers\n' "$DEST" "$count" "$size"
