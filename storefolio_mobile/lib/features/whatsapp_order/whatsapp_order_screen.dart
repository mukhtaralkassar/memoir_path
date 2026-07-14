import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/models/product.dart';
import '../../core/models/store.dart';

class WhatsAppOrderScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final total = items.fold(0.0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));
    final message = WhatsAppService.generateOrderMessage(
      storeName: store.displayName,
      items: items,
      total: total,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الطلب'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص الطلب', style: AppTheme.heading2),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['image'] ?? 'https://via.placeholder.com/60',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(item['name']),
                      subtitle: Text('الكمية: ${item['quantity']}'),
                      trailing: Text(
                        '${(item['price'] * item['quantity']).toStringAsFixed(0)} ${store.currency}',
                        style: AppTheme.price,
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
                Text('المجموع:', style: AppTheme.heading3),
                Text(
                  '${total.toStringAsFixed(0)} ${store.currency}',
                  style: AppTheme.price.copyWith(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendOrder(context, message),
                icon: const Icon(Icons.send),
                label: const Text('إرسال الطلب عبر واتساب'),
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: AppTheme.caption,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOrder(BuildContext context, String message) async {
    final success = await WhatsAppService.openWhatsApp(
      phone: store.whatsapp ?? store.phone ?? '',
      message: message,
    );

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح واتساب. تأكد من تثبيت التطبيق.'),
          ),
        );
      }
    }
  }
}
