import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              Text('السلة', style: AppTheme.heading3),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // TODO: Show cart items
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: AppTheme.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'السلة فارغة',
                  style: AppTheme.subtitle1.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'أضف منتجات من المتجر',
                  style: AppTheme.body2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: null,
              child: const Text('إتمام الطلب عبر واتساب'),
            ),
          ),
        ],
      ),
    );
  }
}
