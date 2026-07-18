import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/currency.dart';
import '../../core/providers/currency_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final currencies = ref.watch(storeCurrenciesProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final storeAsync = ref.watch(currentStoreProvider);
    final store = storeAsync.valueOrNull;

    final l10n = _AppLabels(isArabic);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(l10n.language),
          _LanguageTile(isArabic: isArabic),
          const Divider(),

          _buildSection(l10n.currency),
          if (currencies.isNotEmpty)
            _CurrencyTile(
              currencies: currencies,
              selectedCurrency: selectedCurrency,
            )
          else
            ListTile(
              leading: const Icon(Icons.money_outlined),
              title: Text(l10n.currency),
              subtitle: Text(store?.currency ?? 'USD'),
            ),
          const Divider(),

          _buildSection(l10n.aboutApp),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.support),
            onTap: () {
              // TODO: Open support
            },
          ),
          const Divider(),

          _buildSection(l10n.legal),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfUse),
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
}

class _LanguageTile extends ConsumerWidget {
  final bool isArabic;

  const _LanguageTile({required this.isArabic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(isArabic ? 'اللغة' : 'Language'),
      subtitle: Text(isArabic ? 'العربية' : 'English'),
      trailing: Switch(
        value: isArabic,
        onChanged: (_) {
          ref.read(localeProvider.notifier).toggleLocale();
        },
      ),
    );
  }
}

class _CurrencyTile extends ConsumerWidget {
  final List<Currency> currencies;
  final Currency selectedCurrency;

  const _CurrencyTile({
    required this.currencies,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = currencies.contains(selectedCurrency) ? selectedCurrency : currencies.first;

    return ListTile(
      leading: const Icon(Icons.money_outlined),
      title: Text(_AppLabels(ref.watch(localeProvider).languageCode == 'ar').currency),
      subtitle: Text('${selectedCurrency.name} (${selectedCurrency.symbol})'),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: value,
          items: currencies.map((currency) {
            return DropdownMenuItem<Currency>(
              value: currency,
              child: Text('${currency.name} (${currency.symbol})'),
            );
          }).toList(),
          onChanged: (currency) {
            if (currency != null) {
              ref.read(selectedCurrencyProvider.notifier).setCurrency(currency);
              AnalyticsService.setUserCurrency(currency.code);
            }
          },
        ),
      ),
    );
  }
}

class _AppLabels {
  final bool isArabic;

  const _AppLabels(this.isArabic);

  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get currency => isArabic ? 'العملة' : 'Currency';
  String get aboutApp => isArabic ? 'حول التطبيق' : 'About App';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get privacyPolicy => isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get support => isArabic ? 'الدعم الفني' : 'Support';
  String get legal => isArabic ? 'قانوني' : 'Legal';
  String get termsOfUse => isArabic ? 'شروط الاستخدام' : 'Terms of Use';
}
