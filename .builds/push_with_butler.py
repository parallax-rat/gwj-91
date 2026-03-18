from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib import error, request
from zipfile import ZIP_DEFLATED, ZipFile

ITCH_USER = "parallaxrat"
ITCH_GAME = "gwj-91"
BUILD_CHANNEL = "html"
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1483654934053257366/y2triNS9vCdd4_EUOptmaDAZS6wBGRJHTmrl3Zt3AGRsFzjw0eszWjXYUN7LluDfhwFM"

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent
PYTHON_SCRIPT = Path(__file__).resolve()
LEGACY_ZIP = SCRIPT_DIR / "gwj-91-build.zip"
EXCLUDED_DIR_NAMES = {"__pycache__"}


def ensure_butler_installed() -> None:
    if shutil.which("butler") is None:
        raise RuntimeError("Butler not found. Please install butler from https://itch.io/app")


def iter_build_files():
    excluded_paths = {PYTHON_SCRIPT, LEGACY_ZIP}

    for root, dir_names, file_names in os.walk(SCRIPT_DIR):
        dir_names[:] = sorted(name for name in dir_names if name not in EXCLUDED_DIR_NAMES)
        root_path = Path(root)

        for file_name in sorted(file_names):
            path = (root_path / file_name).resolve()
            if path in excluded_paths:
                continue
            yield path


def create_archive(zip_path: Path) -> int:
    file_count = 0

    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as archive:
        for file_path in iter_build_files():
            relative_path = file_path.relative_to(SCRIPT_DIR).as_posix()
            archive.write(file_path, relative_path)
            file_count += 1

    if file_count == 0:
        raise RuntimeError(f"No build files found in {SCRIPT_DIR}")

    return file_count


def push_archive(zip_path: Path) -> None:
    target = f"{ITCH_USER}/{ITCH_GAME}:{BUILD_CHANNEL}"
    print(f"Pushing zipped build to itch.io channel '{BUILD_CHANNEL}'...")

    result = subprocess.run(["butler", "push", str(zip_path), target], check=False)
    if result.returncode != 0:
        raise RuntimeError("Failed to push zip to itch.io. Check your credentials and paths.")


def send_discord_webhook(file_count: int) -> None:
    payload = {
        "content": (
            f"New itch.io build pushed for {ITCH_USER}/{ITCH_GAME}:{BUILD_CHANNEL} "
            f"with {file_count} files."
        )
    }
    data = json.dumps(payload).encode("utf-8")
    webhook_request = request.Request(
        DISCORD_WEBHOOK_URL,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with request.urlopen(webhook_request) as response:
            if response.status >= 400:
                raise RuntimeError(f"Discord webhook returned HTTP {response.status}")
    except error.HTTPError as exc:
        raise RuntimeError(f"Discord webhook failed with HTTP {exc.code}") from exc
    except error.URLError as exc:
        raise RuntimeError(f"Discord webhook failed: {exc.reason}") from exc


def main() -> int:
    ensure_butler_installed()

    fd, temp_name = tempfile.mkstemp(
        prefix=f"{ITCH_GAME}-build-",
        suffix=".zip",
        dir=str(PROJECT_DIR),
    )
    os.close(fd)
    zip_path = Path(temp_name)

    try:
        print(f"Creating temporary zip from {SCRIPT_DIR}...")
        file_count = create_archive(zip_path)
        print(f"Created temporary zip with {file_count} files: {zip_path}")

        push_archive(zip_path)
        send_discord_webhook(file_count)
        print("Discord webhook sent.")
        print("Successfully pushed zip to itch.io!")
        return 0
    finally:
        if zip_path.exists():
            zip_path.unlink()
            print(f"Removed temporary zip: {zip_path}")


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(exc, file=sys.stderr)
        raise SystemExit(1)
