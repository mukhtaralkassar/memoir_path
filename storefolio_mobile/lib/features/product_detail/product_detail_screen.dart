import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/models/store.dart';
import '../../core/providers/store_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/currency_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/price_formatter.dart';

final productDetailProvider = FutureProvider.family<Product, Map<String, dynamic>>((ref, params) async {
  final api = ref.watch(apiProvider);
  final storeName = params['storeName'] as String;
  final productId = params['productId'] as int;
  return await api.getProduct(productId, storeName: storeName);
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String storeName;
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.storeName,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  final Map<String, String?> _selectedAttributes = {};

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider({
      'storeName': widget.storeName,
      'productId': widget.productId,
    }));
    final storeAsync = ref.watch(storeConfigProvider(widget.storeName));
    final isWholesale = ref.watch(wholesaleModeProvider);

    return storeAsync.when(
      data: (store) => productAsync.when(
        data: (product) => _buildScaffold(product, store, isWholesale),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('خطأ: $error')),
        ),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('خطأ في تحميل المتجر')),
      ),
    );
  }

  Widget _buildScaffold(Product product, Store store, bool isWholesale) {
    final backgroundColor = AppTheme.parseHexColor(store.backgroundColor, AppTheme.backgroundColor);
    final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);
    final primaryColor = AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(product, primaryColor),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(product, store),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.displayNameAr ?? product.displayNameEn ?? '',
                        style: AppTheme.heading2.copyWith(fontSize: 22, color: fontColor),
                      ),
                      const SizedBox(height: 8),
                      if (product.rating != null) _buildRating(product, fontColor),
                      const SizedBox(height: 16),
                      _buildPrice(product, isWholesale, store, primaryColor),
                      const SizedBox(height: 24),
                      Text('الوصف', style: AppTheme.heading3.copyWith(color: fontColor)),
                      const SizedBox(height: 8),
                      Text(
                        product.displayDescriptionAr ?? product.displayDescriptionEn ?? '',
                        style: AppTheme.body1.copyWith(color: fontColor.withAlpha(204)),
                      ),
                      const SizedBox(height: 24),
                      if (product.attributesJson != null && product.attributesJson!.isNotEmpty)
                        _buildAttributes(product, primaryColor, fontColor),
                      const SizedBox(height: 24),
                      _buildQuantitySelector(fontColor),
                      const SizedBox(height: 24),
                      if (product.sku != null)
                        Text(
                          'رمز المنتج: ${product.sku}',
                          style: AppTheme.caption.copyWith(color: fontColor.withAlpha(153)),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(product, store, isWholesale, primaryColor),
    );
  }

  Widget _buildSliverAppBar(Product product, Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildImageGallery(Product product, Store store) {
    final images = product.images?.isNotEmpty == true
        ? product.images!
        : [product.mainImage ?? 'https://via.placeholder.com/400'];
    final fit = _resolveBoxFit(store.imageObjectFit);
    final borderRadius = store.imageBorderRadius ?? 8;

    return Column(
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: fit,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor)
                      : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRating(Product product, Color fontColor) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final rating = product.rating ?? 0;
          if (index < rating.floor()) {
            return Icon(Icons.star, color: Colors.amber[700], size: 20);
          } else if (index < rating) {
            return Icon(Icons.star_half, color: Colors.amber[700], size: 20);
          }
          return Icon(Icons.star_border, color: Colors.amber[700], size: 20);
        }),
        const SizedBox(width: 8),
        Text(
          '${product.rating?.toStringAsFixed(1)}',
          style: AppTheme.subtitle2.copyWith(color: fontColor),
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewCount} تقييم)',
          style: AppTheme.caption.copyWith(color: fontColor.withAlpha(153)),
        ),
      ],
    );
  }

  Widget _buildPrice(Product product, bool isWholesale, Store store, Color primaryColor) {
    final price = isWholesale ? (product.wholesalePrice ?? product.price ?? 0) : (product.price ?? 0);
    final currency = ref.watch(selectedCurrencyProvider);
    final locale = ref.watch(localeProvider);

    if (product.discountPrice != null && !isWholesale) {
      return Row(
        children: [
          Text(
            PriceFormatter.format(product.discountPrice!, currency: currency, locale: locale.languageCode),
            style: AppTheme.price.copyWith(fontSize: 24, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            PriceFormatter.format(product.price, currency: currency, locale: locale.languageCode),
            style: AppTheme.priceDiscount.copyWith(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${((1 - product.discountPrice! / product.price!) * 100).toStringAsFixed(0)}% خصم',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }
    return Text(
      PriceFormatter.format(price, currency: currency, locale: locale.languageCode),
      style: AppTheme.price.copyWith(fontSize: 24, color: primaryColor),
    );
  }

  Widget _buildAttributes(Product product, Color primaryColor, Color fontColor) {
    Map<String, dynamic>? attrs;
    try {
      attrs = jsonDecode(product.attributesJson!) as Map<String, dynamic>?;
    } catch (_) {
      attrs = null;
    }
    if (attrs == null || attrs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attrs.entries.map((entry) {
        final key = entry.key;
        final values = (entry.value is List) ? List<String>.from(entry.value.map((e) => e.toString())) : <String>[];
        if (values.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key, style: AppTheme.heading3.copyWith(color: fontColor)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: values.map((value) {
                final isSelected = _selectedAttributes[key] == value;
                return ChoiceChip(
                  label: Text(value),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : fontColor,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAttributes[key] = value;
                      } else {
                        _selectedAttributes.remove(key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector(Color fontColor) {
    return Row(
      children: [
        Text('الكمية', style: AppTheme.heading3.copyWith(color: fontColor)),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_quantity',
                  style: AppTheme.subtitle1.copyWith(color: fontColor),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildBottomBar(Product product, Store store, bool isWholesale, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () => _addToCart(product, isWholesale),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('أضف للسلة'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _orderViaWhatsApp(product, store),
                icon: const Icon(Icons.message),
                label: const Text('اطلب عبر واتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product, bool isWholesale) {
    final price = isWholesale ? (product.wholesalePrice ?? product.price ?? 0) : (product.price ?? 0);
    ref.read(cartProvider(widget.storeName).notifier).addItem(
      productId: product.id,
      name: product.displayNameAr ?? product.displayNameEn ?? '',
      price: price,
      image: product.mainImage ?? (product.images?.isNotEmpty == true ? product.images!.first : null),
      quantity: _quantity,
      isWholesale: isWholesale,
      selectedAttributes: _selectedAttributes.isNotEmpty ? jsonEncode(_selectedAttributes) : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${product.displayNameAr} للسلة'),
        action: SnackBarAction(
          label: 'عرض السلة',
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
  }

  void _orderViaWhatsApp(Product product, Store store) {
    // Single product order via WhatsApp
    final items = [
      {
        'productId': product.id,
        'name': product.displayNameAr ?? product.displayNameEn ?? '',
        'quantity': _quantity,
        'price': product.price ?? 0,
        'attributes': _selectedAttributes.isNotEmpty ? jsonEncode(_selectedAttributes) : null,
        'image': product.mainImage ?? (product.images?.isNotEmpty == true ? product.images!.first : null),
      }
    ];
    context.go('/store/${widget.storeName}/whatsapp', extra: {
      'store': store,
      'items': items,
    });
  }

  BoxFit _resolveBoxFit(String? objectFit) {
    switch (objectFit) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'cover':
      default:
        return BoxFit.cover;
    }
  }
}
