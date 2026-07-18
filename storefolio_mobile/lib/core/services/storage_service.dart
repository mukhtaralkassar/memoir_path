import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/category.dart';

class StorageService {
  static StorageService? _instance;
  late Box<String> _cartBox;
  late Box<String> _cacheBox;
  late Box<dynamic> _settingsBox;

  static Future<StorageService> get instance async {
    _instance ??= StorageService();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    await Hive.initFlutter();
    
    _cartBox = await Hive.openBox<String>(AppConstants.cartBoxName);
    _cacheBox = await Hive.openBox<String>(AppConstants.hiveBoxName);
    _settingsBox = await Hive.openBox('${AppConstants.hiveBoxName}_settings');
  }

  // Cart Operations
  Future<void> addToCart(CartItem item) async {
    final key = '${item.storeName}_${item.productId}';
    await _cartBox.put(key, jsonEncode(item.toJson()));
  }

  Future<void> removeFromCart(String storeName, int productId) async {
    await _cartBox.delete('${storeName}_$productId');
  }

  Future<void> updateCartItem(CartItem item) async {
    final key = '${item.storeName}_${item.productId}';
    await _cartBox.put(key, jsonEncode(item.toJson()));
  }

  Future<void> clearCart(String storeName) async {
    final keysToDelete = _cartBox.keys.where(
      (key) => key.toString().startsWith('${storeName}_'),
    ).toList();
    await _cartBox.deleteAll(keysToDelete);
  }

  List<CartItem> getCartItems(String storeName) {
    return _cartBox.values
        .map((jsonStr) => CartItem.fromJson(jsonDecode(jsonStr)))
        .where((item) => item.storeName == storeName)
        .toList();
  }

  List<CartItem> getAllCartItems() {
    return _cartBox.values
        .map((jsonStr) => CartItem.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> clearAllCart() async {
    await _cartBox.clear();
  }

  // Settings
  Future<void> setLanguage(String language) async {
    await _settingsBox.put('language', language);
  }

  String getLanguage() {
    return _settingsBox.get('language', defaultValue: AppConstants.defaultLanguage);
  }

  Future<void> setCurrency(String currency) async {
    await _settingsBox.put('currency', currency);
  }

  String? getCurrency() {
    return _settingsBox.get('currency');
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await _settingsBox.put('darkMode', isDarkMode);
  }

  bool getDarkMode() {
    return _settingsBox.get('darkMode', defaultValue: false);
  }

  Future<void> setStoreColors(Map<String, dynamic> colors) async {
    await _settingsBox.put('storeColors', colors);
  }

  Map<String, dynamic>? getStoreColors() {
    return _settingsBox.get('storeColors');
  }

  // Wholesale / Retail Mode
  static const String _wholesaleModeKey = 'wholesale_mode';

  Future<void> setWholesaleMode(bool isWholesale) async {
    await _settingsBox.put(_wholesaleModeKey, isWholesale);
  }

  bool getWholesaleMode() {
    return _settingsBox.get(_wholesaleModeKey, defaultValue: false);
  }

  // Cache Operations
  Future<void> cacheStoreConfig(String storeName, Store store) async {
    await _cacheBox.put('store_$storeName', jsonEncode(store.toJson()));
    await _cacheBox.put('store_${storeName}_time', DateTime.now().toIso8601String());
  }

  Store? getCachedStoreConfig(String storeName) {
    final jsonStr = _cacheBox.get('store_$storeName');
    if (jsonStr == null) return null;
    try {
      return Store.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  bool isStoreConfigCacheValid(String storeName) {
    final timeStr = _cacheBox.get('store_${storeName}_time');
    if (timeStr == null) return false;
    final cachedTime = DateTime.tryParse(timeStr);
    if (cachedTime == null) return false;
    return DateTime.now().difference(cachedTime) < AppConstants.cacheDuration;
  }

  Future<void> cacheProducts(String storeName, List<Product> products, {bool wholesale = false}) async {
    final key = 'products_${storeName}_${wholesale ? 'wholesale' : 'retail'}';
    await _cacheBox.put(key, jsonEncode(products.map((p) => p.toJson()).toList()));
    await _cacheBox.put('${key}_time', DateTime.now().toIso8601String());
  }

  List<Product> getCachedProducts(String storeName, {bool wholesale = false}) {
    final key = 'products_${storeName}_${wholesale ? 'wholesale' : 'retail'}';
    final jsonStr = _cacheBox.get(key);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  bool isProductsCacheValid(String storeName, {bool wholesale = false}) {
    final key = 'products_${storeName}_${wholesale ? 'wholesale' : 'retail'}';
    final timeStr = _cacheBox.get('${key}_time');
    if (timeStr == null) return false;
    final cachedTime = DateTime.tryParse(timeStr);
    if (cachedTime == null) return false;
    return DateTime.now().difference(cachedTime) < const Duration(hours: 1);
  }

  Future<void> cacheCategories(String storeName, List<Category> categories) async {
    final key = 'categories_$storeName';
    await _cacheBox.put(key, jsonEncode(categories.map((c) => c.toJson()).toList()));
    await _cacheBox.put('${key}_time', DateTime.now().toIso8601String());
  }

  List<Category> getCachedCategories(String storeName) {
    final key = 'categories_$storeName';
    final jsonStr = _cacheBox.get(key);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  bool isCategoriesCacheValid(String storeName) {
    final key = 'categories_$storeName';
    final timeStr = _cacheBox.get('${key}_time');
    if (timeStr == null) return false;
    final cachedTime = DateTime.tryParse(timeStr);
    if (cachedTime == null) return false;
    return DateTime.now().difference(cachedTime) < AppConstants.cacheDuration;
  }

  Future<void> clearAllCache() async {
    await _cacheBox.clear();
  }
}
