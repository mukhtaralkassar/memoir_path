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

## إعدادات العرض القادمة من السيرفر

كل متجر يتحكم بمظهر تطبيقه من لوحة التحكم (dashboard). القيم التالية تُقرأ من `/api/shop/store/{STORE_NAME}` وتُطبّق فوراً:

| الإعداد | المفتاح | تأثيره |
|---|---|---|
| `themeColor` | لون رئيسي | أزرار و AppBar |
| `backgroundColor` | لون خلفية | Scaffold / خلفية الشاشة |
| `fontColor` | لون الخط | النصوص العامة |
| `cardBackgroundColor` | لون خلفية الكارد | بطاقات المنتجات |
| `cardShape` | شكل الكارد | `style-1` … `style-100` |
| `viewMode` | طريقة العرض | `grid` أو `list` |
| `imageAspectRatio` | نسبة صورة المنتج | `1/1`, `4/3`, `16/9` ... |
| `imageObjectFit` | ملء الصورة | `cover`, `contain`, `fill` |
| `imageBorderRadius` | حدود الصورة | قيمة عددية |
| `imageShowBorder` | إظهار إطار الصورة | `true` / `false` |
| `hasDelivery` | يوجد توصيل | يُحسب في سلة الطلب |
| `deliveryFee` | أجرة التوصيل | تُضاف للمجموع |
| `whatsAppLang` | لغة رسالة الطلب | `Auto`, `Ar`, `En` |
| `whatsAppMessage` | قالب رسالة الطلب | يدعم `{product}`, `{quantity}`, `{price}`, `{store}`, `{link}` |

> **ملاحظة:** التطبيق يحتفظ بنسخة محلية (cache) لإعدادات المتجر والمنتجات والفئات، لكنه يطلب تحديثاً من السيرفر بالخلفية عند كل فتح للتأكد من صحة البيانات.

## وضع المفرق والجملة

التطبيق يدعم متجرين عملائيين:

| الوضع | كيفية الفتح |
|---|---|
| **مفرق (Retail)** | افتراضي دائماً |
| **جملة (Wholesale)** | فقط عبر QR أو Deep Link |

Deep Link للجملة:
```
storefolio://store/{STORE_NAME}?mode=wholesale
```
أو عبر الموقع:
```
https://storefolio.devminds.dev/{STORE_NAME}?mode=wholesale
```

لما المستخدم يمسح QR للجملة:
1. يفتح التطبيق (أو Play Store إذا غير منصّب).
2. يُحفظ وضع الجملة محلياً.
3. يُعرض المتجر بأسعار الجملة.
4. المستخدم يستطيع العودة للمفرق من زر toggle داخل التطبيق، أو بمسح QR/رابط آخر.

## السلة وإرسال الطلب

- السلة تُحفظ محلياً عبر Hive.
- لكل عنصر في السلة: اسم المنتج، السعر، الكمية، الصورة، الخصائص المختارة، وهل هو جملة.
- عند الضغط على "إتمام الطلب عبر واتساب":
  1. يُرسل الطلب للسيرفر `POST /Shop/CreateOrder`.
  2. تُبنى رسالة واتساب مطابقة لقالب الموقع.
  3. يُفتح واتساب برسالة جاهزة.
  4. بعد النجاح تُفرّغ السلة.

## الشاشات الرئيسية

### SplashScreen
- أول شاشة تظهر.
- تستدعي `/api/shop/store/{STORE_NAME}` مع cache-first.
- تدعم Deep Links وتحدد `wholesale` mode.
- إذا نجحت → `StoreDetailScreen`.
- إذا فشلت بـ 403 expired → `StoreExpiredScreen`.

### StoreDetailScreen
- تعرض المنتجات والفئات والعروض.
- تطبق `backgroundColor`, `fontColor`, `cardShape`, `viewMode` من الـ API.
- تدعم تبديل المفرق/الجملة إذا المتجر يدعم كلاهما.

### ProductDetailScreen
- عرض صور المنتج وفق `imageAspectRatio`, `imageObjectFit`, `imageBorderRadius`.
- اختيار الخصائص (attributes) مباشرة من `attributesJson`.
- زر "أضف للسلة" وزر "اطلب عبر واتساب".

### CartScreen
- عرض محتويات السلة مع تعديل الكميات وحذف العناصر.
- حساب المجموع والتوصيل.
- زر إتمام الطلب عبر واتساب.

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
