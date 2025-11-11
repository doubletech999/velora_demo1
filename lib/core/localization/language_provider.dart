// lib/core/localization/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'ar';
  
  String get currentLanguage => _currentLanguage;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'ar';
    notifyListeners();
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      notifyListeners();
    }
  }
  
  bool get isArabic => _currentLanguage == 'ar';
  bool get isEnglish => _currentLanguage == 'en';
  
  TextDirection get textDirection => 
      isArabic ? TextDirection.rtl : TextDirection.ltr;
      
  // إضافة دعم أفضل للنصوص المحلية
  String getText(String arabicText, String englishText) {
    return isArabic ? arabicText : englishText;
  }
}