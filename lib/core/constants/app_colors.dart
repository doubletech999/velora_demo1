// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ألوان أساسية محسنة
  static const Color primary = Color(0xFF0F9D58); // أخضر من الشعار (محافظة على اللون الأصلي)
  static const Color secondary = Color(0xFFFF4B4B); // أحمر من الشعار (محافظة على اللون الأصلي)
  static const Color tertiary = Color(0xFF4285F4); // أزرق متناسق مع الألوان الأخرى
  
  // ألوان الخلفية والسطح
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  
  // ألوان الحالة
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);
  
  // ألوان النص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFEEEEEE);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // عناصر واجهة المستخدم الأخرى
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  
  // تدرجات الألوان
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00796B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [primary, Color(0xFF00796B), Color(0xFF00695C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // تدرجات للبطاقات المميزة
  static const LinearGradient featuredCardGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ألوان الصعوبة
  static const Color difficultyEasy = Color(0xFF4CAF50);
  static const Color difficultyMedium = Color(0xFFFFC107);
  static const Color difficultyHard = Color(0xFFF44336);
}