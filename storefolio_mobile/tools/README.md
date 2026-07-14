# Storefolio Mobile Build Tool

This directory contains scripts to generate per-store Android apps from the
Storefolio Flutter template.

## Usage

```bash
python3 tools/storefolio_build.py \
  --store-name test-store \
  --app-name "Test Store" \
  --app-name-ar "متجر التجربة" \
  --app-name-en "Test Store" \
  --bundle-id com.storefolio.devminds.test-store \
  --logo-url https://storefolio.devminds.dev/uploads/icon.png \
  --base-url https://storefolio.devminds.dev \
  --output ./builds/test-store
```

## Important flags

- `--store-name`: Store slug used by the API (`/api/shop/store/{slug}`).
- `--app-name` / `--app-name-ar`: Android app label.
- `--app-name-en`: Used to derive a safe bundle-id suffix when `--bundle-id` is omitted.
- `--bundle-id`: Must be unique per app on Google Play.
- `--base-url`: Storefolio backend URL. The AAB will call `$BASE_URL/api`.
- `--logo-url`: Square PNG (512×512 or larger). It becomes the launcher icon.
- `--output`: Directory for the resulting `*.aab` and `metadata.json`.

## Prerequisites

- Flutter SDK installed and on PATH
- Android SDK configured for release App Bundles
- Python 3.10+
- Pillow (optional; used to generate launcher icons at multiple densities)
- For Google Play publishing: a service account JSON key with Play Console Admin access

## Outputs

The script produces:

- `{store-name}.aab` — Android App Bundle ready for Google Play
- `metadata.json` — store/bundle metadata including slug, bundle id, and backend URL

## How it works

The tool copies the Flutter project to a temporary directory, patches the
Android bundle id/label, generates launcher icons, and runs
`flutter build appbundle` with dart-define values for `STORE_NAME` and
`BASE_URL`. No source files in the original repository are modified.

## Local server test build

```bash
python3 tools/storefolio_build.py \
  --store-name test-store \
  --app-name "Test Store" \
  --app-name-ar "متجر تجريبي" \
  --base-url http://localhost:5100 \
  --logo-url file:///tmp/test_icon.png \
  --output /tmp/storefolio_test_build
```

## Google Play Integration

Google Play API integration is handled on the Storefolio server (see
`Storefolio/Services/GooglePlayService.cs`). The build tool only produces the
AAB; upload/publish the AAB through the Storefolio dashboard once Google Play
API credentials are configured.
