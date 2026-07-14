import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

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
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double total,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('🛍️ *طلب جديد من $storeName*');
    buffer.writeln('');
    
    if (customerName != null) {
      buffer.writeln('👤 *الاسم:* $customerName');
    }
    if (customerPhone != null) {
      buffer.writeln('📱 *الهاتف:* $customerPhone');
    }
    if (customerAddress != null) {
      buffer.writeln('📍 *العنوان:* $customerAddress');
    }
    buffer.writeln('');
    
    buffer.writeln('*المنتجات:*');
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('${i + 1}. ${item['name']} x${item['quantity']} - ${item['price']}');
      if (item['attributes'] != null) {
        buffer.writeln('   ${item['attributes']}');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('💰 *المجموع:* ${total.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('تم إرسال الطلب من تطبيق Storefolio 📲');
    
    return buffer.toString();
  }
}
