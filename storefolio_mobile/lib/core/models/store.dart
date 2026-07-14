import 'dart:convert';

class Store {
  final String storeName;
  final String displayName;
  final String? displayNameEn;
  final String? description;
  final String? descriptionEn;
  final String? logoUrl;
  final String? bannerUrl;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String? primaryColor;
  final String? secondaryColor;
  final String? accentColor;
  final String? fontFamily;
  final String? backgroundImage;
  final String? backgroundColor;
  final String? themeColor;
  final bool? isRetail;
  final bool? isWholesale;
  final String? currency;
  final String? currencySymbol;
  final double? deliveryFee;
  final bool? deliveryAvailable;
  final bool? pickupAvailable;
  final String? socialFacebook;
  final String? socialInstagram;
  final String? socialTiktok;
  final String? seoTitle;
  final String? seoDescription;
  final String? imageAspectRatio;
  final String? imageObjectFit;
  final double? imageBorderRadius;
  final bool? imageShowBorder;
  final bool? imageZoomOnHover;
  final String? productCardStyle;
  final bool? showPrices;
  final bool? showSearch;
  final bool? showCategories;
  final bool? showReviews;
  final bool? showOffers;
  final bool? showAds;
  final String? theme;
  final bool? isExpired;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Store({
    required this.storeName,
    required this.displayName,
    this.displayNameEn,
    this.description,
    this.descriptionEn,
    this.logoUrl,
    this.bannerUrl,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.fontFamily,
    this.backgroundImage,
    this.backgroundColor,
    this.themeColor,
    this.isRetail,
    this.isWholesale,
    this.currency,
    this.currencySymbol,
    this.deliveryFee,
    this.deliveryAvailable,
    this.pickupAvailable,
    this.socialFacebook,
    this.socialInstagram,
    this.socialTiktok,
    this.seoTitle,
    this.seoDescription,
    this.imageAspectRatio,
    this.imageObjectFit,
    this.imageBorderRadius,
    this.imageShowBorder,
    this.imageZoomOnHover,
    this.productCardStyle,
    this.showPrices,
    this.showSearch,
    this.showCategories,
    this.showReviews,
    this.showOffers,
    this.showAds,
    this.theme,
    this.isExpired,
    this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeName: json['storeName'] ?? json['store_name'] ?? '',
      displayName: json['displayName'] ?? json['display_name'] ?? '',
      displayNameEn: json['displayNameEn'] ?? json['display_name_en'],
      description: json['description'],
      descriptionEn: json['descriptionEn'] ?? json['description_en'],
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      bannerUrl: json['bannerUrl'] ?? json['banner_url'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      address: json['address'],
      primaryColor: json['primaryColor'] ?? json['primary_color'],
      secondaryColor: json['secondaryColor'] ?? json['secondary_color'],
      accentColor: json['accentColor'] ?? json['accent_color'],
      fontFamily: json['fontFamily'] ?? json['font_family'],
      backgroundImage: json['backgroundImage'] ?? json['background_image'],
      backgroundColor: json['backgroundColor'] ?? json['background_color'],
      themeColor: json['themeColor'] ?? json['theme_color'],
      isRetail: json['isRetail'] ?? json['is_retail'],
      isWholesale: json['isWholesale'] ?? json['is_wholesale'],
      currency: json['currency'],
      currencySymbol: json['currencySymbol'] ?? json['currency_symbol'] ?? json['currency'],
      deliveryFee: json['deliveryFee'] != null ? double.parse(json['deliveryFee'].toString()) : null,
      deliveryAvailable: json['deliveryAvailable'] ?? json['delivery_available'],
      pickupAvailable: json['pickupAvailable'] ?? json['pickup_available'],
      socialFacebook: json['socialFacebook'] ?? json['social_facebook'],
      socialInstagram: json['socialInstagram'] ?? json['social_instagram'],
      socialTiktok: json['socialTiktok'] ?? json['social_tiktok'],
      seoTitle: json['seoTitle'] ?? json['seo_title'],
      seoDescription: json['seoDescription'] ?? json['seo_description'],
      imageAspectRatio: json['imageAspectRatio'] ?? json['image_aspect_ratio'],
      imageObjectFit: json['imageObjectFit'] ?? json['image_object_fit'],
      imageBorderRadius: json['imageBorderRadius'] != null ? double.parse(json['imageBorderRadius'].toString()) : null,
      imageShowBorder: json['imageShowBorder'] ?? json['image_show_border'],
      imageZoomOnHover: json['imageZoomOnHover'] ?? json['image_zoom_on_hover'],
      productCardStyle: json['productCardStyle'] ?? json['product_card_style'] ?? 'style-1',
      showPrices: json['showPrices'] ?? json['show_prices'],
      showSearch: json['showSearch'] ?? json['show_search'] ?? true,
      showCategories: json['showCategories'] ?? json['show_categories'] ?? true,
      showReviews: json['showReviews'] ?? json['show_reviews'],
      showOffers: json['showOffers'] ?? json['show_offers'],
      showAds: json['showAds'] ?? json['show_ads'],
      theme: json['theme'],
      isExpired: json['isExpired'] ?? json['is_expired'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'displayName': displayName,
      'displayNameEn': displayNameEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'address': address,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'fontFamily': fontFamily,
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor,
      'themeColor': themeColor,
      'isRetail': isRetail,
      'isWholesale': isWholesale,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'deliveryFee': deliveryFee,
      'deliveryAvailable': deliveryAvailable,
      'pickupAvailable': pickupAvailable,
      'socialFacebook': socialFacebook,
      'socialInstagram': socialInstagram,
      'socialTiktok': socialTiktok,
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'imageAspectRatio': imageAspectRatio,
      'imageObjectFit': imageObjectFit,
      'imageBorderRadius': imageBorderRadius,
      'imageShowBorder': imageShowBorder,
      'imageZoomOnHover': imageZoomOnHover,
      'productCardStyle': productCardStyle,
      'showPrices': showPrices,
      'showSearch': showSearch,
      'showCategories': showCategories,
      'showReviews': showReviews,
      'showOffers': showOffers,
      'showAds': showAds,
      'theme': theme,
      'isExpired': isExpired,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
