import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../models/cart_item.dart';

class StorageService {
  static StorageService? _instance;
  late Box<String> _cartBox;
  late Box<dynamic> _settingsBox;

  static Future<StorageService> get instance async {
    _instance ??= StorageService();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    await Hive.initFlutter();
    
    _cartBox = await Hive.openBox<String>(AppConstants.cartBoxName);
    _settingsBox = await Hive.openBox(AppConstants.hiveBoxName);
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
}
