import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/product.dart';
import '../../../core/models/store.dart';

class ProductCardFactory extends StatelessWidget {
  final Product product;
  final Store store;
  final String style;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCardFactory({
    super.key,
    required this.product,
    required this.store,
    required this.style,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (style == 'list-style' || style == 'style-2') {
      return _buildHorizontalCard(context);
    }
    if (style == 'style-3') {
      return _buildOverlayCard(context);
    }
    return _buildVerticalCard(context);
  }

  Widget _buildPriceWidget() {
    if (product.discountPrice != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${product.discountPrice?.toStringAsFixed(0)} ${store.currencySymbol ?? ''}',
            style: AppTheme.price,
          ),
          Text(
            '${product.price?.toStringAsFixed(0)} ${store.currencySymbol ?? ''}',
            style: AppTheme.priceDiscount,
          ),
        ],
      );
    }
    return Text(
      '${product.price?.toStringAsFixed(0)} ${store.currencySymbol ?? ''}',
      style: AppTheme.price,
    );
  }

  Widget _buildProductImage({double? height, BorderRadius? borderRadius, BoxFit fit = BoxFit.cover}) {
    final imageUrl = product.mainImage ?? (product.images?.isNotEmpty == true ? product.images!.first : null);
    return CachedNetworkImage(
      imageUrl: imageUrl ?? 'https://via.placeholder.com/300',
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }

  List<Widget> _buildBadges() {
    final badges = <Widget>[];
    if (product.isNew == true) badges.add(_buildBadge('جديد', Colors.green));
    if (product.isOnSale == true || product.discountPrice != null) badges.add(_buildBadge('عرض', Colors.red));
    if (product.isFeatured == true) badges.add(_buildBadge('مميز', Colors.orange));
    return badges;
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(children: _buildBadges()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.displayNameAr ?? product.displayNameEn ?? '',
                    style: AppTheme.subtitle1.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.displayDescriptionAr != null)
                    Text(
                      product.displayDescriptionAr!,
                      style: AppTheme.body2.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceWidget(),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        onPressed: onAddToCart,
                        color: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 120,
                height: 120,
                child: _buildProductImage(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: _buildBadges()),
                    const SizedBox(height: 4),
                    Text(
                      product.displayNameAr ?? product.displayNameEn ?? '',
                      style: AppTheme.subtitle1.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildPriceWidget(),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('أضف للسلة', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 0.8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildProductImage(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: _buildBadges()),
                      const SizedBox(height: 4),
                      Text(
                        product.displayNameAr ?? product.displayNameEn ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price?.toStringAsFixed(0)} ${store.currencySymbol ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    onPressed: onAddToCart,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
