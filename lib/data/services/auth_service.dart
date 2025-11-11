// lib/data/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  final ApiService _apiService = ApiService();

  // مفاتيح التخزين
  static const String _tokenKey = AppConstants.userTokenKey;
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  // ═══════════════════════════════════════════════════════════════════
  // Authentication Methods - طرق المصادقة
  // ═══════════════════════════════════════════════════════════════════

  /// تسجيل مستخدم جديد
  Future<AuthMessageResult> register({
    required String name,
    required String email,
    required String password,
    String? role,
    String? language,
  }) async {
    try {
      print('🔄 AuthService: بدء عملية التسجيل...');
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: password,
        role: role,
        language: language ?? 'ar',
      );

      print('✅ AuthService: استجابة التسجيل: $response');

      final bool status =
          response['status'] == true || response['success'] == true;
      final String message =
          response['message']?.toString().trim().isNotEmpty == true
              ? response['message'].toString()
              : 'تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني.';

      if (!status) {
        final String error =
            response['error']?.toString().trim().isNotEmpty == true
                ? response['error'].toString()
                : message;
        print('❌ AuthService: فشل التسجيل بدون تفعيل البريد: $error');
        throw Exception(error);
      }

      print('✅ AuthService: التسجيل نجح وينتظر التحقق من البريد');
      return AuthMessageResult(success: true, message: message);
    } catch (e, stackTrace) {
      print('❌ AuthService: خطأ في التسجيل: $e');
      print(
        '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}...',
      );
      throw Exception('فشل التسجيل: ${e.toString()}');
    }
  }

  /// تسجيل الدخول
  Future<AuthLoginResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      print('🔄 AuthService: بدء عملية تسجيل الدخول...');
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      print('✅ AuthService: استجابة تسجيل الدخول: $response');

      // دعم أشكال مختلفة من الاستجابة
      String? token;
      Map<String, dynamic>? userData;

      // محاولة 1: إذا كانت الاستجابة تحتوي على token و user مباشرة
      if (response['token'] != null && response['user'] != null) {
        token = response['token'].toString();
        userData =
            response['user'] is Map
                ? response['user'] as Map<String, dynamic>
                : null;
        print('✅ AuthService: تم العثور على token و user مباشرة');
      }
      // محاولة 2: إذا كانت الاستجابة تحتوي على data
      else if (response['data'] != null) {
        final data = response['data'];
        if (data is Map) {
          token = data['token']?.toString();
          if (data['user'] != null) {
            userData =
                data['user'] is Map
                    ? data['user'] as Map<String, dynamic>
                    : null;
          } else if (data['id'] != null) {
            // إذا كان user data مباشرة في data
            userData = data as Map<String, dynamic>;
          }
          print('✅ AuthService: تم العثور على token و user في data');
        }
      }
      // محاولة 3: إذا كانت الاستجابة تحتوي على user و token في مستويات مختلفة
      else if (response['user'] != null) {
        userData =
            response['user'] is Map
                ? response['user'] as Map<String, dynamic>
                : null;
        // البحث عن token في response
        token =
            response['token']?.toString() ??
            response['access_token']?.toString() ??
            response['auth_token']?.toString();
        print('✅ AuthService: تم العثور على user و token منفصل');
      }

      // التحقق من وجود token و userData
      if (token == null || token.isEmpty) {
        print('❌ AuthService: Token مفقود في الاستجابة');
        throw Exception('فشل تسجيل الدخول: Token مفقود في الاستجابة');
      }

      if (userData == null) {
        print('❌ AuthService: User data مفقود في الاستجابة');
        throw Exception('فشل تسجيل الدخول: User data مفقود في الاستجابة');
      }

      print('✅ AuthService: Token: ${token.substring(0, 20)}...');
      print('✅ AuthService: User Data: $userData');
      print('✅ AuthService: Remember Me: $rememberMe');

      // حفظ Token
      await saveToken(token);
      _apiService.setAuthToken(token);

      // حفظ حالة "تذكرني"
      await saveRememberMe(rememberMe);
      print('✅ AuthService: تم حفظ حالة تذكرني: $rememberMe');

      // إنشاء UserModel
      final user = UserModel.fromJson(userData);
      print('✅ AuthService: تم إنشاء UserModel: ${user.name} (${user.email})');

      // حفظ بيانات المستخدم
      await saveUser(user);
      print('✅ AuthService: تم حفظ بيانات المستخدم');

      return AuthLoginResult(
        success: true,
        message: response['message']?.toString() ?? 'تم تسجيل الدخول بنجاح',
        token: token,
        user: user,
      );
    } on UnauthorizedException catch (e, stackTrace) {
      final message = e.message.isNotEmpty ? e.message : 'البريد غير مفعل';
      print('❌ AuthService: UnauthorizedException: $message');
      print(
        '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}...',
      );

      if (message.toLowerCase().contains('email not verified')) {
        return AuthLoginResult(
          success: false,
          message: message,
          requiresEmailVerification: true,
        );
      }

      return AuthLoginResult(
        success: false,
        message: message,
        requiresEmailVerification: false,
      );
    } catch (e, stackTrace) {
      print('❌ AuthService: خطأ في تسجيل الدخول: $e');
      print(
        '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}...',
      );
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  /// إعادة إرسال رابط التحقق
  Future<AuthMessageResult> resendVerificationEmail(String email) async {
    try {
      print('🔄 AuthService: إعادة إرسال رابط التحقق للبريد $email');
      final response = await _apiService.resendVerificationEmail(email: email);
      final bool status =
          response['status'] == true || response['success'] == true;
      final String message =
          response['message']?.toString().trim().isNotEmpty == true
              ? response['message'].toString()
              : 'تم إرسال رابط التحقق إلى بريدك الإلكتروني.';

      if (!status) {
        final String error =
            response['error']?.toString().trim().isNotEmpty == true
                ? response['error'].toString()
                : message;
        throw Exception(error);
      }

      return AuthMessageResult(success: true, message: message);
    } catch (e, stackTrace) {
      print('❌ AuthService: خطأ في إعادة إرسال رابط التحقق: $e');
      print(
        '   StackTrace: ${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}...',
      );
      throw Exception('فشل إرسال رابط التحقق: ${e.toString()}');
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    // التحقق من وجود Token قبل محاولة تسجيل الخروج
    final token = await getToken();
    final hasToken = token != null && token.isNotEmpty;

    try {
      // استدعاء API للخروج فقط إذا كان هناك Token
      if (hasToken && _apiService.isAuthenticated) {
        try {
          await _apiService.logout();
        } catch (e) {
          // تجاهل خطأ 401 (Unauthenticated) لأنه يعني أن المستخدم مسجل خروج بالفعل
          if (e.toString().contains('401') ||
              e.toString().contains('Unauthenticated')) {
            print('المستخدم مسجل خروج بالفعل من السيرفر');
          } else {
            print('خطأ في تسجيل الخروج من API: $e');
          }
        }
      }
    } finally {
      // عند تسجيل الخروج، نحذف كل شيء (Token و User و rememberMe)
      // لأن المستخدم اختار تسجيل الخروج بشكل صريح
      print('🗑️ تسجيل الخروج - حذف جميع البيانات');
      await clearToken();
      await clearUser();
      await clearRememberMe();
      _apiService.clearAuthToken();
      print('✅ تم حذف جميع بيانات المصادقة');
    }
  }

  /// الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    try {
      // محاولة الحصول على المستخدم من التخزين المحلي أولاً
      final localUser = await getStoredUser();
      if (localUser != null) {
        return localUser;
      }

      // إذا لم يكن موجوداً محلياً، جلبه من الـ API
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        _apiService.setAuthToken(token);

        final response = await _apiService.getCurrentUser();
        final user = UserModel.fromJson(response['user']);

        // حفظ المستخدم محلياً
        await saveUser(user);

        return user;
      }

      return null;
    } catch (e) {
      print('خطأ في الحصول على المستخدم الحالي: $e');
      return null;
    }
  }

  /// تحديث الملف الشخصي
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.updateProfile(data);

      final user = UserModel.fromJson(response['user'] ?? response);

      // تحديث المستخدم المحفوظ محلياً
      await saveUser(user);

      return user;
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
      await _apiService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
    } catch (e) {
      throw Exception('فشل تحديث كلمة المرور: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Token Management - إدارة الـ Token
  // ═══════════════════════════════════════════════════════════════════

  /// حفظ Token
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('خطأ في حفظ Token: $e');
    }
  }

  /// الحصول على Token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('خطأ في الحصول على Token: $e');
      return null;
    }
  }

  /// مسح Token
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('خطأ في مسح Token: $e');
    }
  }

  /// التحقق من وجود Token
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Remember Me Management - إدارة "تذكرني"
  // ═══════════════════════════════════════════════════════════════════

  /// حفظ حالة "تذكرني"
  Future<void> saveRememberMe(bool rememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, rememberMe);
      print('✅ تم حفظ حالة تذكرني: $rememberMe');
    } catch (e) {
      print('خطأ في حفظ حالة تذكرني: $e');
    }
  }

  /// الحصول على حالة "تذكرني"
  Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      print('خطأ في الحصول على حالة تذكرني: $e');
      return false;
    }
  }

  /// مسح حالة "تذكرني"
  Future<void> clearRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      print('✅ تم مسح حالة تذكرني');
    } catch (e) {
      print('خطأ في مسح حالة تذكرني: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // User Storage - تخزين المستخدم
  // ═══════════════════════════════════════════════════════════════════

  /// حفظ بيانات المستخدم
  Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('خطأ في حفظ بيانات المستخدم: $e');
    }
  }

  /// الحصول على بيانات المستخدم المحفوظة
  Future<UserModel?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null && userJson.isNotEmpty) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }

      return null;
    } catch (e) {
      print('خطأ في الحصول على بيانات المستخدم المحفوظة: $e');
      return null;
    }
  }

  /// مسح بيانات المستخدم
  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('خطأ في مسح بيانات المستخدم: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Authentication State - حالة المصادقة
  // ═══════════════════════════════════════════════════════════════════

  /// التحقق من تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final hasTokenValue = await hasToken();
    final user = await getStoredUser();
    final rememberMe = await getRememberMe();

    // إذا لم يكن "تذكرني" مفعل، المستخدم غير مسجل دخول
    if (!rememberMe) {
      return false;
    }

    // إذا كان "تذكرني" مفعل و Token موجود و User موجود، المستخدم مسجل دخول
    return rememberMe && hasTokenValue && user != null;
  }

  /// تهيئة المصادقة (استدعاء عند بدء التطبيق)
  Future<void> initialize() async {
    try {
      // تحميل Base URL المخصص أولاً (للاستخدام مع الأجهزة الحقيقية)
      await _apiService.loadCustomBaseUrl();

      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        _apiService.setAuthToken(token);
        print('✅ تم تحميل Token بنجاح: ${token.substring(0, 10)}...');
      } else {
        print('⚠️ لا يوجد Token محفوظ - المستخدم ضيف');
      }
    } catch (e) {
      print('❌ خطأ في تهيئة المصادقة: $e');
    }
  }

  /// مسح جميع البيانات
  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
    _apiService.clearAuthToken();
  }

  // ═══════════════════════════════════════════════════════════════════
  // API Service Access - الوصول لـ API Service
  // ═══════════════════════════════════════════════════════════════════

  ApiService get apiService => _apiService;
}

class AuthMessageResult {
  final bool success;
  final String message;

  AuthMessageResult({required this.success, required this.message});
}

class AuthLoginResult {
  final bool success;
  final String? message;
  final String? token;
  final UserModel? user;
  final bool requiresEmailVerification;

  AuthLoginResult({
    required this.success,
    this.message,
    this.token,
    this.user,
    this.requiresEmailVerification = false,
  });
}
