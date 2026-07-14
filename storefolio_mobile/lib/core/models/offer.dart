class Offer {
  final int id;
  final String storeName;
  final String? titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final String? link;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;

  Offer({
    required this.id,
    required this.storeName,
    this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    this.link,
    this.type,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] ?? 0,
      storeName: json['storeName'] ?? json['store_name'] ?? '',
      titleAr: json['titleAr'] ?? json['title_ar'],
      titleEn: json['titleEn'] ?? json['title_en'],
      descriptionAr: json['descriptionAr'] ?? json['description_ar'],
      descriptionEn: json['descriptionEn'] ?? json['description_en'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      link: json['link'],
      type: json['type'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'].toString()) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'].toString()) : null,
      isActive: json['isActive'] ?? json['is_active'],
    );
  }
}
