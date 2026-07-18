import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/product.dart';
import '../../../core/models/store.dart';
import '../../../core/utils/price_formatter.dart';

class ProductCardFactory extends ConsumerWidget {
  final Product product;
  final Store store;
  final String style;
  final bool isWholesale;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCardFactory({
    super.key,
    required this.product,
    required this.store,
    required this.style,
    this.isWholesale = false,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (style == 'list-style') {
      return _buildHorizontalCard(context, ref);
    }

    final group = _styleGroup(style);
    switch (group) {
      case _CardGroup.vertical:
        return _buildVerticalCard(context, ref);
      case _CardGroup.horizontal:
        return _buildHorizontalCard(context, ref);
      case _CardGroup.overlay:
        return _buildOverlayCard(context, ref);
      case _CardGroup.compact:
        return _buildCompactCard(context, ref);
      case _CardGroup.reversed:
        return _buildReversedCard(context, ref);
      case _CardGroup.banner:
        return _buildBannerCard(context, ref);
      case _CardGroup.accentBorder:
        return _buildAccentBorderCard(context, ref);
      case _CardGroup.asymmetric:
        return _buildAsymmetricCard(context, ref);
      case _CardGroup.geometric:
        return _buildGeometricCard(context, ref);
      case _CardGroup.interactive:
        return _buildInteractiveCard(context, ref);
    }
  }

  // Style grouping for style-1..style-100
  _CardGroup _styleGroup(String style) {
    final id = _extractStyleNumber(style);
    if (id == null) return _CardGroup.vertical;

    if (id >= 1 && id <= 10) return _CardGroup.vertical;
    if (id >= 11 && id <= 20) return _CardGroup.horizontal;
    if (id >= 21 && id <= 30) return _CardGroup.overlay;
    if (id >= 31 && id <= 40) return _CardGroup.compact;
    if (id >= 41 && id <= 50) return _CardGroup.reversed;
    if (id >= 51 && id <= 60) return _CardGroup.banner;
    if (id >= 61 && id <= 70) return _CardGroup.accentBorder;
    if (id >= 71 && id <= 80) return _CardGroup.asymmetric;
    if (id >= 81 && id <= 90) return _CardGroup.geometric;
    if (id >= 91 && id <= 100) return _CardGroup.interactive;

    return _CardGroup.vertical;
  }

  int? _extractStyleNumber(String style) {
    final match = RegExp(r'(\d+)').firstMatch(style);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Color get _cardColor => AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor);
  Color get _fontColor => AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);
  Color get _primaryColor => AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);

  double get _imageAspectRatio {
    switch (store.imageAspectRatio) {
      case '1/1':
      case '1:1':
        return 1.0;
      case '4/3':
      case '4:3':
        return 4 / 3;
      case '16/9':
      case '16:9':
        return 16 / 9;
      case '3/4':
      case '3:4':
        return 3 / 4;
      default:
        return 1.0;
    }
  }

  BoxFit get _imageFit {
    switch (store.imageObjectFit) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'cover':
      default:
        return BoxFit.cover;
    }
  }

  double get _borderRadius => store.imageBorderRadius ?? 8;

  bool get _showBorder => store.imageShowBorder == true;

  double get _price => isWholesale ? (product.wholesalePrice ?? product.price ?? 0) : (product.price ?? 0);

  Widget _buildProductImage({double? height, double? width, BorderRadius? borderRadius}) {
    final imageUrl = product.mainImage ?? (product.images?.isNotEmpty == true ? product.images!.first : null);
    final br = borderRadius ?? BorderRadius.circular(_borderRadius);

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl ?? 'https://via.placeholder.com/300',
      height: height,
      width: width,
      fit: _imageFit,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );

    if (_showBorder) {
      image = Container(
        decoration: BoxDecoration(
          borderRadius: br,
          border: Border.all(color: _primaryColor.withAlpha(77), width: 1),
        ),
        child: ClipRRect(borderRadius: br, child: image),
      );
    } else {
      image = ClipRRect(borderRadius: br, child: image);
    }

    return image;
  }

  Widget _buildPriceWidget(WidgetRef ref) {
    final currency = ref.watch(selectedCurrencyProvider);
    final locale = ref.watch(localeProvider);

    final basePrice = isWholesale
        ? (product.wholesalePrice ?? product.price ?? 0)
        : (product.price ?? 0);
    final formatted = PriceFormatter.format(basePrice, currency: currency, locale: locale.languageCode);

    if (product.discountPrice != null) {
      final discounted = isWholesale
          ? (product.wholesalePrice ?? product.discountPrice!)
          : product.discountPrice!;
      final formattedDiscount = PriceFormatter.format(discounted, currency: currency, locale: locale.languageCode);
      final formattedOriginal = PriceFormatter.format(basePrice, currency: currency, locale: locale.languageCode);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDiscount,
            style: AppTheme.price.copyWith(color: _primaryColor),
          ),
          Text(
            formattedOriginal,
            style: AppTheme.priceDiscount,
          ),
        ],
      );
    }
    return Text(
      formatted,
      style: AppTheme.price.copyWith(color: _primaryColor),
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

  Widget _buildVerticalCard(BuildContext context, WidgetRef ref) {
    return Card(
      color: _cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: _imageAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
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
                    style: AppTheme.subtitle1.copyWith(fontSize: 14, color: _fontColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.displayDescriptionAr != null)
                    Text(
                      product.displayDescriptionAr!,
                      style: AppTheme.body2.copyWith(fontSize: 12, color: _fontColor.withAlpha(179)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceWidget(ref),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        onPressed: onAddToCart,
                        color: _primaryColor,
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

  Widget _buildHorizontalCard(BuildContext context, WidgetRef ref) {
    return Card(
      color: _cardColor,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(_borderRadius)),
              child: SizedBox(
                width: 120,
                height: 120,
                child: _buildProductImage(borderRadius: BorderRadius.zero),
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
                      style: AppTheme.subtitle1.copyWith(fontSize: 14, color: _fontColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildPriceWidget(ref),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('أضف للسلة', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
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

  Widget _buildOverlayCard(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(selectedCurrencyProvider);
    final locale = ref.watch(localeProvider);
    final formatted = PriceFormatter.format(_price, currency: currency, locale: locale.languageCode);

    return Card(
      color: _cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: _imageAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildProductImage(borderRadius: BorderRadius.zero),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(179),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Row(children: _buildBadges()),
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
                        formatted,
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
                  backgroundColor: _primaryColor,
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

  Widget _buildCompactCard(BuildContext context, WidgetRef ref) {
    return _buildVerticalCard(context, ref);
  }

  Widget _buildReversedCard(BuildContext context, WidgetRef ref) {
    return Card(
      color: _cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.displayNameAr ?? product.displayNameEn ?? '',
                      style: AppTheme.subtitle1.copyWith(fontSize: 14, color: _fontColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriceWidget(ref),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: _imageAspectRatio,
              child: _buildProductImage(borderRadius: BorderRadius.zero),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('أضف للسلة', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, WidgetRef ref) {
    return _buildOverlayCard(context, ref);
  }

  Widget _buildAccentBorderCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: _primaryColor.withAlpha(128), width: 2),
      ),
      child: _buildVerticalCard(context, ref),
    );
  }

  Widget _buildAsymmetricCard(BuildContext context, WidgetRef ref) {
    return _buildVerticalCard(context, ref);
  }

  Widget _buildGeometricCard(BuildContext context, WidgetRef ref) {
    return ClipPath(
      clipper: _DiagonalClipper(),
      child: _buildVerticalCard(context, ref),
    );
  }

  Widget _buildInteractiveCard(BuildContext context, WidgetRef ref) {
    return _buildVerticalCard(context, ref);
  }
}

enum _CardGroup {
  vertical,
  horizontal,
  overlay,
  compact,
  reversed,
  banner,
  accentBorder,
  asymmetric,
  geometric,
  interactive,
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
