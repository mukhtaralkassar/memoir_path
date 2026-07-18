import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// Firebase Analytics wrapper for storefolio template.
///
/// All logging methods are safe to call even when Firebase is not configured.
class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static bool _available = false;

  static Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      if (!kIsWeb) {
        await _analytics!.setAnalyticsCollectionEnabled(true);
      }
      _available = true;
    } catch (e) {
      debugPrint('AnalyticsService: Firebase Analytics not available: $e');
      _available = false;
    }
  }

  static bool get isAvailable => _available;

  static FirebaseAnalytics? get analytics => _analytics;

  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_available || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: _sanitize(name),
        parameters: _sanitizeParameters(parameters ?? {}),
      );
    } catch (_) {}
  }

  static Future<void> viewStore(String storeName) async {
    await logEvent(
      name: 'view_store',
      parameters: {'store_name': storeName},
    );
  }

  static String _productName(Product product) {
    return product.displayNameAr ??
        product.displayNameEn ??
        'unknown';
  }

  static Future<void> viewProduct(Product product, String storeName) async {
    await logEvent(
      name: 'view_product',
      parameters: {
        'store_name': storeName,
        'product_id': product.id,
        'product_name': _productName(product),
        'price': product.price ?? 0.0,
      },
    );
  }

  static Future<void> addToCart({
    required Product product,
    required String storeName,
    required int quantity,
    required bool isWholesale,
    double? price,
  }) async {
    await logEvent(
      name: 'add_to_cart',
      parameters: {
        'store_name': storeName,
        'product_id': product.id,
        'product_name': _productName(product),
        'quantity': quantity,
        'is_wholesale': isWholesale,
        'price': price ?? product.price ?? 0.0,
      },
    );
  }

  static Future<void> removeFromCart({
    required int productId,
    required String storeName,
  }) async {
    await logEvent(
      name: 'remove_from_cart',
      parameters: {
        'store_name': storeName,
        'product_id': productId,
      },
    );
  }

  static Future<void> beginCheckout({
    required String storeName,
    required double total,
    required String currency,
    required int itemCount,
  }) async {
    await logEvent(
      name: 'begin_checkout',
      parameters: {
        'store_name': storeName,
        'value': total,
        'currency': currency,
        'item_count': itemCount,
      },
    );
  }

  static Future<void> placeOrder({
    required String storeName,
    required double total,
    required String currency,
    required int itemCount,
  }) async {
    await logEvent(
      name: 'place_order',
      parameters: {
        'store_name': storeName,
        'value': total,
        'currency': currency,
        'item_count': itemCount,
      },
    );
  }

  static Future<void> setUserCurrency(String currency) async {
    if (!_available || _analytics == null) return;
    try {
      await _analytics!.setUserProperty(
        name: 'selected_currency',
        value: currency,
      );
    } catch (_) {}
  }

  static Future<void> setUserLanguage(String languageCode) async {
    if (!_available || _analytics == null) return;
    try {
      await _analytics!.setUserProperty(
        name: 'app_language',
        value: languageCode,
      );
    } catch (_) {}
  }

  static String _sanitize(String name) {
    // Firebase event names must be 1-40 chars, only alphanumeric and underscores.
    final sanitized = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (sanitized.length > 40) {
      return sanitized.substring(0, 40);
    }
    return sanitized;
  }

  static Map<String, Object> _sanitizeParameters(Map<String, Object> params) {
    final result = <String, Object>{};
    params.forEach((key, value) {
      final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final trimmedKey = safeKey.length > 40 ? safeKey.substring(0, 40) : safeKey;
      if (value is String || value is num || value is bool) {
        result[trimmedKey] = value;
      } else {
        result[trimmedKey] = value.toString();
      }
    });
    return result;
  }
}
