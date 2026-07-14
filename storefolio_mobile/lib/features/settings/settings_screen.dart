import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('اللغة'),
          _buildLanguageTile(context, ref, isArabic),
          const Divider(),
          
          _buildSection('حول التطبيق'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('الإصدار'),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('سياسة الخصوصية'),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('الدعم الفني'),
            onTap: () {
              // TODO: Open support
            },
          ),
          const Divider(),
          
          _buildSection('قانوني'),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('شروط الاستخدام'),
            onTap: () {
              // TODO: Open terms
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: AppTheme.subtitle1.copyWith(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref, bool isArabic) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('اللغة'),
      subtitle: Text(isArabic ? 'العربية' : 'English'),
      trailing: Switch(
        value: isArabic,
        onChanged: (value) {
          ref.read(localeProvider.notifier).toggleLocale();
        },
      ),
    );
  }
}
