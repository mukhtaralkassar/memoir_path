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

  Future<void> addItem(CartItem item) async {
    final existingIndex = state.indexWhere(
      (i) => i.productId == item.productId && i.selectedAttributes == item.selectedAttributes,
    );

    if (existingIndex >= 0) {
      final updated = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + item.quantity,
      );
      await _storage?.updateCartItem(updated);
      state = [
        ...state.sublist(0, existingIndex),
        updated,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      await _storage?.addToCart(item);
      state = [...state, item];
    }
  }

  Future<void> removeItem(int productId, {String? attributes}) async {
    await _storage?.removeFromCart(storeName, productId);
    state = state.where((i) => i.productId != productId).toList();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final index = state.indexWhere((i) => i.productId == productId);
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
}
