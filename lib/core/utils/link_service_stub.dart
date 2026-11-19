import '../../models/udb_record.dart';
import '../../models/user_session.dart';

class LinkService {
  static Future<bool> launchPhone(String phoneNumber) async {
    return true;
  }

  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    return true;
  }

  static Future<bool> launchWebUrl(String url) async {
    return true;
  }

  static void printPage() {}

  static void printHtmlDocument({required String title, required String htmlContent}) {}

  static void printGazetteNotice(UdbRecord record) {}

  static void printOfficialDossier(UdbRecord record, UserSession session) {}
}
