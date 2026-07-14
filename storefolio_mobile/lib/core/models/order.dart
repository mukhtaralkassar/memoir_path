class Order {
  final int id;
  final String storeName;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double totalAmount;
  final double? deliveryFee;
  final String? status;
  final String? whatsappMessage;
  final bool? isWholesale;
  final List<OrderItem>? items;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.storeName,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.totalAmount,
    this.deliveryFee,
    this.status,
    this.whatsappMessage,
    this.isWholesale,
    this.items,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      storeName: json['storeName'] ?? json['store_name'] ?? '',
      customerName: json['customerName'] ?? json['customer_name'],
      customerPhone: json['customerPhone'] ?? json['customer_phone'],
      customerAddress: json['customerAddress'] ?? json['customer_address'],
      totalAmount: double.parse(json['totalAmount']?.toString() ?? '0'),
      deliveryFee: json['deliveryFee'] != null ? double.parse(json['deliveryFee'].toString()) : null,
      status: json['status'],
      whatsappMessage: json['whatsappMessage'] ?? json['whatsapp_message'],
      isWholesale: json['isWholesale'] ?? json['is_wholesale'],
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null,
    );
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String? attributesJson;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.attributesJson,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? json['product_id'] ?? 0,
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: double.parse(json['unitPrice']?.toString() ?? json['unit_price']?.toString() ?? '0'),
      attributesJson: json['attributesJson'] ?? json['attributes_json'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
    );
  }
}
