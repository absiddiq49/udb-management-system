import 'package:flutter/material.dart';

enum AppLanguage { bangla, english }

class LocaleProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.bangla; // Default to Bangla for BD users, easily switchable

  AppLanguage get language => _language;
  bool get isBangla => _language == AppLanguage.bangla;
  bool get isEnglish => _language == AppLanguage.english;

  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _language = _language == AppLanguage.bangla ? AppLanguage.english : AppLanguage.bangla;
    notifyListeners();
  }

  /// Convenient inline translation helper
  String tr(String en, String bn) {
    return _language == AppLanguage.bangla ? bn : en;
  }
}
