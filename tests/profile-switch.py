#!/usr/bin/env python3
"""Exercise profile-switch failure, recovery, capture, and locking without a desktop."""
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
def main():
    with tempfile.TemporaryDirectory(prefix="profile-switch-test-") as temp:
        home = Path(temp)
        repo = home / ".dotfiles"
        scripts = repo / "scripts"
        profile = repo / "profiles/test/noctalia"
        state = home / ".local/state"
        bin_dir = home / "bin"
        for directory in (scripts, profile, state / "noctalia", repo / "dots", bin_dir):
            directory.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / "scripts/profile-switch", scripts / "profile-switch")
        (profile / "settings.toml").write_text('[theme]\nsource="builtin"\n')
        live = state / "noctalia/settings.toml"
        live.write_text("original")
        current = repo / "profiles/.current"
        current.write_text("original\n")
        helper = """
import os,sys,shutil
from pathlib import Path
home=Path.home();live=home/'.local/state/noctalia/settings.toml';current=home/'.dotfiles/profiles/.current'
op=sys.argv[1]
if op=='preflight':Path(sys.argv[3]).write_text('{}')
elif op=='snapshot':
 d=Path(sys.argv[2]);d.mkdir(exist_ok=True)
 shutil.copy2(live,d/'settings');shutil.copy2(current,d/'current')
elif op=='restore':
 d=Path(sys.argv[2]);shutil.copy2(d/'settings',live);shutil.copy2(d/'current',current)
 (home/'restored').touch()
elif op=='wait' and os.getenv('FAIL_WAIT'):sys.exit(1)
"""
        (scripts / "profile-theme.py").write_text(helper)
        mocks = {
            "noctalia": "#!/bin/sh\nexit 0\n",
            "hyprctl": "#!/bin/sh\nexit 0\n",
            "chezmoi": "#!/bin/sh\ntouch \"$HOME/captured\"\n",
        }
        for name, source in mocks.items():
            path = bin_dir / name
            path.write_text(source)
            path.chmod(0o755)
        env = dict(os.environ, HOME=str(home), PATH=str(bin_dir) + ":" + os.environ["PATH"])
        def run(**extra):
            return subprocess.run(["bash", str(scripts / "profile-switch"), "test"],
                                  env=dict(env, **extra), capture_output=True, text=True)
        result = run(FAIL_WAIT="1")
        assert result.returncode != 0 and "activated" not in result.stdout, result
        assert live.read_text() == "original" and current.read_text() == "original\n"
        assert (home / "restored").exists() and not (home / "captured").exists()
        result = run()
        assert result.returncode == 0 and "activated" in result.stdout, result
        assert (home / "captured").exists() and current.read_text() == "test\n"
        lock_path = state / "hyprdots/profile-switch.lock"
        with lock_path.open("w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result = run()
            assert result.returncode != 0 and "already running" in result.stderr, result
        print("Passed: failed generation rolls back, incomplete outputs are not captured, success captures, concurrent switch is rejected.")
if __name__ == "__main__":
    main()
