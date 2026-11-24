#!/usr/bin/env python3
"""Verify profile theme outputs and snapshot files changed by template hooks."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time
import tomllib

HOME = Path.home()
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state"))
VAULT = Path(os.environ.get("OBSIDIAN_VAULT", HOME / "Workspace/notes/obsidian/0000"))
THEME = CONFIG / "hypr/noctalia.lua"

def read(path):
    return Path(path).read_text()

def color(text, pattern):
    match = re.search(pattern, text, re.M)
    if not match:
        raise ValueError("missing color: " + pattern)
    return match[1].lower().lstrip("#")

def settings(path):
    return tomllib.loads(read(path))

def preflight(path, output):
    data = settings(path)
    theme = data.get("theme", {})
    source = theme.get("source", "builtin")
    if theme.get("mode", "dark") != "dark":
        raise ValueError("profile verification currently supports explicit dark mode")
    expected = {}
    if source == "wallpaper":
        wallpaper = data.get("wallpaper", {})
        image = wallpaper.get("default", {}).get("path")
        if not image or not Path(image).is_file():
            raise ValueError("profile wallpaper is missing: " + str(image))
        # Every configured output must use the same wallpaper for this profile.
        if any(v.get("path") != image for v in wallpaper.get("monitors", {}).values()):
            raise ValueError("profile has different monitor wallpapers; choose a single palette wallpaper")
        command = ["noctalia", "theme", image, "--scheme",
                   theme.get("wallpaper_scheme", "m3-tonal-spot"), "--dark"]
        if theme.get("pure_black_dark", False):
            command.append("--pure-black")
        result = subprocess.run(command, capture_output=True, text=True, check=True, timeout=30)
        palette = json.loads(result.stdout)
        expected = {key: palette[key].lower().lstrip("#") for key in ("primary", "surface")}
    elif source == "builtin":
        # Anchors for the built-in palette used by this repository. Fail closed
        # when adding a different built-in rather than accepting old colors.
        anchors = {"Nord": {"primary": "8fbcbb", "surface": "2e3440"}}
        name = theme.get("builtin", "")
        if name not in anchors:
            raise ValueError("add verification anchors for built-in palette: " + name)
        expected = anchors[name]
    else:
        raise ValueError("unsupported profile palette source: " + source)
    Path(output).write_text(json.dumps(expected))

def generated_files():
    # Include generated outputs AND main configs modified by their apply hooks.
    files = set()
    for app in ("alacritty", "btop", "cava", "foot", "fuzzel", "gtk-3.0", "gtk-4.0",
                "qt5ct", "qt6ct", "kitty", "konsole", "bat", "fzf", "fastfetch"):
        directory = CONFIG / app
        if directory.exists():
            files.update(p for p in directory.rglob("*") if p.is_file()
                         and (not p.is_symlink() or p.resolve().is_relative_to(HOME)))
    files.update([THEME, CONFIG / "nvim/lua/matugen.lua", CONFIG / "starship.toml",
                  CONFIG / "kdeglobals", STATE / "noctalia/settings.toml",
                  HOME / ".dotfiles/profiles/.current",
                  VAULT / ".obsidian/appearance.json",
                  VAULT / ".obsidian/snippets/noctalia.css"])
    colors = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share")) / "color-schemes/noctalia.colors"
    files.add(colors)
    return sorted(files)

def snapshot(destination):
    directory = Path(destination)
    directory.mkdir(parents=True, exist_ok=True)
    records = []
    for path in generated_files():
        item = {"path": str(path), "exists": path.is_file()}
        if item["exists"]:
            item["copy"] = str(len(records))
            shutil.copy2(path, directory / item["copy"])
        records.append(item)
    (directory / "manifest.json").write_text(json.dumps(records))

def restore(destination):
    directory = Path(destination)
    records = json.loads(read(directory / "manifest.json"))
    # Files created by a template inside monitored app directories are removed.
    originals = {item["path"] for item in records}
    for path in generated_files():
        if str(path) not in originals and path.is_file():
            path.unlink()
    for item in records:
        path = Path(item["path"])
        if path.is_symlink() and not path.resolve().is_relative_to(HOME):
            continue  # Never write to a system theme through a user symlink.
        if item["exists"]:
            path.parent.mkdir(parents=True, exist_ok=True)
            # Write through symlinks, preserving chezmoi/application integration.
            path.write_bytes((directory / item["copy"]).read_bytes())
            shutil.copystat(directory / item["copy"], path)
        elif path.is_file():
            path.unlink()

def check(data, expected, stamp):
    # Noctalia may skip rewriting identical output. Verify content, not mtime.
    text = read(THEME)
    primary = color(text, r'local primary = "rgb\(([0-9a-fA-F]{6})\)"')
    surface = color(text, r'local surface = "rgb\(([0-9a-fA-F]{6})\)"')
    if expected and (primary != expected["primary"] or surface != expected["surface"]):
        raise ValueError("waiting for the requested wallpaper palette")
    templates = data.get("theme", {}).get("templates", {})
    selected = set(templates.get("builtin_ids", [])) | set(templates.get("community_ids", []))
    checks = [
        ("kitty", CONFIG / "kitty/themes/noctalia.conf", r"^active_tab_background\s+#([0-9a-fA-F]{6})", primary),
        ("foot", CONFIG / "foot/themes/noctalia", r"^background=([0-9a-fA-F]{6})", surface),
        ("fuzzel", CONFIG / "fuzzel/themes/noctalia", r"^input=([0-9a-fA-F]{6})", primary),
        ("btop", CONFIG / "btop/themes/noctalia.theme", r'theme\[title\]="#([0-9a-fA-F]{6})"', primary),
        ("cava", CONFIG / "cava/themes/noctalia", r"foreground\s*=\s*'#([0-9a-fA-F]{6})'", primary),
        ("neovim", CONFIG / "nvim/lua/matugen.lua", r"base00\s*=\s*'#([0-9a-fA-F]{6})'", surface),
    ]
    tracked = [THEME]
    for template, path, pattern, wanted in checks:
        if template in selected:
            if color(read(path), pattern) != wanted:
                raise ValueError(template + " has a stale palette")
            tracked.append(path)
    if "starship" in selected:
        path = CONFIG / "starship.toml"
        palette = tomllib.loads(read(path)).get("palettes", {}).get("noctalia", {})
        if palette.get("base", "").lower() != "#" + surface:
            raise ValueError("Starship apply hook has not finished")
        tracked.append(path)
    if "fastfetch" in selected:
        path = CONFIG / "fastfetch/config.jsonc"
        applied = json.loads(read(path))
        if applied.get("display", {}).get("color", {}).get("keys", "").lower() != "#" + primary:
            raise ValueError("Fastfetch apply hook has not finished")
        tracked.append(path)
    if (VAULT / ".obsidian").is_dir():
        path = VAULT / ".obsidian/snippets/noctalia.css"
        css = read(path)
        if "{{" in css or not re.search(r"--text-accent:\s*#" + primary, css, re.I):
            raise ValueError("Obsidian has not rendered the current palette")
        tracked.append(path)
    return hashlib.sha256(b"".join(path.read_bytes() for path in tracked)).hexdigest()

def wait(path, expected_path, stamp, timeout):
    data = settings(path)
    expected = json.loads(read(Path(expected_path)))
    deadline = time.monotonic() + timeout
    previous = None
    stable_since = None
    issue = "theme generation did not finish"
    while time.monotonic() < deadline:
        try:
            current = check(data, expected, stamp)
            if current != previous:
                previous, stable_since = current, time.monotonic()
            elif time.monotonic() - stable_since >= 3:
                print("Required theme outputs match and have settled.")
                return
        except (ValueError, OSError, KeyError) as error:
            issue = str(error)
            previous = stable_since = None
        time.sleep(0.5)
    raise ValueError("theme verification timed out: " + issue)

def prune(destination, keep):
    directory = Path(destination)
    # Only remove snapshots created by this helper; leave unrelated backups alone.
    snapshots = sorted((p for p in directory.glob("switch-*")
                        if p.is_dir() and (p / "manifest.json").is_file()),
                       key=lambda p: p.stat().st_mtime, reverse=True)
    for path in snapshots[int(keep):]:
        shutil.rmtree(path)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("preflight", "snapshot", "restore", "wait", "prune"))
    parser.add_argument("args", nargs="*")
    options = parser.parse_args()
    if options.operation == "preflight":
        preflight(*options.args)
    elif options.operation == "snapshot":
        snapshot(*options.args)
    elif options.operation == "restore":
        restore(*options.args)
    elif options.operation == "prune":
        prune(*options.args)
    else:
        wait(*options.args[:3], float(options.args[3]))
if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("profile-theme: " + str(error), file=sys.stderr)
        sys.exit(1)
