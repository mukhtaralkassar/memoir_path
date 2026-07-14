import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/offer.dart';
import '../models/review.dart';
import '../models/order.dart';

class StorefolioApi {
  final Dio _dio;

  StorefolioApi(this._dio);

  // Stores
  Future<List<Store>> getStores() async {
    try {
      final response = await _dio.get('/shop/stores');
      return (response.data as List).map((e) => Store.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load stores: $e');
    }
  }

  Future<Store> getStore(String storeName) async {
    try {
      final response = await _dio.get('/shop/store/$storeName');
      return Store.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Products
  Future<ProductResponse> getProducts(
    String storeName, {
    String? search,
    int? page,
    int? pageSize,
    String? sort,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? wholesale,
  }) async {
    try {
      final response = await _dio.get('/shop/products', queryParameters: {
        'storeName': storeName,
        if (search != null) 'search': search,
        if (page != null) 'page': page,
        if (sort != null) 'sort': sort,
        if (categoryId != null) 'categoryId': categoryId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (wholesale != null) 'wholesale': wholesale,
      });
      return ProductResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProduct(int id, {required String storeName}) async {
    try {
      final response = await _dio.get('/shop/product/$id', queryParameters: {
        'storeName': storeName,
      });
      return Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  Future<void> trackProductView(Map<String, dynamic> body) async {
    try {
      await _dio.post('/shop/product/view', data: body);
    } catch (e) {
      // Silently fail for tracking
    }
  }

  Future<void> trackProductOrder(Map<String, dynamic> body) async {
    try {
      await _dio.post('/shop/product/order', data: body);
    } catch (e) {
      // Silently fail for tracking
    }
  }

  // Categories
  Future<List<Category>> getCategories(String storeName) async {
    try {
      final response = await _dio.get('/shop/categories', queryParameters: {
        'storeName': storeName,
      });
      return (response.data as List).map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Offers
  Future<List<Offer>> getOffers(String storeName) async {
    try {
      final response = await _dio.get('/shop/offers', queryParameters: {
        'storeName': storeName,
      });
      return (response.data as List).map((e) => Offer.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Reviews
  Future<List<Review>> getReviews(int productId) async {
    try {
      final response = await _dio.get('/shop/reviews', queryParameters: {
        'productId': productId,
      });
      return (response.data as List).map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<Review> createReview(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post('/shop/reviews', data: body);
      return Review.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Search Suggestions
  Future<List<String>> getSearchSuggestions(String storeName, String query) async {
    try {
      final response = await _dio.get('/shop/suggest', queryParameters: {
        'storeName': storeName,
        'q': query,
      });
      return (response.data as List).map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // Orders
  Future<Order> createOrder(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post('/shop/create-order', data: body);
      return Order.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

class ProductResponse {
  final List<Product> products;
  final bool hasMore;
  final int totalCount;

  ProductResponse({
    required this.products,
    required this.hasMore,
    required this.totalCount,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final items = json['items'] ?? json['products'] ?? [];
    final totalCount = json['totalCount'] ?? json['total'] ?? 0;
    final hasMore = json['hasMore'] ?? false;

    return ProductResponse(
      products: (items as List?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }
}
