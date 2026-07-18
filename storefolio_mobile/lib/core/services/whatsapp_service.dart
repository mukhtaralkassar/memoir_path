import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';
import '../models/currency.dart';
import '../models/store.dart';
import '../models/cart_item.dart';
import '../utils/price_formatter.dart';

class WhatsAppService {
  static final Logger _logger = Logger();

  static Future<bool> openWhatsApp({
    required String phone,
    String? message,
  }) async {
    try {
      // Clean phone number
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      
      final uri = Uri.parse(
        'https://wa.me/$cleanPhone${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        _logger.w('Cannot launch WhatsApp URI: $uri');
        return false;
      }
    } catch (e) {
      _logger.e('Error opening WhatsApp: $e');
      return false;
    }
  }

  static String generateOrderMessage({
    required Store store,
    required List<CartItem> items,
    double? deliveryFee,
    String? customTemplate,
    String? storeLink,
    bool isWholesale = false,
    Currency? currency,
    String? locale,
  }) {
    final storeDisplayName = store.displayName;
    final selectedCurrency = currency ?? Currency(id: 0, name: store.currency ?? 'USD', symbol: store.currencySymbol ?? r'$', code: store.currency ?? 'USD', rate: 1.0, isDefault: true, showExchangeRate: true);
    final lang = _resolveLang(store.whatsAppLang);

    final lines = items.map((item) {
      var line = '${item.name} ×${item.quantity} - ${PriceFormatter.format(item.price, currency: selectedCurrency, locale: locale ?? lang)}';
      if (item.selectedAttributes != null && item.selectedAttributes!.isNotEmpty) {
        line += '\n   ${item.selectedAttributes}';
      }
      return line;
    }).toList();

    final subtotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    var total = subtotal;
    var deliveryText = '';
    if (deliveryFee != null && deliveryFee > 0) {
      deliveryText = '\n📦 ${_deliveryLabel(lang)}: ${PriceFormatter.format(deliveryFee, currency: selectedCurrency, locale: locale ?? lang)}';
      total += deliveryFee;
    } else if (store.hasDelivery == true) {
      deliveryText = '\n📦 ${_deliveryLabel(lang)}: ${_freeDeliveryLabel(lang)}';
    }

    final formattedTotal = PriceFormatter.format(total, currency: selectedCurrency, locale: locale ?? lang);
    String message;
    if (customTemplate != null && customTemplate.isNotEmpty) {
      final productNames = items.map((i) => i.name).join(', ');
      final totalQty = items.fold(0, (sum, i) => sum + i.quantity);
      message = customTemplate
          .replaceAll('{product}', productNames)
          .replaceAll('{quantity}', totalQty.toString())
          .replaceAll('{price}', formattedTotal)
          .replaceAll('{store}', storeDisplayName)
          .replaceAll('{link}', storeLink ?? '');
    } else if (lang == 'en') {
      message = 'Hello $storeDisplayName,\nI want to order:\n${lines.join('\n')}$deliveryText\n\nTotal: $formattedTotal\nStore: ${storeLink ?? ''}';
    } else {
      message = 'مرحباً $storeDisplayName،\nأريد طلب:\n${lines.join('\n')}$deliveryText\n\nالمجموع: $formattedTotal\nالمتجر: ${storeLink ?? ''}';
    }

    final customerTypeText = isWholesale
        ? (lang == 'en' ? '🏪 Wholesale' : '🏪 تاجر جملة')
        : (lang == 'en' ? '🛍️ Retail Customer' : '🛍️ عميل مفرق');

    return '$customerTypeText\n$message';
  }

  static String _resolveLang(String? waLang) {
    if (waLang == 'Ar') return 'ar';
    if (waLang == 'En') return 'en';
    return 'ar';
  }

  static String _deliveryLabel(String lang) {
    return lang == 'en' ? 'Delivery' : 'توصيل';
  }

  static String _freeDeliveryLabel(String lang) {
    return lang == 'en' ? 'Free' : 'مجاني';
  }
}
