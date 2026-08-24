import 'package:url_launcher/url_launcher.dart';

import 'services.dart';

class OpenLinkService extends Services {
  Future<void> openUrl({required String link}) async {
    final uri = Uri.parse(link);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $link');
    }
  }
}
