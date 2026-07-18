import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/category.dart';
import '../../../core/theme/app_theme.dart';

/// Advanced filter bottom sheet with category chips, price range, and sorting.
class FilterDrawer extends StatefulWidget {
  final String currentSort;
  final int? selectedCategoryId;
  final double? minPrice;
  final double? maxPrice;
  final List<Category> categories;
  final Function(FilterResult) onApply;
  final VoidCallback? onReset;

  const FilterDrawer({
    super.key,
    required this.currentSort,
    this.selectedCategoryId,
    this.minPrice,
    this.maxPrice,
    required this.categories,
    required this.onApply,
    this.onReset,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late String _sort;
  late int? _selectedCategoryId;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  static const List<Map<String, dynamic>> _sortOptions = [
    {'labelAr': 'الأحدث', 'labelEn': 'Newest', 'value': 'newest', 'icon': Icons.access_time},
    {'labelAr': 'الأقل سعراً', 'labelEn': 'Price: Low to High', 'value': 'price-low', 'icon': Icons.arrow_downward},
    {'labelAr': 'الأعلى سعراً', 'labelEn': 'Price: High to Low', 'value': 'price-high', 'icon': Icons.arrow_upward},
    {'labelAr': 'الأكثر مشاهدة', 'labelEn': 'Most Viewed', 'value': 'viewed', 'icon': Icons.visibility},
    {'labelAr': 'الاسم أ-ي', 'labelEn': 'Name A-Z', 'value': 'name-asc', 'icon': Icons.sort_by_alpha},
  ];

  @override
  void initState() {
    super.initState();
    _sort = widget.currentSort;
    _selectedCategoryId = widget.selectedCategoryId;
    _minPriceController = TextEditingController(
      text: widget.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.maxPrice?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'الفلترة والترتيب' : 'Filter & Sort',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSectionTitle(isArabic ? 'ترتيب حسب' : 'Sort By'),
                    _buildSortOptions(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(isArabic ? 'التصنيف' : 'Category'),
                    _buildCategoryChips(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(isArabic ? 'نطاق السعر' : 'Price Range'),
                    _buildPriceRange(isArabic),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildActionButtons(isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTheme.subtitle1),
    );
  }

  Widget _buildSortOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _sortOptions.map((option) {
        final value = option['value'] as String;
        final isSelected = _sort == value;
        final isArabic = Directionality.of(context) == TextDirection.rtl;
        return ChoiceChip(
          label: Text(isArabic ? option['labelAr'] : option['labelEn']),
          selected: isSelected,
          onSelected: (_) => setState(() => _sort = value),
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips() {
    if (widget.categories.isEmpty) {
      return Text(
        Directionality.of(context) == TextDirection.rtl
            ? 'لا توجد تصنيفات'
            : 'No categories',
        style: AppTheme.body2.copyWith(color: AppTheme.textHint),
      );
    }

    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(isArabic ? 'الكل' : 'All'),
          selected: _selectedCategoryId == null,
          onSelected: (_) => setState(() => _selectedCategoryId = null),
        ),
        ...widget.categories.map((category) {
          final isSelected = _selectedCategoryId == category.id;
          return ChoiceChip(
            label: Text(isArabic ? category.nameAr : (category.nameEn ?? category.nameAr)),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedCategoryId = isSelected ? null : category.id),
          );
        }),
      ],
    );
  }

  Widget _buildPriceRange(bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: isArabic ? 'الحد الأدنى' : 'Min',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('—'),
        ),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: isArabic ? 'الحد الأعلى' : 'Max',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              widget.onReset?.call();
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'إعادة تعيين' : 'Reset'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApply(FilterResult(
                sort: _sort,
                categoryId: _selectedCategoryId,
                minPrice: _parseDouble(_minPriceController.text),
                maxPrice: _parseDouble(_maxPriceController.text),
              ));
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'تطبيق' : 'Apply'),
          ),
        ),
      ],
    );
  }

  double? _parseDouble(String text) {
    if (text.trim().isEmpty) return null;
    return double.tryParse(text);
  }
}

class FilterResult {
  final String sort;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;

  const FilterResult({
    required this.sort,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });
}
