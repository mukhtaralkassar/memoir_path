import 'currency.dart';

class Store {
  final int? id;
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
  final String? fontColor;
  final String? fontFamily;
  final String? backgroundImage;
  final String? backgroundColor;
  final String? cardBackgroundColor;
  final String? modalBackgroundColor;
  final String? themeColor;
  final bool? isRetail;
  final bool? isWholesale;
  final String? currency;
  final String? currencySymbol;
  final List<Currency>? currencies;
  final double? deliveryFee;
  final bool? deliveryAvailable;
  final bool? pickupAvailable;
  final bool? hasDelivery;
  final String? socialFacebook;
  final String? socialInstagram;
  final String? socialTiktok;
  final String? socialMediaPosition;
  final String? whatsAppLang;
  final String? whatsAppMessage;
  final String? seoTitle;
  final String? seoDescription;
  final String? imageAspectRatio;
  final String? imageObjectFit;
  final double? imageBorderRadius;
  final bool? imageShowBorder;
  final bool? imageZoomOnHover;
  final String? cardShape;
  final String? viewMode;
  final String? imageGalleryMode;
  final int? imageGalleryAutoInterval;
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
    this.id,
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
    this.fontColor,
    this.fontFamily,
    this.backgroundImage,
    this.backgroundColor,
    this.cardBackgroundColor,
    this.modalBackgroundColor,
    this.themeColor,
    this.isRetail,
    this.isWholesale,
    this.currency,
    this.currencySymbol,
    this.currencies,
    this.deliveryFee,
    this.deliveryAvailable,
    this.pickupAvailable,
    this.hasDelivery,
    this.socialFacebook,
    this.socialInstagram,
    this.socialTiktok,
    this.socialMediaPosition,
    this.whatsAppLang,
    this.whatsAppMessage,
    this.seoTitle,
    this.seoDescription,
    this.imageAspectRatio,
    this.imageObjectFit,
    this.imageBorderRadius,
    this.imageShowBorder,
    this.imageZoomOnHover,
    this.cardShape,
    this.viewMode,
    this.imageGalleryMode,
    this.imageGalleryAutoInterval,
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
      id: json['id'],
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
      fontColor: json['fontColor'] ?? json['font_color'],
      fontFamily: json['fontFamily'] ?? json['font_family'],
      backgroundImage: json['backgroundImage'] ?? json['background_image'],
      backgroundColor: json['backgroundColor'] ?? json['background_color'],
      cardBackgroundColor: json['cardBackgroundColor'] ?? json['card_background_color'],
      modalBackgroundColor: json['modalBackgroundColor'] ?? json['modal_background_color'],
      themeColor: json['themeColor'] ?? json['theme_color'],
      isRetail: json['isRetail'] ?? json['is_retail'],
      isWholesale: json['isWholesale'] ?? json['is_wholesale'],
      currency: json['currency'],
      currencySymbol: json['currencySymbol'] ?? json['currency_symbol'] ?? json['currency'],
      currencies: _parseCurrencies(json['currencies'] ?? json['Currencies']),
      deliveryFee: json['deliveryFee'] != null ? double.parse(json['deliveryFee'].toString()) : null,
      deliveryAvailable: json['deliveryAvailable'] ?? json['delivery_available'],
      pickupAvailable: json['pickupAvailable'] ?? json['pickup_available'],
      hasDelivery: json['hasDelivery'] ?? json['has_delivery'],
      socialFacebook: json['socialFacebook'] ?? json['social_facebook'] ?? json['facebookUrl'] ?? json['facebook_url'],
      socialInstagram: json['socialInstagram'] ?? json['social_instagram'] ?? json['instagramUrl'] ?? json['instagram_url'],
      socialTiktok: json['socialTiktok'] ?? json['social_tiktok'],
      socialMediaPosition: json['socialMediaPosition'] ?? json['social_media_position'],
      whatsAppLang: json['whatsAppLang'] ?? json['whats_app_lang'],
      whatsAppMessage: json['whatsAppMessage'] ?? json['whats_app_message'],
      seoTitle: json['seoTitle'] ?? json['seo_title'],
      seoDescription: json['seoDescription'] ?? json['seo_description'],
      imageAspectRatio: json['imageAspectRatio'] ?? json['image_aspect_ratio'],
      imageObjectFit: json['imageObjectFit'] ?? json['image_object_fit'],
      imageBorderRadius: json['imageBorderRadius'] != null ? double.parse(json['imageBorderRadius'].toString()) : null,
      imageShowBorder: json['imageShowBorder'] ?? json['image_show_border'],
      imageZoomOnHover: json['imageZoomOnHover'] ?? json['image_zoom_on_hover'],
      cardShape: json['cardShape'] ?? json['card_shape'] ?? json['productCardStyle'] ?? json['product_card_style'] ?? 'style-1',
      viewMode: json['viewMode'] ?? json['view_mode'],
      imageGalleryMode: json['imageGalleryMode'] ?? json['image_gallery_mode'],
      imageGalleryAutoInterval: json['imageGalleryAutoInterval'] != null ? int.parse(json['imageGalleryAutoInterval'].toString()) : null,
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
      'id': id,
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
      'fontColor': fontColor,
      'fontFamily': fontFamily,
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor,
      'cardBackgroundColor': cardBackgroundColor,
      'modalBackgroundColor': modalBackgroundColor,
      'themeColor': themeColor,
      'isRetail': isRetail,
      'isWholesale': isWholesale,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'currencies': currencies?.map((c) => c.toJson()).toList(),
      'deliveryFee': deliveryFee,
      'deliveryAvailable': deliveryAvailable,
      'pickupAvailable': pickupAvailable,
      'hasDelivery': hasDelivery,
      'socialFacebook': socialFacebook,
      'socialInstagram': socialInstagram,
      'socialTiktok': socialTiktok,
      'socialMediaPosition': socialMediaPosition,
      'whatsAppLang': whatsAppLang,
      'whatsAppMessage': whatsAppMessage,
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'imageAspectRatio': imageAspectRatio,
      'imageObjectFit': imageObjectFit,
      'imageBorderRadius': imageBorderRadius,
      'imageShowBorder': imageShowBorder,
      'imageZoomOnHover': imageZoomOnHover,
      'cardShape': cardShape,
      'viewMode': viewMode,
      'imageGalleryMode': imageGalleryMode,
      'imageGalleryAutoInterval': imageGalleryAutoInterval,
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

  static List<Currency>? _parseCurrencies(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => Currency.fromJson(e as Map<String, dynamic>)).toList();
    }
    return null;
  }
}
