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
    final primary = AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);
    final secondary = AppTheme.parseHexColor(store.secondaryColor, AppTheme.secondaryColor);
    final accent = AppTheme.parseHexColor(store.accentColor, AppTheme.accentColor);
    final background = AppTheme.parseHexColor(store.backgroundColor, AppTheme.backgroundColor);
    final surface = AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor);
    final onSurface = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);
    return AppTheme.storeTheme(
      primary: primary,
      secondary: secondary,
      accent: accent,
      background: background,
      surface: surface,
      onSurface: onSurface,
      fontFamily: store.fontFamily,
    );
  }
}
