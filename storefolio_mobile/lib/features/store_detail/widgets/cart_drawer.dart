import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/store_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/price_formatter.dart';

class CartDrawer extends ConsumerWidget {
  final String storeName;

  const CartDrawer({super.key, required this.storeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider(storeName));
    final storeAsync = ref.watch(storeConfigProvider(storeName));

    return storeAsync.when(
      data: (store) {
        final primaryColor = AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);
        final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);
        final cardColor = AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor);
        final currency = ref.watch(selectedCurrencyProvider);
        final locale = ref.watch(localeProvider);
        final total = cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('السلة', style: AppTheme.heading3.copyWith(color: fontColor)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (cart.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: fontColor.withAlpha(77),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'السلة فارغة',
                        style: AppTheme.subtitle1.copyWith(color: fontColor.withAlpha(179)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أضف منتجات من المتجر',
                        style: AppTheme.body2.copyWith(color: fontColor.withAlpha(153)),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: item.image != null
                            ? Image.network(item.image!, width: 40, height: 40, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(item.name, style: TextStyle(color: fontColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          'x${item.quantity} - ${PriceFormatter.format(item.price * item.quantity, currency: currency, locale: locale.languageCode)}',
                          style: TextStyle(color: fontColor.withAlpha(153)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref.read(cartProvider(storeName).notifier).removeItem(
                            item.productId,
                            attributes: item.selectedAttributes,
                            isWholesale: item.isWholesale,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              if (cart.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المجموع:', style: AppTheme.heading3.copyWith(color: fontColor)),
                    Text(
                      PriceFormatter.format(total, currency: currency, locale: locale.languageCode),
                      style: AppTheme.price.copyWith(color: primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final items = cart.map((item) => {
                        'productId': item.productId,
                        'name': item.name,
                        'price': item.price,
                        'quantity': item.quantity,
                        'attributes': item.selectedAttributes,
                        'image': item.image,
                      }).toList();
                      context.go('/store/$storeName/whatsapp', extra: {
                        'store': store,
                        'items': items,
                      });
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('إتمام الطلب عبر واتساب'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('خطأ في تحميل المتجر')),
    );
  }
}
