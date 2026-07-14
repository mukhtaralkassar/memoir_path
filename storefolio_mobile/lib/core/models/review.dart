class Review {
  final int id;
  final int productId;
  final String? customerName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final bool? isApproved;

  Review({
    required this.id,
    required this.productId,
    this.customerName,
    required this.rating,
    this.comment,
    this.createdAt,
    this.isApproved,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? json['product_id'] ?? 0,
      customerName: json['customerName'] ?? json['customer_name'],
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null,
      isApproved: json['isApproved'] ?? json['is_approved'],
    );
  }
}
