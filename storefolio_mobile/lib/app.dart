import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/navigation/app_router.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/store_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/models/store.dart';

class StorefolioApp extends ConsumerWidget {
  const StorefolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final storeName = ref.watch(activeStoreNameProvider);
    final storeAsync = ref.watch(storeConfigProvider(storeName));

    final theme = storeAsync.when(
      data: (store) => _buildStoreTheme(store),
      loading: () => AppTheme.lightTheme,
      error: (_, __) => AppTheme.lightTheme,
    );

    return MaterialApp.router(
      title: 'Storefolio',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme,
      routerConfig: router,
    );
  }

  ThemeData _buildStoreTheme(Store store) {
    final primary = _parseColor(store.themeColor, AppTheme.primaryColor);
    final secondary = _parseColor(store.secondaryColor, AppTheme.secondaryColor);
    final accent = _parseColor(store.accentColor, AppTheme.accentColor);
    return AppTheme.storeTheme(
      primary: primary,
      secondary: secondary,
      accent: accent,
      fontFamily: store.fontFamily,
    );
  }

  Color _parseColor(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return Color(int.parse(value.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (_) {
      return fallback;
    }
  }
}
