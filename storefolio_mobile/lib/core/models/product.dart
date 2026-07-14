import 'dart:convert';

class Product {
  final int id;
  final String? displayNameAr;
  final String? displayNameEn;
  final String? displayDescriptionAr;
  final String? displayDescriptionEn;
  final double? price;
  final double? wholesalePrice;
  final double? discountPrice;
  final int? quantity;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final String? categoryNameAr;
  final String? categoryNameEn;
  final List<String>? images;
  final String? mainImage;
  final bool? isRetailAvailable;
  final bool? isWholesaleAvailable;
  final bool? isFeatured;
  final bool? isNew;
  final bool? isOnSale;
  final int? viewCount;
  final int? orderCount;
  final double? rating;
  final int? reviewCount;
  final String? attributesJson;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    this.displayNameAr,
    this.displayNameEn,
    this.displayDescriptionAr,
    this.displayDescriptionEn,
    this.price,
    this.wholesalePrice,
    this.discountPrice,
    this.quantity,
    this.sku,
    this.barcode,
    this.categoryId,
    this.categoryNameAr,
    this.categoryNameEn,
    this.images,
    this.mainImage,
    this.isRetailAvailable,
    this.isWholesaleAvailable,
    this.isFeatured,
    this.isNew,
    this.isOnSale,
    this.viewCount,
    this.orderCount,
    this.rating,
    this.reviewCount,
    this.attributesJson,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      displayNameAr: json['displayNameAr'] ?? json['display_name_ar'] ?? json['name'],
      displayNameEn: json['displayNameEn'] ?? json['display_name_en'],
      displayDescriptionAr: json['displayDescriptionAr'] ?? json['display_description_ar'] ?? json['description'],
      displayDescriptionEn: json['displayDescriptionEn'] ?? json['display_description_en'],
      price: _parseDouble(json['price']) ?? _parseDouble(json['priceUSD']) ?? _parseDouble(json['PriceUSD']),
      wholesalePrice: _parseDouble(json['wholesalePrice']) ?? _parseDouble(json['wholesalePriceUSD']) ?? _parseDouble(json['WholesalePriceUSD']),
      discountPrice: _parseDouble(json['discountPrice']),
      quantity: json['quantity'],
      sku: json['sku'],
      barcode: json['barcode'],
      categoryId: json['categoryId']?.toString(),
      categoryNameAr: json['categoryNameAr'] ?? json['category_name_ar'] ?? json['CategoryName'] ?? json['categoryName'],
      categoryNameEn: json['categoryNameEn'] ?? json['category_name_en'],
      images: _extractImages(json),
      mainImage: json['mainImage'] ?? json['main_image'] ?? json['image'] ?? json['imagePath'] ?? json['ImagePath'],
      isRetailAvailable: json['isRetailAvailable'] ?? json['is_retail_available'],
      isWholesaleAvailable: json['isWholesaleAvailable'] ?? json['is_wholesale_available'],
      isFeatured: json['isFeatured'] ?? json['is_featured'],
      isNew: json['isNew'] ?? json['is_new'],
      isOnSale: json['isOnSale'] ?? json['is_on_sale'],
      viewCount: json['viewCount'] ?? json['view_count'],
      orderCount: json['orderCount'] ?? json['order_count'],
      rating: json['averageRating'] != null
          ? double.parse(json['averageRating'].toString())
          : json['rating'] != null
              ? double.parse(json['rating'].toString())
              : null,
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? json['ReviewCount'],
      attributesJson: json['attributesJson'] ?? json['attributes_json'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static List<String> _extractImages(Map<String, dynamic> json) {
    if (json['images'] != null) {
      try {
        return List<String>.from(json['images']);
      } catch (_) {}
    }
    if (json['ImagesJson'] != null || json['imagesJson'] != null || json['images_json'] != null) {
      try {
        final raw = json['ImagesJson'] ?? json['imagesJson'] ?? json['images_json'];
        final decoded = jsonDecode(raw.toString());
        if (decoded is List) return List<String>.from(decoded);
      } catch (_) {}
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayNameAr': displayNameAr,
      'displayNameEn': displayNameEn,
      'displayDescriptionAr': displayDescriptionAr,
      'displayDescriptionEn': displayDescriptionEn,
      'price': price,
      'wholesalePrice': wholesalePrice,
      'discountPrice': discountPrice,
      'quantity': quantity,
      'sku': sku,
      'barcode': barcode,
      'categoryId': categoryId,
      'categoryNameAr': categoryNameAr,
      'categoryNameEn': categoryNameEn,
      'images': images,
      'mainImage': mainImage,
      'isRetailAvailable': isRetailAvailable,
      'isWholesaleAvailable': isWholesaleAvailable,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'isOnSale': isOnSale,
      'viewCount': viewCount,
      'orderCount': orderCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'attributesJson': attributesJson,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
