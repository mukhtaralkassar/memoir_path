import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final String storeName;
  final Function(String) onSearch;

  const SearchBarWidget({
    super.key,
    required this.storeName,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'ابحث في المتجر...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              onSearch('');
            },
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
