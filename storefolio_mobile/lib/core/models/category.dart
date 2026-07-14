class Category {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? description;
  final String? icon;
  final int? sortOrder;
  final int? parentId;
  final bool? isActive;

  Category({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.description,
    this.icon,
    this.sortOrder,
    this.parentId,
    this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'] ?? json['name_ar'] ?? json['name'] ?? '',
      nameEn: json['nameEn'] ?? json['name_en'],
      description: json['description'],
      icon: json['icon'],
      sortOrder: json['sortOrder'] ?? json['sort_order'],
      parentId: json['parentId'] ?? json['parent_id'],
      isActive: json['isActive'] ?? json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'description': description,
      'icon': icon,
      'sortOrder': sortOrder,
      'parentId': parentId,
      'isActive': isActive,
    };
  }
}
