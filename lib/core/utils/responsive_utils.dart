// lib/core/utils/responsive_utils.dart - نسخة محدثة لدعم جميع الأجهزة
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ResponsiveUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  
  // معايير الأجهزة المحسنة
  static late bool isMobile;
  static late bool isTablet;
  static late bool isDesktop;
  static late bool isSmallPhone;
  static late bool isLargePhone;
  static late bool isIOS;
  static late bool isAndroid;
  static late bool isWeb;
  
  // أحجام النصوص المتكيفة
  static late double textScaleFactor;
  static late double defaultTextSize;
  static late double smallTextSize;
  static late double mediumTextSize;
  static late double largeTextSize;
  static late double extraLargeTextSize;
  
  // المساحات المتكيفة
  static late double defaultSpace;
  static late double extraSmallSpace;
  static late double smallSpace;
  static late double mediumSpace;
  static late double largeSpace;
  static late double extraLargeSpace;
  
  // حواف آمنة للأجهزة ذات الشاشات المنحنية
  static late EdgeInsets safePadding;
  
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    
    // حساب المناطق الآمنة
    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    
    // الحواف الآمنة
    safePadding = _mediaQueryData.padding;
    
    // تحديد نوع الجهاز بشكل أكثر دقة
    isSmallPhone = screenWidth < 360;  // أجهزة صغيرة جداً
    isMobile = screenWidth < 600;
    isLargePhone = screenWidth >= 360 && screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 1200;
    isDesktop = screenWidth >= 1200;
    
    // تحديد نظام التشغيل
    isWeb = kIsWeb;
    if (!isWeb) {
      isIOS = Platform.isIOS;
      isAndroid = Platform.isAndroid;
    } else {
      isIOS = false;
      isAndroid = false;
    }
    
    // عامل تكبير النص من إعدادات النظام
    textScaleFactor = _mediaQueryData.textScaleFactor.clamp(0.8, 1.3);
    
    // حجم الخط المتكيف مع حجم الشاشة وإعدادات النظام
    if (isSmallPhone) {
      defaultTextSize = 12 * textScaleFactor;
      smallTextSize = 10 * textScaleFactor;
      mediumTextSize = 14 * textScaleFactor;
      largeTextSize = 16 * textScaleFactor;
      extraLargeTextSize = 20 * textScaleFactor;
    } else if (isMobile) {
      defaultTextSize = 14 * textScaleFactor;
      smallTextSize = 12 * textScaleFactor;
      mediumTextSize = 16 * textScaleFactor;
      largeTextSize = 18 * textScaleFactor;
      extraLargeTextSize = 24 * textScaleFactor;
    } else if (isTablet) {
      defaultTextSize = 16 * textScaleFactor;
      smallTextSize = 14 * textScaleFactor;
      mediumTextSize = 18 * textScaleFactor;
      largeTextSize = 22 * textScaleFactor;
      extraLargeTextSize = 28 * textScaleFactor;
    } else {
      defaultTextSize = 18 * textScaleFactor;
      smallTextSize = 16 * textScaleFactor;
      mediumTextSize = 20 * textScaleFactor;
      largeTextSize = 24 * textScaleFactor;
      extraLargeTextSize = 32 * textScaleFactor;
    }
    
    // المساحات المتكيفة
    if (isSmallPhone) {
      extraSmallSpace = 2;
      smallSpace = 4;
      defaultSpace = 8;
      mediumSpace = 12;
      largeSpace = 16;
      extraLargeSpace = 24;
    } else if (isMobile) {
      extraSmallSpace = 4;
      smallSpace = 8;
      defaultSpace = 16;
      mediumSpace = 24;
      largeSpace = 32;
      extraLargeSpace = 48;
    } else if (isTablet) {
      extraSmallSpace = 6;
      smallSpace = 12;
      defaultSpace = 20;
      mediumSpace = 32;
      largeSpace = 48;
      extraLargeSpace = 64;
    } else {
      extraSmallSpace = 8;
      smallSpace = 16;
      defaultSpace = 24;
      mediumSpace = 40;
      largeSpace = 64;
      extraLargeSpace = 80;
    }
  }
  
  // دالة للحصول على عرض متجاوب
  static double getResponsiveWidth(double percentage) {
    return safeBlockHorizontal * percentage;
  }

  // دالة للحصول على ارتفاع متجاوب
  static double getResponsiveHeight(double percentage) {
    return safeBlockVertical * percentage;
  }
  
  // دالة محسنة للحصول على padding متجاوب
  static EdgeInsets getResponsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(getAdaptiveValue(all));
    }
    
    return EdgeInsets.only(
      left: left != null ? getAdaptiveValue(left) : 
            (horizontal != null ? getAdaptiveValue(horizontal) : 0),
      right: right != null ? getAdaptiveValue(right) : 
             (horizontal != null ? getAdaptiveValue(horizontal) : 0),
      top: top != null ? getAdaptiveValue(top) : 
           (vertical != null ? getAdaptiveValue(vertical) : 0),
      bottom: bottom != null ? getAdaptiveValue(bottom) : 
              (vertical != null ? getAdaptiveValue(vertical) : 0),
    );
  }
  
  // دالة للحصول على قيمة متكيفة بناءً على حجم الشاشة
  static double getAdaptiveValue(double baseValue) {
    if (isSmallPhone) {
      return baseValue * 0.8;
    } else if (isMobile) {
      return baseValue;
    } else if (isTablet) {
      return baseValue * 1.2;
    } else {
      return baseValue * 1.5;
    }
  }
  
  // دالة محسنة للحصول على حجم خط متجاوب
  static double getResponsiveFontSize(double baseSize) {
    double scaledSize;
    
    if (isSmallPhone) {
      scaledSize = baseSize * 0.85;
    } else if (isMobile) {
      scaledSize = baseSize;
    } else if (isTablet) {
      scaledSize = baseSize * 1.1;
    } else {
      scaledSize = baseSize * 1.2;
    }
    
    // تطبيق عامل تكبير النص من إعدادات النظام
    scaledSize = scaledSize * textScaleFactor;
    
    // تحديد حد أدنى وحد أقصى لحجم الخط
    return scaledSize.clamp(10.0, 40.0);
  }
  
  // دالة للحصول على ارتفاع مناسب للأزرار
  static double getButtonHeight() {
    if (isSmallPhone) return 42;
    if (isMobile) return 48;
    if (isTablet) return 56;
    return 60;
  }
  
  // دالة للحصول على حجم الأيقونات
  static double getIconSize({bool isLarge = false}) {
    if (isLarge) {
      if (isSmallPhone) return 28;
      if (isMobile) return 32;
      if (isTablet) return 40;
      return 48;
    } else {
      if (isSmallPhone) return 20;
      if (isMobile) return 24;
      if (isTablet) return 28;
      return 32;
    }
  }
  
  // دالة للتحقق من اتجاه الشاشة
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // دالة للحصول على عدد الأعمدة في الشبكة
  static int getGridColumns() {
    if (isSmallPhone) return 1;
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }
  
  // دالة للحصول على نسبة العرض إلى الارتفاع للبطاقات
  static double getCardAspectRatio() {
    if (isSmallPhone) return 1.0;
    if (isMobile) return 1.0;
    if (isTablet) return 1.1;
    return 1.2;
  }
  
  // دالة للحصول على نسبة العرض إلى الارتفاع للبطاقات العمودية (مثل بطاقات الأنشطة)
  static double getVerticalCardAspectRatio() {
    if (isSmallPhone) return 0.9;
    if (isMobile) return 0.95;
    if (isTablet) return 1.0;
    return 1.05;
  }
  
  // دالة للحصول على قيمة متجاوبة حسب نوع الجهاز
  static T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// امتداد محسن لسهولة الاستخدام
