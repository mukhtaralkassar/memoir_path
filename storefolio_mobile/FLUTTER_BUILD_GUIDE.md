# دليل بناء تطبيق Flutter لكل متجر

## نبذة عن التطبيق

`storefolio_mobile` هو **template Flutter أبيض-ملصق (white-label)**. كل نسخة منه مربوطة بمتجر واحد على منصة Storefolio.

الفكرة: عندما يطلب زبون تطبيقاً خاصاً بمتجره، ننسخ هذا النموذج لمسار جديد (مثلاً `storefolio_mobile_alwaha`)، نعدّل اسم التطبيق والأيقونة ومعرّف الحزمة، ثم نبني AAB ونرفعه على Google Play.

## المتطلبات

- Flutter SDK (مثبت وموجود على PATH)
- Android SDK
- JDK 17 أو أحدث
- Python 3.10+ (لاستخدام أداة البناء التلقائية)
- Pillow اختيارياً لتوليد أيقونات بكل المقاسات

## هيكل المشروع

```
storefolio_mobile/
├── android/              ← إعدادات Android (gradle, manifest, icons)
├── ios/                  ← إعدادات iOS (placeholder — غير جاهز بعد)
├── lib/
│   ├── core/
│   │   ├── api/
│   │   │   ├── dio_client.dart       ← إعدادات Dio + language header
│   │   │   └── storefolio_api.dart   ← جميع استدعاءات الـ API
│   │   ├── constants/
│   │   │   └── app_constants.dart    ← BASE_URL, STORE_NAME, app name
│   │   ├── models/
│   │   │   ├── store.dart
│   │   │   ├── product.dart
│   │   │   ├── category.dart
│   │   │   └── ...
│   │   ├── providers/
│   │   │   └── store_provider.dart   ← Riverpod providers
│   │   └── navigation/
│   │       └── app_router.dart       ← go_router setup
│   └── features/
│       ├── splash/
│       │   └── splash_screen.dart
│       ├── store_detail/
│       │   └── store_detail_screen.dart
│       └── store_expired/
│           └── store_expired_screen.dart
├── assets/images/        ← شعار المتجر وأيقونة التطبيق
├── pubspec.yaml
└── tools/
    ├── storefolio_build.py  ← أداة بناء تلقائية لكل متجر
    └── README.md            ← شرح أداة البناء
```

## كيف التطبيق يجيب معلومات المتجر

القيم الأساسية (`STORE_NAME` و `BASE_URL`) تُمرّر وقت البناء عن طريق `--dart-define`. عند التشغيل، التطبيق يستدعي:

| Endpoint | الغرض |
|----------|-------|
| `GET /api/shop/store/{STORE_NAME}` | إعدادات المتجر (الاسم، الألوان، الشعار، هل الاشتراك منتهي) |
| `GET /api/shop/products?storeName={STORE_NAME}` | قائمة المنتجات |
| `GET /api/shop/categories?storeName={STORE_NAME}` | الفئات |
| `GET /api/shop/offers?storeName={STORE_NAME}` | العروض |

إذا رجع الاستدعاء الأول HTTP 403 مع `{ "isExpired": true }`، التطبيق ينتقل إلى `StoreExpiredScreen`.

### مثال استجابة `/api/shop/store/test-store`

```json
{
  "storeName": "test-store",
  "displayName": "Test Store",
  "displayNameEn": "Test Store",
  "description": null,
  "logoUrl": null,
  "themeColor": "#0d6efd",
  "backgroundColor": "#f8f9fa",
  "fontColor": "#212529",
  "cardBackgroundColor": "#ffffff",
  "cardShape": "style-1",
  "viewMode": "grid",
  "imageAspectRatio": "1/1",
  "imageObjectFit": "cover",
  "imageBorderRadius": 8,
  "imageShowBorder": false,
  "imageZoomOnHover": true,
  "socialMediaPosition": "Footer",
  "whatsAppNumber": null,
  "phoneNumber": null,
  "instagramUrl": null,
  "facebookUrl": null,
  "storeType": "General",
  "hasDelivery": false,
  "deliveryFee": null,
  "showDamascusTime": false,
  "whatsAppLang": "Auto",
  "whatsAppMessage": null,
  "isExpired": false,
  "isRetail": true,
  "isWholesale": true,
  "currencySymbol": "SYP",
  "androidApp": null
}
```

