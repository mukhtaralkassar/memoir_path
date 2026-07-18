class CartItem {
  final int productId;
  final String storeName;
  final String name;
  final double price;
  final String? image;
  final int quantity;
  final bool isWholesale;
  final String? selectedAttributes;
  final String? notes;
  final DateTime? addedAt;

  CartItem({
    required this.productId,
    required this.storeName,
    required this.name,
    required this.price,
    this.image,
    required this.quantity,
    this.isWholesale = false,
    this.selectedAttributes,
    this.notes,
    this.addedAt,
  });

  CartItem copyWith({
    int? productId,
    String? storeName,
    String? name,
    double? price,
    String? image,
    int? quantity,
    bool? isWholesale,
    String? selectedAttributes,
    String? notes,
    DateTime? addedAt,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      storeName: storeName ?? this.storeName,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      isWholesale: isWholesale ?? this.isWholesale,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? 0,
      storeName: json['storeName'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      image: json['image'],
      quantity: json['quantity'] ?? 1,
      isWholesale: json['isWholesale'] ?? false,
      selectedAttributes: json['selectedAttributes'],
      notes: json['notes'],
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'storeName': storeName,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
      'isWholesale': isWholesale,
      'selectedAttributes': selectedAttributes,
      'notes': notes,
      'addedAt': addedAt?.toIso8601String(),
    };
  }
}
