#!/usr/bin/env python3
"""
Storefolio Mobile White-Label Build Tool

Generates a per-store Android App Bundle (AAB) from the Storefolio Flutter
template. The resulting project is placed in a temporary directory, built,
and the AAB/metadata are copied to the requested output directory.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def slugify(name: str) -> str:
    """Convert any store name into a safe Android bundle-id suffix."""
    name = name.lower().strip()
    name = re.sub(r"[^a-z0-9]", "", name)
    return name or "store"


def run(cmd: list[str], cwd: Path, env: dict | None = None, timeout: int = 600) -> None:
    print(f"$ {' '.join(cmd)}")
    subprocess.run(cmd, cwd=cwd, env=env, check=True, timeout=timeout)


def patch_file(path: Path, replacements: dict[str, str]) -> None:
    text = path.read_text(encoding="utf-8")
    for old, new in replacements.items():
        text = text.replace(old, new)
    path.write_text(text, encoding="utf-8")


def download_icon(url: str, dest: Path) -> None:
    import urllib.request

    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=60) as response:
        dest.write_bytes(response.read())


def generate_icons(source_icon: Path, res_dir: Path) -> None:
    """Generate Android launcher icons in all mipmap densities."""
    try:
        from PIL import Image
    except ImportError:
        print("Pillow not installed; copying single icon only.")
        for density in ["mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"]:
            target_dir = res_dir / f"mipmap-{density}"
            target_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy(source_icon, target_dir / "ic_launcher.png")
        return

    img = Image.open(source_icon).convert("RGBA")
    sizes = {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }
    for density, size in sizes.items():
        target_dir = res_dir / f"mipmap-{density}"
        target_dir.mkdir(parents=True, exist_ok=True)
        resized = img.resize((size, size), Image.LANCZOS)
        resized.save(target_dir / "ic_launcher.png")


def build_store_app(args: argparse.Namespace) -> Path:
    store_name = args.store_name
    app_name = args.app_name
    app_name_ar = args.app_name_ar or app_name
    bundle_id = args.bundle_id or f"com.storefolio.devminds.{slugify(args.app_name_en or app_name)}"
    base_url = args.base_url or "https://storefolio.devminds.dev"

    output_dir = Path(args.output).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="storefolio_build_") as tmp:
        work_dir = Path(tmp) / "storefolio_mobile"
        print(f"Copying template to {work_dir}...")
        shutil.copytree(ROOT, work_dir, ignore=shutil.ignore_patterns(
            "build", ".dart_tool", ".idea", ".git", "tools", "test"
        ))

        android_dir = work_dir / "android" / "app" / "src" / "main"
        res_dir = android_dir / "res"

        # 1. Patch Android bundle id and app name
        build_gradle = work_dir / "android" / "app" / "build.gradle.kts"
        patch_file(build_gradle, {
            'applicationId = "com.devminds.storefolio"': f'applicationId = "{bundle_id}"',
        })

        manifest = android_dir / "AndroidManifest.xml"
        patch_file(manifest, {
            'android:label="storefolio"': f'android:label="{app_name_ar}"',
        })

        # 2. Patch iOS/macOS app name and bundle id (best-effort)
        for plist in [
            work_dir / "ios" / "Runner" / "Info.plist",
            work_dir / "macos" / "Runner" / "Configs" / "AppInfo.xcconfig",
        ]:
            if plist.exists():
                patch_file(plist, {
                    "com.devminds.storefolio": bundle_id,
                    "Storefolio": app_name,
                })

        # 3. Patch default store name in dart-define source
        # 4. Download and generate app icon
        if args.logo_url:
            icon_path = work_dir / "assets" / "images" / "store_logo.png"
            icon_path.parent.mkdir(parents=True, exist_ok=True)
            print(f"Downloading icon from {args.logo_url}...")
            download_icon(args.logo_url, icon_path)
            generate_icons(icon_path, res_dir)
            # Also keep a copy for the splash screen
            splash_path = work_dir / "assets" / "images" / "storefolio_logo.png"
            shutil.copy(icon_path, splash_path)

        # 5. Run Flutter build
        print("Building Android App Bundle...")
        flutter_env = os.environ.copy()
        run(
            [
                "flutter", "build", "appbundle", "--release",
                "--dart-define", f"STORE_NAME={store_name}",
                "--dart-define", f"BASE_URL={base_url}",
            ],
            cwd=work_dir,
            env=flutter_env,
        )

        aab_source = work_dir / "build" / "app" / "outputs" / "bundle" / "release" / "app-release.aab"
        aab_dest = output_dir / f"{store_name}.aab"
        shutil.copy(aab_source, aab_dest)

        metadata = {
            "storeName": store_name,
            "appName": app_name,
            "appNameAr": app_name_ar,
            "bundleId": bundle_id,
            "baseUrl": base_url,
            "logoUrl": args.logo_url,
            "aabPath": str(aab_dest),
        }
        (output_dir / "metadata.json").write_text(json.dumps(metadata, indent=2, ensure_ascii=False))

        print(f"Build complete: {aab_dest}")
        return aab_dest


def main() -> int:
    parser = argparse.ArgumentParser(description="Build a Storefolio Android app for a specific store.")
    parser.add_argument("--store-name", required=True, help="Store slug used in API calls")
    parser.add_argument("--app-name", required=True, help="Default/English app name")
    parser.add_argument("--app-name-ar", default=None, help="Arabic app name (Android label)")
    parser.add_argument("--app-name-en", default=None, help="English app name used to derive bundle id")
    parser.add_argument("--bundle-id", default=None, help="Android bundle id, e.g. com.storefolio.devminds.storename")
    parser.add_argument("--logo-url", default=None, help="URL to a square PNG icon (512x512+)")
    parser.add_argument("--base-url", default=None, help="Storefolio backend base URL")
    parser.add_argument("--output", required=True, help="Directory to place the AAB and metadata")
    parser.add_argument("--publish", default=None, choices=["internal", "closed", "production"], help="Publish track (requires Google Play setup)")

    args = parser.parse_args()

    try:
        aab = build_store_app(args)
        if args.publish:
            print(f"Publishing to {args.publish} is not implemented in this version.")
            print("Use the Storefolio dashboard or Google Play Console to upload the AAB.")
        return 0
    except Exception as e:
        print(f"Build failed: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