## إعدادات البناء (Build-time Configuration)

لا تُعدّل الملفات يدوياً داخل `lib/core/constants/app_constants.dart` إلا إذا كان لازماً. القيم تُغطّى عبر `--dart-define`:

| Dart Define | الوصف | مثال |
|-------------|-------|------|
| `STORE_NAME` | slug المتجر | `test-store` |
| `BASE_URL` | رابط السيرفر | `https://storefolio.devminds.dev` |

## أوامر البناء

### بناء تجريبي محلي

```bash
flutter build appbundle --release \
  --dart-define=STORE_NAME=test-store \
  --dart-define=BASE_URL=http://localhost:5100
```

### بناء إنتاجي

```bash
flutter build appbundle --release \
  --dart-define=STORE_NAME=my-store \
  --dart-define=BASE_URL=https://storefolio.devminds.dev
```

النتيجة:
```
build/app/outputs/bundle/release/app-release.aab
```

## البناء بمشروع منفصل عن النموذج

الأداة `tools/storefolio_build.py` تأخذ نسخة من المشروع الحالي وتضعها بمجلد مؤقت (temp directory)، ثم تعدّل:

- bundle id داخل `android/app/build.gradle.kts`
- اسم التطبيق داخل `AndroidManifest.xml`
- أيقونة التطبيق بكل مقاسات `mipmap-*`
- قيم `STORE_NAME` و `BASE_URL` عبر `--dart-define`

ثم تشغّل `flutter build appbundle` داخل المجلد المنسوخ.

### مثال

```bash
python3 tools/storefolio_build.py \
  --store-name test-store \
  --app-name "Test Store" \
  --app-name-ar "متجر تجريبي" \
  --app-name-en "Test Store" \
  --bundle-id com.storefolio.devminds.teststore \
  --base-url http://localhost:5100 \
  --output /tmp/storefolio_test_build \
  --logo-url file:///tmp/test_icon.png
```

المخرجات:
```
/tmp/storefolio_test_build/
  ├── test-store.aab
  └── metadata.json
```

> **ملاحظة:** الأداة تنسخ المشروع لمسار جديد أثناء البناء؛ النموذج الأصلي `storefolio_mobile` يبقى كما هو.

لشرح تفصيلي أكثر للأداة، راجع `tools/README.md`.

## الشاشات الرئيسية

### SplashScreen
- أول شاشة تظهر.
- تستدعي `/api/shop/store/{STORE_NAME}`.
- إذا نجحت → `StoreDetailScreen`.
- إذا فشلت بـ 403 expired → `StoreExpiredScreen`.

### StoreDetailScreen
- تعرض المنتجات والفئات والعروض.
- تستخدم ألوان المتجر القادمة من الـ API.

### StoreExpiredScreen
- تظهر عند انتهاء اشتراك المتجر.
- لا تسمح بتصفح المنتجات.

## iOS (placeholder)

iOS غير مدعوم رسمياً حالياً. الملفات موجودة لكنها تحتاج:

- Apple Developer Account ($99/سنة)
- Xcode على macOS
- App Store Connect setup
- تعديل `ios/Runner/Info.plist` و bundle id
- أيقونات iOS بمقاساتها

## حلول مشاكل شائعة

| المشكلة | الحل |
|---------|------|
| فشل البناء | شغّل `flutter clean` ثم `flutter pub get` |
| API لا يستجيب | تأكد من `BASE_URL` وشغّال السيرفر |
| التطبيق يظهر expired | فحص الاشتراك بالسيرفر (`ExpiryDate`) |
| bundle id غير صالح | يجب أن يحتوي فقط على a-z, 0-9, نقاط و underscores؛ لا شرطات |
| الأيقونة صغيرة | يجب أن تكون مربعة PNG 512×512 على الأقل |

## روابط مفيدة

- [README الخاص بأداة البناء](tools/README.md)
- [دليل رفع AAB على Google Play Console](https://support.google.com/googleplay/android-developer/answer/9842757)
