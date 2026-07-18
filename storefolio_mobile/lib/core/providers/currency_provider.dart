import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_client.dart';
import '../models/currency.dart';
import '../models/store.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import 'store_provider.dart';

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.instance;
});

final storeCurrenciesProvider = Provider<List<Currency>>((ref) {
  final storeAsync = ref.watch(currentStoreProvider);
  return storeAsync.when(
    data: (store) => store?.currencies ?? _fallbackCurrencies(store),
    loading: () => [],
    error: (_, __) => [],
  );
});

List<Currency> _fallbackCurrencies(Store? store) {
  final base = store?.currency ?? 'USD';
  final symbol = store?.currencySymbol ?? r'$';
  return [
    Currency(
      id: 0,
      name: base,
      symbol: symbol,
      code: base,
      rate: 1.0,
      isDefault: true,
      showExchangeRate: true,
    ),
  ];
}

final selectedCurrencyProvider = StateNotifierProvider<SelectedCurrencyNotifier, Currency>((ref) {
  return SelectedCurrencyNotifier(ref);
});

class SelectedCurrencyNotifier extends StateNotifier<Currency> {
  final Ref _ref;
  StorageService? _storage;

  SelectedCurrencyNotifier(this._ref) : super(_defaultCurrency) {
    _load();
  }

  static final Currency _defaultCurrency = Currency(
    id: 0,
    name: 'USD',
    symbol: r'$',
    code: 'USD',
    rate: 1.0,
    isDefault: true,
    showExchangeRate: true,
  );

  Future<void> _load() async {
    _storage = await _ref.read(storageServiceProvider.future);

    // Subscribe to store currencies so we can re-evaluate when the store loads.
    final currencies = _ref.read(storeCurrenciesProvider);
    final savedCode = _storage?.getCurrency();

    if (currencies.isNotEmpty && savedCode != null) {
      final match = currencies.firstWhere(
        (c) => c.code == savedCode,
        orElse: () => currencies.firstWhere((c) => c.isDefault, orElse: () => currencies.first),
      );
      state = match;
    } else if (currencies.isNotEmpty) {
      final defaultCurrency = currencies.firstWhere(
        (c) => c.isDefault,
        orElse: () => currencies.first,
      );
      state = defaultCurrency;
    }

    _updateDioContext();
    AnalyticsService.setUserCurrency(state.code);
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    await _storage?.setCurrency(currency.code);
    _updateDioContext();
    AnalyticsService.setUserCurrency(currency.code);
  }

  void _updateDioContext() {
    DioContext.currency = state;
    DioClient.reset();
  }
}

/// Converts a base price (store currency) to the currently selected currency.
extension CurrencyConversion on WidgetRef {
  double convertPrice(double? basePrice) {
    if (basePrice == null) return 0.0;
    final currency = read(selectedCurrencyProvider);
    return basePrice * currency.rate;
  }
}

extension CurrencyConversionOnNum on num {
  double convertWith(Currency currency) {
    return toDouble() * currency.rate;
  }
}
