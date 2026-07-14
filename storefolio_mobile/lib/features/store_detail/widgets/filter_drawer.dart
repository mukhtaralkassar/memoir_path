import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FilterDrawer extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortChanged;

  const FilterDrawer({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('ترتيب حسب', style: AppTheme.heading3),
          const SizedBox(height: 16),
          _buildSortOption('الأحدث', 'newest', Icons.access_time),
          _buildSortOption('الأقل سعراً', 'price-low', Icons.arrow_downward),
          _buildSortOption('الأعلى سعراً', 'price-high', Icons.arrow_upward),
          _buildSortOption('الأكثر مشاهدة', 'viewed', Icons.visibility),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = currentSort == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textHint,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: () => onSortChanged(value),
    );
  }
}
