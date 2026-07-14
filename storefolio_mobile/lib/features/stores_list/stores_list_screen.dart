import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/store.dart';

// TODO: Replace with actual API provider
final storesListProvider = FutureProvider<List<Store>>((ref) async {
  // This will be replaced with actual API call
  return _getMockStores();
});

List<Store> _getMockStores() {
  return [
    Store(
      storeName: 'test-store',
      displayName: 'متجر تجريبي',
      displayNameEn: 'Test Store',
      description: 'هذا متجر تجريبي لاختبار التطبيق',
      descriptionEn: 'This is a test store',
      logoUrl: 'https://via.placeholder.com/150',
      phone: '+963912345678',
      whatsapp: '+963912345678',
      primaryColor: '#1B5E20',
      secondaryColor: '#388E3C',
      isRetail: true,
      currency: 'SYP',
    ),
  ];
}

class StoresListScreen extends ConsumerWidget {
  const StoresListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر'),
        centerTitle: true,
      ),
      body: storesAsync.when(
        data: (stores) => _buildStoresList(context, ref, stores),
        loading: () => _buildLoadingShimmer(),
        error: (error, stack) => _buildErrorWidget(context, ref, error),
      ),
    );
  }

  Widget _buildStoresList(BuildContext context, WidgetRef ref, List<Store> stores) {
    if (stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد متاجر متاحة حالياً',
              style: AppTheme.subtitle1.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(storesListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return _StoreCard(store: store);
        },
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل المتاجر',
            style: AppTheme.subtitle1.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTheme.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(storesListProvider);
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Store store;

  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/store/${store.storeName}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Store Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: store.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          store.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.store, size: 40, color: Colors.grey[400]),
                        ),
                      )
                    : Icon(Icons.store, size: 40, color: Colors.grey[400]),
              ),
              const SizedBox(width: 16),
              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.displayName,
                      style: AppTheme.subtitle1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (store.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        store.description!,
                        style: AppTheme.body2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (store.isRetail == true)
                          _buildBadge('تجزئة', AppTheme.primaryColor),
                        if (store.isWholesale == true) ...[
                          const SizedBox(width: 8),
                          _buildBadge('جملة', AppTheme.secondaryColor),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
