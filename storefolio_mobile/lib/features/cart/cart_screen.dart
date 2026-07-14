import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        centerTitle: true,
      ),
      body: _buildEmptyCart(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppTheme.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'السلة فارغة',
            style: AppTheme.heading3.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ التسوق وأضف منتجاتك المفضلة',
            style: AppTheme.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.store),
            label: const Text('تصفح المتاجر'),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    return null; // Will be implemented when cart has items
  }
}
