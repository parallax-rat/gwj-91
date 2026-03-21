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

# Must match your page: https://<ITCH_USER>.itch.io/<ITCH_GAME> (path segment after /, lower-case).
# Override without editing: set env ITCH_USER and ITCH_GAME before running.
ITCH_USER_DEFAULT = "parallaxrat"
ITCH_GAME_DEFAULT = "viralhelix"
HTML_CHANNEL = "html"
WINDOWS_CHANNEL = "windows"
MAC_CHANNEL = "mac"
LINUX_CHANNEL = "linux"
DISCORD_WEBHOOK_URL = (
    "https://discord.com/api/webhooks/1483654934053257366/"
    "y2triNS9vCdd4_EUOptmaDAZS6wBGRJHTmrl3Zt3AGRsFzjw0eszWjXYUN7LluDfhwFM"
)

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent
WEB_BUILD_DIR = SCRIPT_DIR / "web"
WINDOWS_ZIP_LEGACY = SCRIPT_DIR / "viral_helix.zip"
EXCLUDED_DIR_NAMES = {"__pycache__"}


def ensure_butler_installed() -> None:
    if shutil.which("butler") is None:
        raise RuntimeError("Butler not found. Please install butler from https://itch.io/app")


def iter_web_build_files():
    for root, dir_names, file_names in os.walk(WEB_BUILD_DIR):
        dir_names[:] = sorted(name for name in dir_names if name not in EXCLUDED_DIR_NAMES)
        root_path = Path(root)

        for file_name in sorted(file_names):
            yield (root_path / file_name).resolve()


def create_archive(zip_path: Path) -> int:
    file_count = 0

    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as archive:
        for file_path in iter_web_build_files():
            relative_path = file_path.relative_to(WEB_BUILD_DIR).as_posix()
            archive.write(file_path, relative_path)
            file_count += 1

    if file_count == 0:
        raise RuntimeError(f"No build files found in {WEB_BUILD_DIR}")

    return file_count


def itch_credentials() -> tuple[str, str]:
    user = os.environ.get("ITCH_USER", ITCH_USER_DEFAULT).strip()
    game = os.environ.get("ITCH_GAME", ITCH_GAME_DEFAULT).strip()
    if not user or not game:
        raise RuntimeError("ITCH_USER and ITCH_GAME (or defaults) must be non-empty.")
    return user, game


def push_archive(zip_path: Path, channel: str) -> None:
    itch_user, itch_game = itch_credentials()
    target = f"{itch_user}/{itch_game}:{channel}"
    print(f"Pushing to itch.io channel '{channel}' (target {target})...")

    result = subprocess.run(
        ["butler", "push", str(zip_path), target],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or "").strip()
        hint = (
            "Butler reported a failure. If you see 'invalid game', the slug is wrong or your "
            "account cannot upload to that page: open your game on itch.io and copy the URL — "
            "then set ITCH_USER and ITCH_GAME to match, or edit ITCH_*_DEFAULT in this script."
        )
        if detail:
            raise RuntimeError(f"{detail}\n\n{hint}")
        raise RuntimeError(
            f"Butler exited with code {result.returncode} for {target}.\n\n{hint}"
        )


def first_existing_file(*candidates: Path) -> Path | None:
    for path in candidates:
        if path.is_file():
            return path
    return None


def resolve_windows_zip() -> Path | None:
    """Godot / Explorer may use `viral_helix_windows.zip` or extensionless `viral_helix_windows`."""
    return first_existing_file(
        SCRIPT_DIR / "viral_helix_windows.zip",
        SCRIPT_DIR / "viral_helix_windows",
        WINDOWS_ZIP_LEGACY,
    )


def resolve_mac_zip() -> Path | None:
    return first_existing_file(
        SCRIPT_DIR / "viral_helix_mac.zip",
        SCRIPT_DIR / "viral_helix_mac",
    )


def resolve_linux_zip() -> Path | None:
    return first_existing_file(
        SCRIPT_DIR / "viral_helix_linux.zip",
        SCRIPT_DIR / "viral_helix_linux",
    )


def send_discord_webhook(parts: list[str]) -> bool:
    itch_user, itch_game = itch_credentials()
    summary = ", ".join(parts)
    payload = {
        "content": f"New itch.io builds pushed for {itch_user}/{itch_game}: {summary}."
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
                print(
                    f"Warning: Discord webhook returned HTTP {response.status} (itch push already completed).",
                    file=sys.stderr,
                )
                return False
    except error.HTTPError as exc:
        print(
            f"Warning: Discord webhook failed with HTTP {exc.code} (itch push already completed).",
            file=sys.stderr,
        )
        return False
    except error.URLError as exc:
        print(
            f"Warning: Discord webhook failed: {exc.reason} (itch push already completed).",
            file=sys.stderr,
        )
        return False
    print("Discord webhook sent.")
    return True


def main() -> int:
    ensure_butler_installed()

    if not WEB_BUILD_DIR.is_dir():
        raise RuntimeError(f"Web build directory not found: {WEB_BUILD_DIR}")

    _, itch_game_slug = itch_credentials()

    fd, temp_name = tempfile.mkstemp(
        prefix=f"{itch_game_slug}-build-",
        suffix=".zip",
        dir=str(PROJECT_DIR),
    )
    os.close(fd)
    zip_path = Path(temp_name)

    try:
        print(f"Creating temporary zip from {WEB_BUILD_DIR} for channel '{HTML_CHANNEL}'...")
        file_count = create_archive(zip_path)
        print(f"Created temporary zip with {file_count} files: {zip_path}")

        discord_parts: list[str] = []

        push_archive(zip_path, HTML_CHANNEL)
        discord_parts.append(f"{HTML_CHANNEL} ({file_count} files in zip)")

        win_zip = resolve_windows_zip()
        if win_zip is not None:
            push_archive(win_zip, WINDOWS_CHANNEL)
            discord_parts.append(f"{WINDOWS_CHANNEL} ({win_zip.name})")
        else:
            print(
                f"Skipping '{WINDOWS_CHANNEL}': expected viral_helix_windows.zip, "
                f"viral_helix_windows, or {WINDOWS_ZIP_LEGACY.name} under {SCRIPT_DIR}",
                file=sys.stderr,
            )

        mac_zip = resolve_mac_zip()
        if mac_zip is not None:
            push_archive(mac_zip, MAC_CHANNEL)
            discord_parts.append(f"{MAC_CHANNEL} ({mac_zip.name})")
        else:
            print(
                f"Skipping '{MAC_CHANNEL}': expected viral_helix_mac.zip or viral_helix_mac under {SCRIPT_DIR}",
                file=sys.stderr,
            )

        linux_zip = resolve_linux_zip()
        if linux_zip is not None:
            push_archive(linux_zip, LINUX_CHANNEL)
            discord_parts.append(f"{LINUX_CHANNEL} ({linux_zip.name})")
        else:
            print(
                f"Skipping '{LINUX_CHANNEL}': expected viral_helix_linux.zip or viral_helix_linux under {SCRIPT_DIR}",
                file=sys.stderr,
            )

        send_discord_webhook(discord_parts)
        print("Successfully pushed itch.io build(s).")
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
