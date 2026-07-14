class CartItem {
  final int productId;
  final String storeName;
  final int quantity;
  final String? selectedAttributes;
  final String? notes;
  final DateTime? addedAt;

  CartItem({
    required this.productId,
    required this.storeName,
    required this.quantity,
    this.selectedAttributes,
    this.notes,
    this.addedAt,
  });

  CartItem copyWith({
    int? productId,
    String? storeName,
    int? quantity,
    String? selectedAttributes,
    String? notes,
    DateTime? addedAt,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      storeName: storeName ?? this.storeName,
      quantity: quantity ?? this.quantity,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? 0,
      storeName: json['storeName'] ?? '',
      quantity: json['quantity'] ?? 1,
      selectedAttributes: json['selectedAttributes'],
      notes: json['notes'],
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'storeName': storeName,
      'quantity': quantity,
      'selectedAttributes': selectedAttributes,
      'notes': notes,
      'addedAt': addedAt?.toIso8601String(),
    };
  }
}
