import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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
    state = Locale(language);
  }

  Future<void> setLocale(String languageCode) async {
    if (AppConstants.supportedLanguages.contains(languageCode)) {
      await _storage?.setLanguage(languageCode);
      state = Locale(languageCode);
    }
  }

  void toggleLocale() {
    final newLang = state.languageCode == 'ar' ? 'en' : 'ar';
    setLocale(newLang);
  }
}
