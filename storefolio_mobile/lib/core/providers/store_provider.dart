import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/storefolio_api.dart';
import '../constants/app_constants.dart';
import '../models/store.dart';
import '../models/category.dart';
import '../models/offer.dart';
import '../services/storage_service.dart';
import 'api_provider.dart';

/// Holds the active store for this white-label app.
/// The default value comes from dart-define (STORE_NAME) and can be
/// overridden at runtime if needed (e.g. deep-link fallback).
final activeStoreNameProvider = StateProvider<String>((ref) {
  return AppConstants.defaultStoreName;
});

/// Tracks whether the current session is in wholesale (جملة) mode.
/// This is set from deep links or QR codes and persisted locally.
final wholesaleModeProvider = StateProvider<bool>((ref) {
  return false;
});

/// Storage instance.
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.instance;
});

/// API instance.
final _apiProvider = Provider<StorefolioApi>((ref) {
  final dio = ref.watch(dioProvider);
  return StorefolioApi(dio);
});

/// Current store as an async value. Useful for widgets that need to read
/// store properties without re-fetching a separate provider.
final currentStoreProvider = FutureProvider<Store?>((ref) async {
  final storeName = ref.watch(activeStoreNameProvider);
  return await ref.watch(storeConfigProvider(storeName).future);
});

/// Fetches the current store configuration from the server with cache-first behavior.
/// Returns cached config immediately if available, then refreshes from server in background.
final storeConfigProvider = FutureProvider.family<Store, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  final storage = await ref.watch(storageServiceProvider.future);

  final cached = storage.getCachedStoreConfig(storeName);
  final isValid = storage.isStoreConfigCacheValid(storeName);

  if (cached != null && isValid) {
    // Refresh in background but return cache immediately.
    api.getStore(storeName).then((fresh) {
      storage.cacheStoreConfig(storeName, fresh);
    }).catchError((_) {
      // Ignore background refresh errors; cached data remains usable.
    });
    return cached;
  }

  final fresh = await api.getStore(storeName);
  await storage.cacheStoreConfig(storeName, fresh);
  return fresh;
});

/// Fetches products for the active store with cache-first behavior.
final storeProductsProvider = FutureProvider.family<ProductResponse, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  final storage = await ref.watch(storageServiceProvider.future);
  final isWholesale = ref.watch(wholesaleModeProvider);

  final cached = storage.getCachedProducts(storeName, wholesale: isWholesale);
  final isValid = storage.isProductsCacheValid(storeName, wholesale: isWholesale);

  if (cached.isNotEmpty && isValid) {
    api.getProducts(
      storeName,
      page: 1,
      pageSize: 50,
      sort: 'newest',
      wholesale: isWholesale,
    ).then((fresh) {
      storage.cacheProducts(storeName, fresh.products, wholesale: isWholesale);
    }).catchError((_) {});
    return ProductResponse(
      products: cached,
      hasMore: false,
      totalCount: cached.length,
    );
  }

  final fresh = await api.getProducts(
    storeName,
    page: 1,
    pageSize: 50,
    sort: 'newest',
    wholesale: isWholesale,
  );
  await storage.cacheProducts(storeName, fresh.products, wholesale: isWholesale);
  return fresh;
});

/// Fetches categories for the active store with cache-first behavior.
final storeCategoriesProvider = FutureProvider.family<List<Category>, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  final storage = await ref.watch(storageServiceProvider.future);

  final cached = storage.getCachedCategories(storeName);
  final isValid = storage.isCategoriesCacheValid(storeName);

  if (cached.isNotEmpty && isValid) {
    api.getCategories(storeName).then((fresh) {
      storage.cacheCategories(storeName, fresh);
    }).catchError((_) {});
    return cached;
  }

  final fresh = await api.getCategories(storeName);
  await storage.cacheCategories(storeName, fresh);
  return fresh;
});

/// Fetches active offers for the active store.
final storeOffersProvider = FutureProvider.family<List<Offer>, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  return await api.getOffers(storeName);
});
