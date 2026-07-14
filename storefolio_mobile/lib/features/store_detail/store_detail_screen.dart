import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/dio_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/store.dart';
import '../../core/models/product.dart';
import '../../core/models/category.dart';
import '../../core/providers/store_provider.dart';
import '../../core/providers/api_provider.dart';
import '../store_expired/store_expired_screen.dart';
import 'widgets/product_card_factory.dart';
import 'widgets/filter_drawer.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/cart_drawer.dart';

final storeDetailProvider = FutureProvider.family<Store, String>((ref, storeName) async {
  final api = ref.watch(apiProvider);
  return await api.getStore(storeName);
});

final productsProvider = FutureProvider.family<List<Product>, String>((ref, storeName) async {
  final api = ref.watch(apiProvider);
  final response = await api.getProducts(storeName, page: 1, pageSize: 100, sort: 'newest');
  return response.products;
});

final categoriesProvider = FutureProvider.family<List<Category>, String>((ref, storeName) async {
  final api = ref.watch(apiProvider);
  return await api.getCategories(storeName);
});

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
  String _sortBy = 'newest';
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeDetailProvider(widget.storeName));
    final productsAsync = ref.watch(productsProvider(widget.storeName));
    final categoriesAsync = ref.watch(categoriesProvider(widget.storeName));

    return storeAsync.when(
      data: (store) {
        // If the store came back as expired, block the whole app.
        if (store.isExpired == true) {
          return StoreExpiredScreen(store: store);
        }
        return _buildStoreScaffold(store, productsAsync, categoriesAsync);
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

  Widget _buildStoreScaffold(Store store, AsyncValue<List<Product>> productsAsync, AsyncValue<List<Category>> categoriesAsync) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Banner
          _buildSliverAppBar(store),

          // Search Bar
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

          // Categories
          if (store.showCategories == true)
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => _buildCategoriesList(categories),
                loading: () => const SizedBox(height: 50),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          // Products Grid
          productsAsync.when(
            data: (products) => _buildProductsGrid(products, store),
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

  Widget _buildSliverAppBar(Store store) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: true,
      actions: [
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
          onPressed: () => _showFilterDrawer(context),
        ),
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
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
            // Banner Image
            store.bannerUrl != null
                ? Image.network(
                    store.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppTheme.primaryColor),
                  )
                : Container(color: AppTheme.primaryColor),
            // Gradient Overlay
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

  Widget _buildCategoriesList(List<Category> categories) {
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
              });
            });
          }
          final category = categories[index - 1];
          final isSelected = _selectedCategory == category.nameAr;
          return _buildCategoryChip(
            category.nameAr,
            isSelected,
            () {
              setState(() {
                _selectedCategory = isSelected ? null : category.nameAr;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products, Store store) {
    final filteredProducts = _filterProducts(products);

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
                style: AppTheme.subtitle1.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = filteredProducts[index];
              return ProductCardFactory(
                product: product,
                store: store,
                style: store.productCardStyle ?? 'style-1',
                onTap: () => context.go(
                  '/store/${widget.storeName}/product/${product.id}',
                ),
                onAddToCart: () => _addToCart(product),
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
                style: 'list-style',
                onTap: () => context.go(
                  '/store/${widget.storeName}/product/${product.id}',
                ),
                onAddToCart: () => _addToCart(product),
              ),
            );
          },
          childCount: filteredProducts.length,
        ),
      );
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final name = p.displayNameAr?.toLowerCase() ?? '';
        final desc = p.displayDescriptionAr?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || desc.contains(query);
      }).toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((p) =>
        p.categoryNameAr == _selectedCategory
      ).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => (b.id).compareTo(a.id));
        break;
      case 'price-low':
        filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price-high':
        filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'viewed':
        filtered.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
        break;
    }

    return filtered;
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

  void _addToCart(Product product) {
    // TODO: Implement cart functionality
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

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterDrawer(
        currentSort: _sortBy,
        onSortChanged: (sort) {
          setState(() {
            _sortBy = sort;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCartDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CartDrawer(),
    );
  }
}
