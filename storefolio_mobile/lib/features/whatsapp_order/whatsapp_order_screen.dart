import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/store.dart';
import '../../core/models/cart_item.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/currency_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/price_formatter.dart';

class WhatsAppOrderScreen extends ConsumerStatefulWidget {
  final String storeName;
  final Store store;
  final List<Map<String, dynamic>> items;

  const WhatsAppOrderScreen({
    super.key,
    required this.storeName,
    required this.store,
    required this.items,
  });

  @override
  ConsumerState<WhatsAppOrderScreen> createState() => _WhatsAppOrderScreenState();
}

class _WhatsAppOrderScreenState extends ConsumerState<WhatsAppOrderScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final cartItems = _mapItemsToCartItems();
    final isWholesale = cartItems.isNotEmpty && cartItems.first.isWholesale;
    final storeAsync = ref.watch(storeConfigProvider(widget.storeName));

    final currency = ref.watch(selectedCurrencyProvider);
    final locale = ref.watch(localeProvider);

    return storeAsync.when(
      data: (store) {
        final total = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
        final deliveryFee = store.hasDelivery == true && store.deliveryFee != null && store.deliveryFee! > 0
            ? store.deliveryFee
            : null;
        final message = WhatsAppService.generateOrderMessage(
          currency: currency,
          locale: locale.languageCode,
          store: store,
          items: cartItems,
          deliveryFee: deliveryFee,
          customTemplate: store.whatsAppMessage,
          storeLink: store.storeName,
          isWholesale: isWholesale,
        );

        final backgroundColor = AppTheme.parseHexColor(store.backgroundColor, AppTheme.backgroundColor);
        final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);
        final primaryColor = AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);
        final cardColor = AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text('تأكيد الطلب'),
            centerTitle: true,
            backgroundColor: primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ملخص الطلب', style: AppTheme.heading2.copyWith(color: fontColor)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        color: cardColor,
                        child: ListTile(
                          leading: ClipRRect(
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
                          title: Text(item.name, style: TextStyle(color: fontColor)),
                          subtitle: Text(
                            'الكمية: ${item.quantity}',
                            style: TextStyle(color: fontColor.withAlpha(179)),
                          ),
                          trailing: Text(
                            PriceFormatter.format(item.price * item.quantity, currency: currency, locale: locale.languageCode),
                            style: AppTheme.price.copyWith(color: primaryColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المجموع:', style: AppTheme.heading3.copyWith(color: fontColor)),
                    Text(
                      PriceFormatter.format(total, currency: currency, locale: locale.languageCode),
                      style: AppTheme.price.copyWith(fontSize: 22, color: primaryColor),
                    ),
                  ],
                ),
                if (deliveryFee != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('التوصيل:', style: AppTheme.body2.copyWith(color: fontColor)),
                      Text(
                        PriceFormatter.format(deliveryFee, currency: currency, locale: locale.languageCode),
                        style: AppTheme.body1.copyWith(color: fontColor),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي:', style: AppTheme.heading3.copyWith(color: fontColor)),
                      Text(
                        PriceFormatter.format(total + deliveryFee, currency: currency, locale: locale.languageCode),
                        style: AppTheme.price.copyWith(fontSize: 22, color: primaryColor),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : () => _sendOrder(store, cartItems, message),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSubmitting ? 'جاري الإرسال...' : 'إرسال الطلب عبر واتساب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: AppTheme.caption.copyWith(color: fontColor),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('تأكيد الطلب')),
        body: const Center(child: Text('خطأ في تحميل المتجر')),
      ),
    );
  }

  List<CartItem> _mapItemsToCartItems() {
    return widget.items.map((item) {
      return CartItem(
        productId: item['productId'] as int? ?? 0,
        storeName: widget.storeName,
        name: item['name'] as String? ?? '',
        price: item['price'] != null ? double.parse(item['price'].toString()) : 0.0,
        image: item['image'] as String?,
        quantity: item['quantity'] as int? ?? 1,
        selectedAttributes: item['attributes'] as String?,
      );
    }).toList();
  }

  Future<void> _sendOrder(Store store, List<CartItem> cartItems, String message) async {
    setState(() => _isSubmitting = true);
    try {
      final api = ref.read(apiProvider);
      final total = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
      final deliveryFee = store.hasDelivery == true && store.deliveryFee != null && store.deliveryFee! > 0
          ? store.deliveryFee
          : null;

      await api.createOrder({
        'storeId': store.id,
        'totalAmount': total,
        'deliveryFee': deliveryFee,
        'whatsAppMessage': message,
        'isWholesale': cartItems.isNotEmpty && cartItems.first.isWholesale,
        'items': cartItems.map((item) => {
          'productId': item.productId,
          'productName': item.name,
          'quantity': item.quantity,
          'unitPrice': item.price,
          'attributesJson': item.selectedAttributes,
          'imageUrl': item.image,
        }).toList(),
      });

      final success = await WhatsAppService.openWhatsApp(
        phone: store.whatsapp ?? store.phone ?? '',
        message: message,
      );

      if (success && context.mounted) {
        await ref.read(cartProvider(widget.storeName).notifier).clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
        );
        if (context.mounted) context.go('/store/${widget.storeName}');
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح واتساب. تأكد من تثبيت التطبيق.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الطلب: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
