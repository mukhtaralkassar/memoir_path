import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/cart_item.dart';
import '../../core/models/store.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/currency_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/price_formatter.dart';

class CartScreen extends ConsumerWidget {
  final String? storeName;

  const CartScreen({super.key, this.storeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeStore = storeName ?? ref.watch(activeStoreNameProvider);
    if (activeStore == null || activeStore.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('اسم المتجر غير محدد')),
      );
    }
    final cartAsync = ref.watch(cartProvider(activeStore));
    final storeAsync = ref.watch(storeConfigProvider(activeStore));
    final isWholesale = ref.watch(wholesaleModeProvider);

    return storeAsync.when(
      data: (store) {
        final backgroundColor = AppTheme.parseHexColor(store.backgroundColor, AppTheme.backgroundColor);
        final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);
        final primaryColor = AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);
        final cardColor = AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text('سلة التسوق'),
            centerTitle: true,
            backgroundColor: primaryColor,
          ),
          body: cartAsync.isEmpty
              ? _buildEmptyCart(context, fontColor)
              : _buildCartList(context, ref, cartAsync, store, primaryColor, fontColor, cardColor, isWholesale),
          bottomNavigationBar: cartAsync.isEmpty
              ? null
              : _buildBottomBar(context, ref, cartAsync, store, primaryColor, isWholesale),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('سلة التسوق')),
        body: const Center(child: Text('خطأ في تحميل المتجر')),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, Color fontColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: fontColor.withAlpha(77),
          ),
          const SizedBox(height: 24),
          Text(
            'السلة فارغة',
            style: AppTheme.heading3.copyWith(color: fontColor.withAlpha(179)),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ التسوق وأضف منتجاتك المفضلة',
            style: AppTheme.body2.copyWith(color: fontColor.withAlpha(153)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/store/${storeName ?? ''}'),
            icon: const Icon(Icons.store),
            label: const Text('تصفح المتجر'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, WidgetRef ref, List<CartItem> items, Store store, Color primaryColor, Color fontColor, Color cardColor, bool isWholesale) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.image ?? 'https://via.placeholder.com/60',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTheme.subtitle1.copyWith(color: fontColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.selectedAttributes != null)
                        Text(
                          item.selectedAttributes!,
                          style: AppTheme.caption.copyWith(color: fontColor.withAlpha(153)),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        PriceFormatter.format(item.price, currency: ref.watch(selectedCurrencyProvider), locale: ref.watch(localeProvider).languageCode),
                        style: AppTheme.price.copyWith(color: primaryColor),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => ref.read(cartProvider(store.storeName).notifier).updateQuantity(
                        item.productId,
                        item.quantity - 1,
                        attributes: item.selectedAttributes,
                        isWholesale: item.isWholesale,
                      ),
                    ),
                    Text('${item.quantity}', style: TextStyle(color: fontColor)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => ref.read(cartProvider(store.storeName).notifier).updateQuantity(
                        item.productId,
                        item.quantity + 1,
                        attributes: item.selectedAttributes,
                        isWholesale: item.isWholesale,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref.read(cartProvider(store.storeName).notifier).removeItem(
                        item.productId,
                        attributes: item.selectedAttributes,
                        isWholesale: item.isWholesale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildBottomBar(BuildContext context, WidgetRef ref, List<CartItem> items, Store store, Color primaryColor, bool isWholesale) {
    final currency = ref.watch(selectedCurrencyProvider);
    final locale = ref.watch(localeProvider);
    final total = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final mapItems = items.map((item) => {
      'productId': item.productId,
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
      'attributes': item.selectedAttributes,
      'image': item.image,
    }).toList();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المجموع:',
                    style: AppTheme.body2,
                  ),
                  Text(
                    PriceFormatter.format(total, currency: currency, locale: locale.languageCode),
                    style: AppTheme.price.copyWith(fontSize: 20, color: primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/store/${store.storeName}/whatsapp', extra: {
                  'store': store,
                  'items': mapItems,
                }),
                icon: const Icon(Icons.message),
                label: const Text('إتمام الطلب عبر واتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
