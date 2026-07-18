import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/dio_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/store.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/storage_service.dart';
import '../store_expired/store_expired_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final Uri? deepLinkUri;

  const SplashScreen({super.key, this.deepLinkUri});

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
    final uri = widget.deepLinkUri;
    final storeName = _extractStoreName(uri) ?? AppConstants.defaultStoreName;
    final mode = uri?.queryParameters['mode'];
    final isWholesale = mode == 'wholesale';

    // Persist and apply wholesale mode from deep link immediately.
    if (isWholesale) {
      final storage = await StorageService.instance;
      await storage.setWholesaleMode(true);
    }

    ref.read(activeStoreNameProvider.notifier).state = storeName;
    ref.read(wholesaleModeProvider.notifier).state = isWholesale;

    try {
      final store = await ref.read(storeConfigProvider(storeName).future);
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

  String? _extractStoreName(Uri? uri) {
    if (uri == null) return null;
    final path = uri.path.trim();
    if (path.isEmpty || path == '/') return null;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;
    if (segments.first.toLowerCase() == 'store' && segments.length > 1) {
      return segments[1];
    }
    return segments.last;
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
