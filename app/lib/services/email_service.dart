import 'package:url_launcher/url_launcher.dart';

class EmailService {
  static Future<void> sendAlertEmail({
    required String recipientEmail,
    String subject = 'Water Monitoring System Alert',
    String body = 'Alert from Water Monitoring System',
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: recipientEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      throw Exception('Error launching email: $e');
    }
  }

  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
