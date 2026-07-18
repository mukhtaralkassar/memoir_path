import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/dio_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/store.dart';
import '../../core/models/product.dart';
import '../../core/models/category.dart';
import '../../core/providers/store_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/api/storefolio_api.dart';
import '../store_expired/store_expired_screen.dart';
import 'widgets/product_card_factory.dart';
import 'widgets/filter_drawer.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/cart_drawer.dart';
import 'widgets/store_menu_drawer.dart';

class StoreDetailScreen extends ConsumerStatefulWidget {
  final String storeName;

  const StoreDetailScreen({super.key, required this.storeName});

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  bool _showSearch = false;
  String _searchQuery = '';
  String? _selectedCategory;
  int? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'newest';
  bool? _overrideGridView;

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeConfigProvider(widget.storeName));
    final productsAsync = ref.watch(storeProductsProvider(widget.storeName));
    final categoriesAsync = ref.watch(storeCategoriesProvider(widget.storeName));
    final isWholesale = ref.watch(wholesaleModeProvider);

    return storeAsync.when(
      skipLoadingOnReload: true,
      data: (store) {
        if (store.isExpired == true) {
          return StoreExpiredScreen(store: store);
        }
        return _buildStoreScaffold(store, productsAsync, categoriesAsync, isWholesale);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) {
        if (DioClient.isExpiredStoreError(error)) {
          return StoreExpiredScreen(
            store: Store(storeName: widget.storeName, displayName: widget.storeName, isExpired: true),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ في تحميل المتجر', style: AppTheme.subtitle1),
                Text(error.toString(), style: AppTheme.caption),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreScaffold(Store store, AsyncValue<ProductResponse> productsAsync, AsyncValue<List<Category>> categoriesAsync, bool isWholesale) {
    final isGridView = _overrideGridView ?? (store.viewMode == 'list' ? false : true);
    final backgroundColor = AppTheme.parseHexColor(store.backgroundColor, AppTheme.backgroundColor);
    final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);

    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: isArabic ? null : StoreMenuDrawer(store: store),
      endDrawer: isArabic ? StoreMenuDrawer(store: store) : null,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(store, isWholesale, fontColor, isArabic),

          if (store.showSearch == true && _showSearch)
            SliverToBoxAdapter(
              child: SearchBarWidget(
                storeName: widget.storeName,
                onSearch: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),

          if (store.showCategories == true)
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => _buildCategoriesList(categories, store, fontColor),
                loading: () => const SizedBox(height: 50),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          productsAsync.when(
            data: (response) => _buildProductsGrid(response.products, store, isGridView, isWholesale),
            loading: () => SliverToBoxAdapter(
              child: _buildProductsShimmer(),
            ),
            error: (error, _) {
              if (DioClient.isExpiredStoreError(error)) {
                return SliverToBoxAdapter(
                  child: StoreExpiredScreen(store: store),
                );
              }
              return SliverToBoxAdapter(
                child: _buildErrorWidget(error),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCartDrawer(context),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('السلة'),
      ),
    );
  }

  Widget _buildSliverAppBar(Store store, bool isWholesale, Color fontColor, bool isArabic) {
    final isGridView = _overrideGridView ?? (store.viewMode == 'list' ? false : true);
    final canWholesale = store.isWholesale == true;
    final canRetail = store.isRetail != false;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                if (isArabic) {
                  Scaffold.of(context).openEndDrawer();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
            ),
          ),
          if (canRetail && canWholesale)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ChoiceChip(
              label: Text(isWholesale ? 'جملة' : 'مفرق'),
              selected: isWholesale,
              onSelected: (_) => _toggleWholesaleMode(),
              selectedColor: AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor),
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDrawer(context, []),
        ),
        IconButton(
          icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _overrideGridView = !isGridView;
            });
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          store.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            store.bannerUrl != null
                ? Image.network(
                    store.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor)),
                  )
                : Container(color: AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleWholesaleMode() {
    ref.read(wholesaleModeProvider.notifier).state = !ref.read(wholesaleModeProvider);
  }

  Widget _buildCategoriesList(List<Category> categories, Store store, Color fontColor) {
    final primary = AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('الكل', _selectedCategory == null, () {
              setState(() {
                _selectedCategory = null;
                _selectedCategoryId = null;
              });
            }, primary, fontColor);
          }
          final category = categories[index - 1];
          final isSelected = _selectedCategory == category.nameAr;
          return _buildCategoryChip(
            category.nameAr,
            isSelected,
            () {
              setState(() {
                if (isSelected) {
                  _selectedCategory = null;
                  _selectedCategoryId = null;
                } else {
                  _selectedCategory = category.nameAr;
                  _selectedCategoryId = category.id;
                }
              });
            },
            primary,
            fontColor,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap, Color primary, Color fontColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: primary,
        backgroundColor: AppTheme.parseHexColor(null, AppTheme.surfaceColor),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : fontColor,
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products, Store store, bool isGridView, bool isWholesale) {
    final filteredProducts = _filterProducts(products, isWholesale);
    final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);

    if (filteredProducts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.search_off,
                size: 64,
                color: AppTheme.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد منتجات',
                style: AppTheme.subtitle1.copyWith(color: fontColor.withAlpha(153)),
              ),
            ],
          ),
        ),
      );
    }

    final style = isGridView ? (store.cardShape ?? 'style-1') : 'list-style';

    if (isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: _resolveChildAspectRatio(store.imageAspectRatio),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = filteredProducts[index];
              return ProductCardFactory(
                product: product,
                store: store,
                style: style,
                isWholesale: isWholesale,
                onTap: () => context.go(
                  '/store/${widget.storeName}/product/${product.id}',
                ),
                onAddToCart: () => _addToCart(product, isWholesale),
              );
            },
            childCount: filteredProducts.length,
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = filteredProducts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ProductCardFactory(
                product: product,
                store: store,
                style: style,
                isWholesale: isWholesale,
                onTap: () => context.go(
                  '/store/${widget.storeName}/product/${product.id}',
                ),
                onAddToCart: () => _addToCart(product, isWholesale),
              ),
            );
          },
          childCount: filteredProducts.length,
        ),
      );
    }
  }

  double _resolveChildAspectRatio(String? imageAspectRatio) {
    switch (imageAspectRatio) {
      case '1/1':
      case '1:1':
        return 0.75;
      case '4/3':
      case '4:3':
        return 0.85;
      case '16/9':
      case '16:9':
        return 1.1;
      case '3/4':
      case '3:4':
        return 0.65;
      default:
        return 0.65;
    }
  }

  List<Product> _filterProducts(List<Product> products, bool isWholesale) {
    var filtered = products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final nameAr = p.displayNameAr?.toLowerCase() ?? '';
        final nameEn = p.displayNameEn?.toLowerCase() ?? '';
        final descAr = p.displayDescriptionAr?.toLowerCase() ?? '';
        final descEn = p.displayDescriptionEn?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return nameAr.contains(query) ||
            nameEn.contains(query) ||
            descAr.contains(query) ||
            descEn.contains(query);
      }).toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((p) =>
        p.categoryNameAr == _selectedCategory
      ).toList();
    }

    // Price range filter
    if (_minPrice != null) {
      filtered = filtered.where((p) {
        final price = _resolvePrice(p, isWholesale);
        return price >= _minPrice!;
      }).toList();
    }
    if (_maxPrice != null) {
      filtered = filtered.where((p) {
        final price = _resolvePrice(p, isWholesale);
        return price <= _maxPrice!;
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => (b.id).compareTo(a.id));
        break;
      case 'price-low':
        filtered.sort((a, b) => _resolvePrice(a, isWholesale).compareTo(_resolvePrice(b, isWholesale)));
        break;
      case 'price-high':
        filtered.sort((a, b) => _resolvePrice(b, isWholesale).compareTo(_resolvePrice(a, isWholesale)));
        break;
      case 'viewed':
        filtered.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
        break;
      case 'name-asc':
        filtered.sort((a, b) {
          final aName = a.displayNameAr ?? a.displayNameEn ?? '';
          final bName = b.displayNameAr ?? b.displayNameEn ?? '';
          return aName.compareTo(bName);
        });
        break;
    }

    return filtered;
  }

  double _resolvePrice(Product product, bool isWholesale) {
    if (isWholesale) {
      return product.wholesalePrice ?? product.price ?? 0;
    }
    return product.price ?? 0;
  }

  Widget _buildProductsShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('خطأ: $error', style: AppTheme.caption),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product, bool isWholesale) {
    final cartNotifier = ref.read(cartProvider(widget.storeName).notifier);
    cartNotifier.addItem(
      productId: product.id,
      name: product.displayNameAr ?? product.displayNameEn ?? '',
      price: isWholesale ? (product.wholesalePrice ?? product.price ?? 0) : (product.price ?? 0),
      image: product.mainImage ?? (product.images?.isNotEmpty == true ? product.images!.first : null),
      quantity: 1,
      isWholesale: isWholesale,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${product.displayNameAr} إلى السلة'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'عرض السلة',
          onPressed: () => _showCartDrawer(context),
        ),
      ),
    );
  }

  void _showFilterDrawer(BuildContext context, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterDrawer(
        currentSort: _sortBy,
        selectedCategoryId: _selectedCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        categories: categories,
        onApply: (result) {
          setState(() {
            _sortBy = result.sort;
            _selectedCategoryId = result.categoryId;
            _minPrice = result.minPrice;
            _maxPrice = result.maxPrice;
            _selectedCategory = result.categoryId == null
                ? null
                : categories
                    .firstWhere((c) => c.id == result.categoryId)
                    .nameAr;
          });
        },
        onReset: () {
          setState(() {
            _sortBy = 'newest';
            _selectedCategory = null;
            _selectedCategoryId = null;
            _minPrice = null;
            _maxPrice = null;
          });
        },
      ),
    );
  }

  void _showCartDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CartDrawer(storeName: widget.storeName),
    );
  }
}
