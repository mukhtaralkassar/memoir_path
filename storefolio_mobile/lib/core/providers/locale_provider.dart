import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../api/dio_client.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.instance;
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref _ref;
  StorageService? _storage;

  LocaleNotifier(this._ref) : super(const Locale(AppConstants.defaultLanguage)) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _storage = await _ref.read(storageServiceProvider.future);
    final language = _storage!.getLanguage();
    _applyLanguage(language);
  }

  Future<void> setLocale(String languageCode) async {
    if (AppConstants.supportedLanguages.contains(languageCode)) {
      await _storage?.setLanguage(languageCode);
      _applyLanguage(languageCode);
    }
  }

  void _applyLanguage(String languageCode) {
    state = Locale(languageCode);
    DioContext.locale = state;
    DioClient.reset();
    AnalyticsService.setUserLanguage(languageCode);
  }

  void toggleLocale() {
    final newLang = state.languageCode == 'ar' ? 'en' : 'ar';
    setLocale(newLang);
  }
}
