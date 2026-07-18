import 'package:intl/intl.dart';

import '../models/currency.dart';

/// Converts and formats prices using a server-driven currency.
class PriceFormatter {
  /// Formats a base price (in store default currency) to the selected currency.
  static String format(
    double? price, {
    required Currency currency,
    String? locale,
    bool showSymbol = true,
  }) {
    if (price == null) return showSymbol ? '${currency.symbol}0.00' : '0.00';

    final converted = price * currency.rate;
    final numberFormat = NumberFormat(
      showSymbol ? '###,##0.00' : '###,##0.00',
      locale ?? 'en',
    );
    final formatted = numberFormat.format(converted);

    return showSymbol ? '${currency.symbol}$formatted' : formatted;
  }

  /// Same as [format] but with currency code appended.
  static String formatWithCode(
    double? price, {
    required Currency currency,
    String? locale,
  }) {
    if (price == null) return '${currency.symbol}0.00 ${currency.code}';
    final converted = price * currency.rate;
    final formatted = NumberFormat('###,##0.00', locale ?? 'en').format(converted);
    return '${currency.symbol}$formatted ${currency.code}';
  }

  /// Convert a base price to the selected currency value.
  static double convert(double? price, Currency currency) {
    if (price == null) return 0.0;
    return price * currency.rate;
  }
}
