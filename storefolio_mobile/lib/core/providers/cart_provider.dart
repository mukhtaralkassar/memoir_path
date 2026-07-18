import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../services/storage_service.dart';

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.instance;
});

final cartProvider = StateNotifierProvider.family<CartNotifier, List<CartItem>, String>(
  (ref, storeName) => CartNotifier(ref, storeName),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref _ref;
  final String storeName;
  StorageService? _storage;

  CartNotifier(this._ref, this.storeName) : super([]) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    _storage = await _ref.read(storageServiceProvider.future);
    state = _storage!.getCartItems(storeName);
  }

  Future<void> addItem({
    required int productId,
    required String name,
    required double price,
    String? image,
    int quantity = 1,
    bool isWholesale = false,
    String? selectedAttributes,
  }) async {
    final existingIndex = state.indexWhere(
      (i) => i.productId == productId && i.selectedAttributes == selectedAttributes && i.isWholesale == isWholesale,
    );

    if (existingIndex >= 0) {
      final updated = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + quantity,
      );
      await _storage?.updateCartItem(updated);
      state = [
        ...state.sublist(0, existingIndex),
        updated,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      final item = CartItem(
        productId: productId,
        storeName: storeName,
        name: name,
        price: price,
        image: image,
        quantity: quantity,
        isWholesale: isWholesale,
        selectedAttributes: selectedAttributes,
        addedAt: DateTime.now(),
      );
      await _storage?.addToCart(item);
      state = [...state, item];
    }
  }

  Future<void> removeItem(int productId, {String? attributes, bool isWholesale = false}) async {
    await _storage?.removeFromCart(storeName, productId);
    state = state.where((i) => !(i.productId == productId && i.selectedAttributes == attributes && i.isWholesale == isWholesale)).toList();
  }

  Future<void> updateQuantity(int productId, int quantity, {bool isWholesale = false, String? attributes}) async {
    if (quantity <= 0) {
      await removeItem(productId, attributes: attributes, isWholesale: isWholesale);
      return;
    }

    final index = state.indexWhere((i) => i.productId == productId && i.selectedAttributes == attributes && i.isWholesale == isWholesale);
    if (index >= 0) {
      final updated = state[index].copyWith(quantity: quantity);
      await _storage?.updateCartItem(updated);
      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
    }
  }

  Future<void> clearCart() async {
    await _storage?.clearCart(storeName);
    state = [];
  }

  double get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => state.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
