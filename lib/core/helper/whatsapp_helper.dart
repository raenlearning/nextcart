import 'package:nextcart/core/constants/store_info.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  WhatsAppHelper._();

  /// Buka chat WhatsApp langsung ke aplikasi (bukan browser).
  /// Fallback ke wa.me bila scheme whatsapp:// tidak tersedia.
  static Future<void> openChat(String message) async {
    final encoded = Uri.encodeComponent(message);
    final phone = StoreInfo.whatsappNumber;

    final appUri =
        Uri.parse('whatsapp://send?phone=$phone&text=$encoded');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    final webUri = Uri.parse('https://wa.me/$phone?text=$encoded');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
