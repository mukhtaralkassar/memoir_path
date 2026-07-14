class AppConstants {
  // API
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://storefolio.devminds.dev',
  );
  static const String apiBaseUrl = '$baseUrl/api';
  static const String shopBaseUrl = '$baseUrl/Shop';

  // App Info
  static const String appName = 'Storefolio';
  static const String packageName = 'com.devminds.storefolio';

  // Default store for this white-label app (set at build time via dart-define)
  static const String defaultStoreName = String.fromEnvironment(
    'STORE_NAME',
    defaultValue: 'test-store',
  );

  // Cache
  static const String hiveBoxName = 'storefolio_cache';
  static const String cartBoxName = 'storefolio_cart';
  static const Duration cacheDuration = Duration(hours: 24);

  // Pagination
  static const int defaultPageSize = 20;

  // WhatsApp
  static const String whatsappApiUrl = 'https://wa.me';

  // Languages
  static const String defaultLanguage = 'ar';
  static const List<String> supportedLanguages = ['ar', 'en'];
}
