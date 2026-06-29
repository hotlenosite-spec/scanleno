import 'package:url_launcher/url_launcher.dart';

class CheckoutLauncher {
  Future<void> open(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, webOnlyWindowName: '_self');
    if (!opened) throw UnsupportedError('checkout_url_not_opened');
  }
}

CheckoutLauncher createCheckoutLauncher() => CheckoutLauncher();
