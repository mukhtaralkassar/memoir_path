import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../api/storefolio_api.dart';
import '../constants/app_constants.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/offer.dart';
import 'api_provider.dart';

/// Holds the active store for this white-label app.
/// The default value comes from dart-define (STORE_NAME) and can be
/// overridden at runtime if needed (e.g. deep-link fallback).
final activeStoreNameProvider = StateProvider<String>((ref) {
  return AppConstants.defaultStoreName;
});

/// API instance.
final _apiProvider = Provider<StorefolioApi>((ref) {
  final dio = ref.watch(dioProvider);
  return StorefolioApi(dio);
});

/// Fetches the current store configuration from the server.
/// If the subscription is expired, the future will complete with a
/// DioException carrying isExpired=true so the UI can render the
/// StoreExpiredScreen.
final storeConfigProvider = FutureProvider.family<Store, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  return await api.getStore(storeName);
});

/// Fetches products for the active store.
final storeProductsProvider = FutureProvider.family<ProductResponse, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  return await api.getProducts(
    storeName,
    page: 1,
    pageSize: 50,
    sort: 'newest',
  );
});

/// Fetches categories for the active store.
final storeCategoriesProvider = FutureProvider.family<List<Category>, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  return await api.getCategories(storeName);
});

/// Fetches active offers for the active store.
final storeOffersProvider = FutureProvider.family<List<Offer>, String>((ref, storeName) async {
  final api = ref.watch(_apiProvider);
  return await api.getOffers(storeName);
});
