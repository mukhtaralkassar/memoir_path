import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/dio_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/store.dart';
import '../../core/providers/api_provider.dart';
import '../store_expired/store_expired_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final storeName = AppConstants.defaultStoreName;
    final api = ref.read(apiProvider);

    try {
      final store = await api.getStore(storeName);
      if (store.isExpired == true) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => StoreExpiredScreen(store: store),
            ),
          );
        }
        return;
      }
      if (mounted) {
        context.go('/store/$storeName');
      }
    } catch (e) {
      if (DioClient.isExpiredStoreError(e)) {
        final expiredStore = Store(
          storeName: storeName,
          displayName: storeName,
          isExpired: true,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => StoreExpiredScreen(store: expiredStore),
            ),
          );
        }
        return;
      }

      if (mounted) {
        context.go('/store/$storeName');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/storefolio_logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.store, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
