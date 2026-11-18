import 'dart:html' as html;

class LinkService {
  static String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static Future<bool> launchPhone(String phoneNumber) async {
    final clean = _cleanPhone(phoneNumber);
    if (clean.isEmpty) return false;
    try {
      html.window.open('tel:$clean', '_self');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return false;

    final queryParams = <String>[];
    if (subject != null && subject.isNotEmpty) {
      queryParams.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null && body.isNotEmpty) {
      queryParams.add('body=${Uri.encodeComponent(body)}');
    }

    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final mailtoUrl = 'mailto:$cleanEmail$query';

    try {
      html.window.open(mailtoUrl, '_self');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> launchWebUrl(String url) async {
    final targetUrl = url.trim();
    if (targetUrl.isEmpty) return false;
    try {
      html.window.open(targetUrl, '_blank');
      return true;
    } catch (_) {
      return false;
    }
  }

  static void printPage() {
    try {
      html.window.print();
    } catch (_) {}
  }
}
