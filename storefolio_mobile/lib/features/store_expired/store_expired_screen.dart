import 'package:flutter/material.dart';

import '../../core/models/store.dart';
import '../../core/theme/app_theme.dart';

class StoreExpiredScreen extends StatelessWidget {
  final Store store;

  const StoreExpiredScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final displayName = store.displayNameEn ?? store.displayName ?? store.storeName;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (store.logoUrl != null)
              Image.network(
                store.logoUrl!,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.store_mall_directory, size: 80, color: Colors.grey),
              )
            else
              const Icon(Icons.store_mall_directory, size: 80, color: Colors.grey),
            const SizedBox(height: 32),
            Text(
              displayName,
              style: AppTheme.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'تم إيقاف المتجر مؤقتاً.\nيرجى تجديد الاشتراك للمتابعة.',
              style: AppTheme.subtitle1.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Store subscription expired. Please renew to continue.',
              style: AppTheme.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Nothing to do; app is blocked until backend renews.
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
