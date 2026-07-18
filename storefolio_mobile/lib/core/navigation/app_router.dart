import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/stores_list/stores_list_screen.dart';
import '../../features/store_detail/store_detail_screen.dart';
import '../../features/product_detail/product_detail_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/whatsapp_order/whatsapp_order_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../constants/app_constants.dart';
import '../models/store.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          final uri = state.uri;
          return SplashScreen(deepLinkUri: uri.queryParameters.isEmpty ? null : uri);
        },
      ),
      GoRoute(
        path: '/',
        name: 'stores',
        builder: (context, state) => const StoresListScreen(),
      ),
      GoRoute(
        path: '/store/:storeName',
        name: 'store',
        builder: (context, state) {
          final storeName = state.pathParameters['storeName']!;
          return StoreDetailScreen(storeName: storeName);
        },
      ),
      GoRoute(
        path: '/store/:storeName/product/:productId',
        name: 'product',
        builder: (context, state) {
          final storeName = state.pathParameters['storeName']!;
          final productId = int.parse(state.pathParameters['productId']!);
          return ProductDetailScreen(
            storeName: storeName,
            productId: productId,
          );
        },
      ),
      GoRoute(
        path: '/store/:storeName/whatsapp',
        name: 'whatsapp-order',
        builder: (context, state) {
          final storeName = state.pathParameters['storeName']!;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final store = extra['store'] as Store?;
          final items = extra['items'] as List<Map<String, dynamic>>? ?? [];
          
          return WhatsAppOrderScreen(
            storeName: storeName,
            store: store ?? Store(storeName: storeName, displayName: storeName),
            items: items,
          );
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/store/${AppConstants.defaultStoreName}'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});
