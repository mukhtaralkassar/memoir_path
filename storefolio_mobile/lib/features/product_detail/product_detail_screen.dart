import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/models/store.dart';

final productDetailProvider = FutureProvider.family<Product, Map<String, dynamic>>((ref, params) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return Product(
    id: params['productId'],
    displayNameAr: 'منتج تجريبي مفصل',
    displayNameEn: 'Detailed Test Product',
    displayDescriptionAr: 'هذا وصف تفصيلي للمنتج. المنتج عالي الجودة ومتاح بألوان وأحجام متعددة.',
    displayDescriptionEn: 'This is a detailed product description.',
    price: 15000.0,
    discountPrice: 12000.0,
    quantity: 50,
    sku: 'SKU-001',
    categoryNameAr: 'تصنيف رئيسي',
    images: [
      'https://via.placeholder.com/400',
      'https://via.placeholder.com/400/300',
      'https://via.placeholder.com/400/600',
    ],
    mainImage: 'https://via.placeholder.com/400',
    isRetailAvailable: true,
    isFeatured: true,
    rating: 4.5,
    reviewCount: 12,
    attributesJson: '{"colors":["أحمر","أزرق","أسود"],"sizes":["S","M","L","XL"]}',
  );
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
  String? _selectedColor;
  String? _selectedSize;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider({
      'storeName': widget.storeName,
      'productId': widget.productId,
    }));

    return Scaffold(
      body: productAsync.when(
        data: (product) => CustomScrollView(
          slivers: [
            _buildSliverAppBar(product),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery
                  _buildImageGallery(product),
                  
                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          product.displayNameAr ?? '',
                          style: AppTheme.heading2.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        
                        // Rating
                        if (product.rating != null)
                          _buildRating(product),
                        
                        const SizedBox(height: 16),
                        
                        // Price
                        _buildPrice(product),
                        
                        const SizedBox(height: 24),
                        
                        // Description
                        Text('الوصف', style: AppTheme.heading3),
                        const SizedBox(height: 8),
                        Text(
                          product.displayDescriptionAr ?? '',
                          style: AppTheme.body1,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Attributes (Color, Size)
                        if (product.attributesJson != null)
                          _buildAttributes(product),
                        
                        const SizedBox(height: 24),
                        
                        // Quantity
                        _buildQuantitySelector(),
                        
                        const SizedBox(height: 24),
                        
                        // SKU
                        if (product.sku != null)
                          Text(
                            'رمز المنتج: ${product.sku}',
                            style: AppTheme.caption,
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
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('خطأ: $error')),
        ),
      ),
      bottomNavigationBar: productAsync.when(
        data: (product) => _buildBottomBar(product),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildSliverAppBar(Product product) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Share product
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Add to favorites
          },
        ),
      ],
    );
  }

  Widget _buildImageGallery(Product product) {
    final images = product.images ?? [product.mainImage ?? 'https://via.placeholder.com/400'];
    
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
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 64),
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
                      ? AppTheme.primaryColor
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

  Widget _buildRating(Product product) {
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
          style: AppTheme.subtitle2,
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewCount} تقييم)',
          style: AppTheme.caption,
        ),
      ],
    );
  }

  Widget _buildPrice(Product product) {
    if (product.discountPrice != null) {
      return Row(
        children: [
          Text(
            '${product.discountPrice?.toStringAsFixed(0)} SYP',
            style: AppTheme.price.copyWith(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            '${product.price?.toStringAsFixed(0)} SYP',
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
      '${product.price?.toStringAsFixed(0)} SYP',
      style: AppTheme.price.copyWith(fontSize: 24),
    );
  }

  Widget _buildAttributes(Product product) {
    // TODO: Parse attributesJson properly
    final colors = ['أحمر', 'أزرق', 'أسود'];
    final sizes = ['S', 'M', 'L', 'XL'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colors
        Text('اللون', style: AppTheme.heading3),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: colors.map((color) {
            final isSelected = _selectedColor == color;
            return ChoiceChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedColor = selected ? color : null;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Sizes
        Text('المقاس', style: AppTheme.heading3),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: sizes.map((size) {
            final isSelected = _selectedSize == size;
            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSize = selected ? size : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text('الكمية', style: AppTheme.heading3),
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
                  style: AppTheme.subtitle1,
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

  Widget? _buildBottomBar(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                onPressed: () {
                  _addToCart(product);
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('أضف للسلة'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  _orderViaWhatsApp(product);
                },
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

  void _addToCart(Product product) {
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

  void _orderViaWhatsApp(Product product) {
    // TODO: Implement WhatsApp order
    context.go('/store/${widget.storeName}/whatsapp', extra: {
      'product': product,
      'quantity': _quantity,
      'color': _selectedColor,
      'size': _selectedSize,
    });
  }
}
