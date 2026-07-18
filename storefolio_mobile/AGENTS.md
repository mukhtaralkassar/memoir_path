# AGENTS.md — storefolio_mobile

Compact guidance for OpenCode sessions working on the Storefolio Flutter white-label template.

## What this repo is

- A Flutter **white-label template** that produces one Android app per store.
- Each store is selected at build time via `--dart-define=STORE_NAME=<slug>`.
- The production backend defaults to `https://storefolio.devminds.dev`; override with `--dart-define=BASE_URL=<url>`.
- iOS/macOS files are placeholders and are not officially supported.

## Must-know commands

```bash
# Run / debug locally against the default backend and test store
flutter run --dart-define=STORE_NAME=test-store --dart-define=BASE_URL=https://storefolio.devminds.dev

# Build release AAB for a real store (standard output path)
flutter build appbundle --release \
  --dart-define=STORE_NAME=<store-slug> \
  --dart-define=BASE_URL=https://storefolio.devminds.dev
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Automated per-store build

Use the build tool to copy, patch bundle id/app name/icons, and build in a temp directory without modifying the template.

```bash
python3 tools/storefolio_build.py \
  --store-name <slug> \
  --app-name "<English app name>" \
  --app-name-ar "<Arabic app name>" \
  --app-name-en "<English app name>" \
  --bundle-id com.storefolio.devminds.<slug> \
  --base-url https://storefolio.devminds.dev \
  --logo-url <square PNG URL or file:///path> \
  --output ./builds/<slug>
```

Produces `{store-name}.aab` and `metadata.json`. The original repo is not modified.

### Verification

```bash
flutter analyze
flutter test
```

## Architecture notes

- `lib/main.dart` bootstraps Riverpod `ProviderScope` and `StorefolioApp`.
- `lib/app.dart` builds the `MaterialApp.router`, loads the active store via `storeConfigProvider(storeName)`, and switches the theme based on server colors.
- `lib/core/navigation/app_router.dart` uses `go_router`; initial route is `/splash`, then the app navigates to `/store/:storeName` or the expired screen.
- `lib/core/api/dio_client.dart` sets `baseUrl = $BASE_URL/api` and sends `Accept-Language` dynamically from `DioContext.locale`.
- `lib/core/providers/store_provider.dart` exposes Riverpod providers tied to the active store slug.
- `lib/core/providers/currency_provider.dart` exposes server-driven `storeCurrenciesProvider` and `selectedCurrencyProvider`.
- `lib/core/providers/locale_provider.dart` persists language and updates `DioContext.locale` on change.
- Default store slug and backend come from `String.fromEnvironment` in `lib/core/constants/app_constants.dart`. Prefer passing `--dart-define` over editing that file.
- Firebase Core/Analytics/Messaging are wired in `lib/main.dart` and fail gracefully if `google-services.json` is absent.
- `tools/storefolio_build.py` accepts `--google-services-json` for per-store Firebase configs.

## API / runtime quirks

- Splash fetches `GET /api/shop/store/{STORE_NAME}`.
- If that call returns HTTP 403 with `{ "isExpired": true }`, the app shows `StoreExpiredScreen`.
- Other endpoints include `/api/shop/products`, `/api/shop/categories`, and `/api/shop/offers`, all scoped by `storeName`.
- Hive is used for cart/cache; boxes are named in `app_constants.dart`.

## Build constraints

- Android `applicationId` defaults to `com.devminds.storefolio`; the build tool rewrites it per store.
- Release signing currently uses the debug keystore (`build.gradle.kts`), so release builds work locally without a custom signing config. Do not ship that as production signing.
- Bundle ids must contain only `a-z`, `0-9`, dots, and underscores (no dashes).
- Launcher icons should be square PNGs, 512×512 or larger.
- iOS is not production-ready; do not commit to iOS builds without explicit setup.

## Troubleshooting

| Symptom | Quick fix |
|---------|-----------|
| Build fails | `flutter clean && flutter pub get` |
| API does not respond | Verify `BASE_URL` and backend server state |
| App shows expired screen | Check subscription / `ExpiryDate` on backend |
| Analyzer/lint issues | `flutter analyze`; lints come from `package:flutter_lints/flutter.yaml` |

## Related docs

- `FLUTTER_BUILD_GUIDE.md` — full Arabic build guide.
- `tools/README.md` — detailed build tool usage.
- `tools/storefolio_build.py` — the actual build script (preferred source of truth for build behavior).
