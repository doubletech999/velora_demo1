// lib/core/utils/validators.dart
class Validators {
  // التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    
    return null;
  }

  // التحقق من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }

  // التحقق من تطابق كلمة المرور
  static String? validatePasswordMatch(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  // التحقق من الاسم
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    
    if (value.length > 50) {
      return 'الاسم طويل جداً';
    }
    
    return null;
  }

  // التحقق من رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختياري
    }
    
    // إزالة المسافات والأقواس والشرطات
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'رقم الهاتف غير صالح';
    }
    
    return null;
  }

  // التحقق من الحقل المطلوب
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  // التحقق من طول النص
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $minLength أحرف على الأقل';
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب ألا يتجاوز $maxLength حرف';
    }

    return null;
  }

  // التحقق من الأرقام فقط
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  // التحقق من الحروف فقط
  static String? validateAlpha(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (!RegExp(r'^[a-zA-Zأ-ي\s]+$').hasMatch(value)) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  // التحقق من URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرابط مطلوب';
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-])\/?$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'الرجاء إدخال رابط صحيح';
    }

    return null;
  }

  // التحقق من التاريخ
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'التاريخ مطلوب';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'الرجاء إدخال تاريخ صحيح';
    }
  }

  // التحقق من أن التاريخ في المستقبل
  static String? validateFutureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'التاريخ مطلوب';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return 'التاريخ يجب أن يكون في المستقبل';
      }
      return null;
    } catch (e) {
      return 'الرجاء إدخال تاريخ صحيح';
    }
  }

  // التحقق من أن التاريخ في الماضي
  static String? validatePastDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'التاريخ مطلوب';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'التاريخ يجب أن يكون في الماضي';
      }
      return null;
    } catch (e) {
      return 'الرجاء إدخال تاريخ صحيح';
    }
  }

  // التحقق من العمر (18 سنة على الأقل)
  static String? validateAge(String? value, {int minimumAge = 18}) {
    if (value == null || value.isEmpty) {
      return 'تاريخ الميلاد مطلوب';
    }

    try {
      final birthDate = DateTime.parse(value);
      final today = DateTime.now();
      final age = today.year - birthDate.year;

      if (age < minimumAge) {
        return 'يجب أن يكون عمرك $minimumAge سنة على الأقل';
      }

      return null;
    } catch (e) {
      return 'الرجاء إدخال تاريخ ميلاد صحيح';
    }
  }

  // التحقق من كلمة المرور القوية
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    // التحقق من وجود حرف كبير وصغير ورقم ورمز خاص
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    if (!hasLowercase) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    if (!hasDigits) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    if (!hasSpecialChar) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    }

    return null;
  }

  // التحقق من الرمز البريدي
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرمز البريدي مطلوب';
    }

    if (!RegExp(r'^[0-9]{5}$').hasMatch(value)) {
      return 'الرمز البريدي يجب أن يكون 5 أرقام';
    }

    return null;
  }

  // التحقق من رقم البطاقة الائتمانية
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم البطاقة مطلوب';
    }

    // إزالة المسافات
    final cleanValue = value.replaceAll(' ', '');

    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cleanValue)) {
      return 'رقم البطاقة غير صالح';
    }

    return null;
  }

  // دالة مساعدة لحساب قوة كلمة المرور
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // الطول
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // الحروف الكبيرة
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

    // الحروف الصغيرة
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;

    // الأرقام
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

    // الرموز الخاصة
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return strength.clamp(0.0, 1.0);
  }

  // دالة مساعدة للحصول على نص قوة كلمة المرور
  static String getPasswordStrengthText(double strength) {
    if (strength < 0.3) return 'ضعيفة جداً';
    if (strength < 0.5) return 'ضعيفة';
    if (strength < 0.7) return 'متوسطة';
    if (strength < 0.9) return 'قوية';
    return 'قوية جداً';
  }

  // دالة مساعدة للحصول على لون قوة كلمة المرور
  static String getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return '#EF4444'; // أحمر
    if (strength < 0.5) return '#F59E0B'; // برتقالي
    if (strength < 0.7) return '#EAB308'; // أصفر
    if (strength < 0.9) return '#10B981'; // أخضر
    return '#059669'; // أخضر داكن
  }
}