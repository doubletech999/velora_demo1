// lib/data/repositories/user_repository.dart
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserRepository {
  final AuthService _authService = AuthService.instance;

  // ═══════════════════════════════════════════════════════════════════
  // Authentication Methods
  // ═══════════════════════════════════════════════════════════════════

  /// تسجيل مستخدم جديد
  Future<AuthMessageResult> register(
    String name,
    String email,
    String password, {
    String? phone,
    String? role,
    String? language,
  }) async {
    try {
      return await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        language: language ?? 'ar',
      );
    } catch (e) {
      throw Exception('فشل التسجيل: ${e.toString()}');
    }
  }

  /// تسجيل الدخول
  Future<AuthLoginResult> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      return await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  Future<AuthMessageResult> resendVerificationEmail(String email) async {
    try {
      return await _authService.resendVerificationEmail(email);
    } catch (e) {
      throw Exception('فشل إرسال رابط التحقق: ${e.toString()}');
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      throw Exception('فشل تسجيل الخروج: ${e.toString()}');
    }
  }

  /// الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      print('خطأ في الحصول على المستخدم: $e');
      return null;
    }
  }

  /// التحقق من تسجيل الدخول
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Profile Methods
  // ═══════════════════════════════════════════════════════════════════

  /// تحديث الملف الشخصي
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final data = {
        'name': user.name,
        'email': user.email,
        'preferred_language': user.preferredLanguage,
      };

      return await _authService.updateProfile(data);
    } catch (e) {
      throw Exception('فشل تحديث الملف الشخصي: ${e.toString()}');
    }
  }

  /// تحديث كلمة المرور
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
    } catch (e) {
      throw Exception('فشل تحديث كلمة المرور: ${e.toString()}');
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    try {
      await _authService.apiService.deleteAccount();
      await _authService.clearAll();
    } catch (e) {
      throw Exception('فشل حذف الحساب: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Storage Methods
  // ═══════════════════════════════════════════════════════════════════

  /// حفظ المستخدم محلياً
  Future<void> saveUserLocally(UserModel user) async {
    await _authService.saveUser(user);
  }

  /// الحصول على المستخدم المحفوظ محلياً
  Future<UserModel?> getStoredUser() async {
    return await _authService.getStoredUser();
  }

  /// مسح بيانات المستخدم المحلية
  Future<void> clearLocalUser() async {
    await _authService.clearUser();
  }
}