extension ResponsiveExtension on BuildContext {
  // معلومات الشاشة
  double get screenWidth => ResponsiveUtils.screenWidth;
  double get screenHeight => ResponsiveUtils.screenHeight;
  EdgeInsets get safePadding => ResponsiveUtils.safePadding;
  
  // نوع الجهاز
  bool get isSmallPhone => ResponsiveUtils.isSmallPhone;
  bool get isMobile => ResponsiveUtils.isMobile;
  bool get isTablet => ResponsiveUtils.isTablet;
  bool get isDesktop => ResponsiveUtils.isDesktop;
  bool get isIOS => ResponsiveUtils.isIOS;
  bool get isAndroid => ResponsiveUtils.isAndroid;
  
  // المساحات المتكيفة
  double get xs => ResponsiveUtils.extraSmallSpace;
  double get sm => ResponsiveUtils.smallSpace;
  double get md => ResponsiveUtils.mediumSpace;
  double get lg => ResponsiveUtils.largeSpace;
  double get xl => ResponsiveUtils.extraLargeSpace;
  double get xxl => ResponsiveUtils.extraLargeSpace; // إضافة xxl
  
  // أحجام النصوص المتكيفة
  double get textXs => ResponsiveUtils.smallTextSize;
  double get textSm => ResponsiveUtils.defaultTextSize;
  double get textMd => ResponsiveUtils.mediumTextSize;
  double get textLg => ResponsiveUtils.largeTextSize;
  double get textXl => ResponsiveUtils.extraLargeTextSize;
  
  // دوال مساعدة
  double rw(double percentage) => ResponsiveUtils.getResponsiveWidth(percentage);
  double rh(double percentage) => ResponsiveUtils.getResponsiveHeight(percentage);
  double fontSize(double size) => ResponsiveUtils.getResponsiveFontSize(size);
  double adaptive(double value) => ResponsiveUtils.getAdaptiveValue(value);
  
  // أحجام العناصر
  double get buttonHeight => ResponsiveUtils.getButtonHeight();
  double iconSize({bool isLarge = false}) => ResponsiveUtils.getIconSize(isLarge: isLarge);
  int get gridColumns => ResponsiveUtils.getGridColumns();
  double get cardAspectRatio => ResponsiveUtils.getCardAspectRatio();
  double get verticalCardAspectRatio => ResponsiveUtils.getVerticalCardAspectRatio();
  
  // الحصول على padding متجاوب
  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return ResponsiveUtils.getResponsivePadding(
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      left: left,
      right: right,
      top: top,
      bottom: bottom,
    );
  }
  
  // دالة responsive للحصول على قيم مختلفة حسب الجهاز
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return ResponsiveUtils.responsive(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}