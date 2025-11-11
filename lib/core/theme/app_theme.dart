// lib/core/theme/app_theme.dart - وضع داكن احترافي حقيقي
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ====== الوضع الفاتح (بدون تغيير) ======
  static ThemeData lightTheme(String languageCode) {
    final isArabic = languageCode == 'ar';

    return ThemeData(
      useMaterial3: true,
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      fontFamilyFallback:
          isArabic
              ? ['Noto Sans Arabic', 'Noto Sans', 'Arial', 'sans-serif']
              : ['Noto Sans', 'Arial', 'sans-serif'],
      brightness: Brightness.light,

      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF212121),
      ),

      textTheme: _buildTextTheme(
        isArabic,
        const Color(0xFF212121),
        const Color(0xFF757575),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: _getTextStyle(
          isArabic,
          20,
          FontWeight.bold,
          AppColors.primary,
        ),
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _getTextStyle(isArabic, 16, FontWeight.w600, Colors.white),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _getTextStyle(
            isArabic,
            16,
            FontWeight.w600,
            AppColors.primary,
          ),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _getTextStyle(
            isArabic,
            16,
            FontWeight.w600,
            AppColors.primary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isArabic ? 20 : 18,
        ),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: _getTextStyle(
          isArabic,
          12,
          FontWeight.w500,
          AppColors.primary,
        ),
        unselectedLabelStyle: _getTextStyle(
          isArabic,
          12,
          FontWeight.normal,
          const Color(0xFF757575),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: _getTextStyle(
          isArabic,
          18,
          FontWeight.bold,
          const Color(0xFF212121),
        ),
        contentTextStyle: _getTextStyle(
          isArabic,
          14,
          FontWeight.normal,
          const Color(0xFF212121),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFF212121),
        iconColor: Color(0xFF757575),
      ),

      iconTheme: const IconThemeData(color: Color(0xFF757575)),

      dividerTheme: DividerThemeData(color: Colors.grey[300], thickness: 1),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: _getTextStyle(
          isArabic,
          14,
          FontWeight.w500,
          AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.grey[300];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.grey[400];
        }),
      ),
    );
  }

  // ====== الوضع الداكن المحسّن ======
  static ThemeData darkTheme(String languageCode) {
    final isArabic = languageCode == 'ar';

    // ألوان مخصصة للوضع الداكن - محسنة للوضوح والتباين
    const darkBg = Color(0xFF0D0D0D); // خلفية رئيسية - أغمق للتباين الأفضل
    const darkSurface = Color(0xFF1A1A1A); // سطح العناصر - أغمق قليلاً
    const darkCard = Color(0xFF262626); // الكروت - محسّن للتباين
    const darkElevatedCard = Color(0xFF2D2D2D); // كروت مرتفعة
    const darkText = Color(0xFFF5F5F5); // نص رئيسي - أوضح
    const darkTextSecondary = Color(0xFFB8B8B8); // نص ثانوي

    return ThemeData(
      useMaterial3: true,
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      fontFamilyFallback:
          isArabic
              ? ['Noto Sans Arabic', 'Noto Sans', 'Arial', 'sans-serif']
              : ['Noto Sans', 'Arial', 'sans-serif'],
      brightness: Brightness.dark,

      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: darkBg,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
      ),

      textTheme: _buildTextTheme(isArabic, darkText, darkTextSecondary),

      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: _getTextStyle(
          isArabic,
          20,
          FontWeight.bold,
          AppColors.primary,
        ),
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _getTextStyle(isArabic, 16, FontWeight.w600, Colors.white),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _getTextStyle(
            isArabic,
            16,
            FontWeight.w600,
            AppColors.primary,
          ),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _getTextStyle(
            isArabic,
            16,
            FontWeight.w600,
            AppColors.primary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkElevatedCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isArabic ? 20 : 18,
        ),
        hintStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: _getTextStyle(
          isArabic,
          12,
          FontWeight.w500,
          AppColors.primary,
        ),
        unselectedLabelStyle: _getTextStyle(
          isArabic,
          12,
          FontWeight.normal,
          darkTextSecondary,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: _getTextStyle(isArabic, 18, FontWeight.bold, darkText),
        contentTextStyle: _getTextStyle(
          isArabic,
          14,
          FontWeight.normal,
          darkText,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      listTileTheme: ListTileThemeData(
        textColor: darkText,
        iconColor: darkTextSecondary,
        tileColor: darkCard,
        selectedTileColor: AppColors.primary.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),

      iconTheme: const IconThemeData(color: darkTextSecondary),

      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.15),
        thickness: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: AppColors.primary.withOpacity(0.3),
        labelStyle: _getTextStyle(isArabic, 14, FontWeight.w500, darkText),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.grey[600];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.grey[800];
        }),
      ),
    );
  }

  // ====== Helper Methods ======

  static TextTheme _buildTextTheme(
    bool isArabic,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return TextTheme(
      displayLarge: _getTextStyle(isArabic, 32, FontWeight.bold, primaryColor),
      displayMedium: _getTextStyle(isArabic, 28, FontWeight.bold, primaryColor),
      displaySmall: _getTextStyle(isArabic, 24, FontWeight.bold, primaryColor),
      headlineLarge: _getTextStyle(isArabic, 22, FontWeight.bold, primaryColor),
      headlineMedium: _getTextStyle(
        isArabic,
        20,
        FontWeight.bold,
        primaryColor,
      ),
      headlineSmall: _getTextStyle(isArabic, 18, FontWeight.bold, primaryColor),
      titleLarge: _getTextStyle(isArabic, 18, FontWeight.w600, primaryColor),
      titleMedium: _getTextStyle(isArabic, 16, FontWeight.w600, primaryColor),
      titleSmall: _getTextStyle(isArabic, 14, FontWeight.w600, primaryColor),
      bodyLarge: _getTextStyle(isArabic, 16, FontWeight.normal, primaryColor),
      bodyMedium: _getTextStyle(isArabic, 14, FontWeight.normal, primaryColor),
      bodySmall: _getTextStyle(isArabic, 12, FontWeight.normal, secondaryColor),
      labelLarge: _getTextStyle(isArabic, 14, FontWeight.w500, primaryColor),
      labelMedium: _getTextStyle(isArabic, 12, FontWeight.w500, primaryColor),
      labelSmall: _getTextStyle(isArabic, 10, FontWeight.w500, secondaryColor),
    );
  }

  static TextStyle _getTextStyle(
    bool isArabic,
    double fontSize,
    FontWeight fontWeight,
    Color? color,
  ) {
    if (isArabic) {
      return GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: 1.5,
        textBaseline: TextBaseline.alphabetic,
      ).copyWith(
        fontFamilyFallback: ['Noto Sans Arabic', 'Noto Sans', 'Arial'],
      );
    } else {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: 1.3,
      ).copyWith(fontFamilyFallback: ['Noto Sans', 'Arial']);
    }
  }
}
