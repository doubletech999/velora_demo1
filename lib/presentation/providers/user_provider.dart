// lib/presentation/providers/user_provider.dart - النسخة المُصلحة مع Logs
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final AuthService _authService = AuthService.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isGuest = false;
  bool _initialized = false;
  String? _infoMessage;
  bool _requiresEmailVerification = false;
  String? _pendingVerificationEmail;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// ✅ تعديل هنا
  /// الآن أي مستخدم يعتبر logged in حتى لو كان guest
  bool get isLoggedIn => _user != null;

  bool get isGuest => _isGuest;
  bool get initialized => _initialized;
  String? get infoMessage => _infoMessage;
  bool get requiresEmailVerification => _requiresEmailVerification;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  /// تهيئة المستخدم عند بدء التطبيق
  Future<void> initialize() async {
    if (_initialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.initialize();
      await loadUser();
      _initialized = true;
    } catch (e) {
      debugPrint('خطأ في تهيئة UserProvider: $e');
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل بيانات المستخدم
  Future<void> loadUser() async {
    try {
      final hasToken = await _authService.hasToken();
      final rememberMe = await _authService.getRememberMe();

      // إذا لم يكن "تذكرني" مفعل، لا نحمل المستخدم
      if (!rememberMe) {
        debugPrint('⚠️ تذكرني غير مفعل - عدم تحميل المستخدم');
        _user = null;
        _isGuest = false;
        return;
      }

      if (!hasToken) {
        _user = null;
        _isGuest = false;
        return;
      }

      _user = await _repository.getCurrentUser();
      _isGuest = _user?.role == 'guest';
      _error = null;

      if (_user != null) {
        debugPrint('✅ تم تحميل المستخدم تلقائياً: ${_user!.name}');
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المستخدم: $e');
      _user = null;
      _isGuest = false;
      _error = null;
    }
  }

  /// تسجيل مستخدم جديد
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
    String? language,
  }) async {
    _isLoading = true;
    _error = null;
    _isGuest = false;
    _infoMessage = null;
    _requiresEmailVerification = false;
    _pendingVerificationEmail = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        name,
        email,
        password,
        phone: phone,
        role: role,
        language: language ?? 'ar',
      );

      _user = null;
      _error = null;
      _infoMessage = result.message;
      _requiresEmailVerification = false;
      _pendingVerificationEmail = email;
      _isLoading = false;
      notifyListeners();
      return result.success;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _user = null;
      _infoMessage = null;
      _requiresEmailVerification = false;
      _pendingVerificationEmail = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الدخول
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _error = null;
    _isGuest = false;
    _infoMessage = null;
    _requiresEmailVerification = false;
    _pendingVerificationEmail = null;
    notifyListeners();

    try {
      final result = await _repository.login(
        email,
        password,
        rememberMe: rememberMe,
      );

      if (result.success && result.user != null) {
        _user = result.user;
        _error = null;
        _infoMessage = result.message;
        _requiresEmailVerification = false;
        _pendingVerificationEmail = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _user = null;
      _error = result.message;
      _infoMessage = result.message;
      _requiresEmailVerification = result.requiresEmailVerification;
      _pendingVerificationEmail =
          result.requiresEmailVerification ? email : null;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _user = null;
      _infoMessage = null;
      _requiresEmailVerification = false;
      _pendingVerificationEmail = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendVerificationEmail({String? email}) async {
    final targetEmail = (email ?? _pendingVerificationEmail)?.trim();

    if (targetEmail == null || targetEmail.isEmpty) {
      _error = 'يرجى إدخال البريد الإلكتروني لإعادة الإرسال.';
      notifyListeners();
      return false;
    }

    try {
      final result = await _repository.resendVerificationEmail(targetEmail);
      _error = null;
      _infoMessage = result.message;
      _requiresEmailVerification = false;
      notifyListeners();
      return result.success;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _infoMessage = null;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الدخول كضيف (للمشاهدة فقط) - مُصلح ✅
  Future<void> loginAsGuest() async {
    debugPrint('🔵 START: تسجيل الدخول كضيف');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // إنشاء مستخدم ضيف
      _user = UserModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'زائر',
        email: 'guest@velora.com',
        createdAt: DateTime.now(),
        completedTrips: 0,
        savedTrips: 0,
        achievements: 0,
        preferredLanguage: 'ar',
        role: 'guest',
      );

      _isGuest = true;
      _error = null;

      debugPrint('✅ تم إنشاء حساب ضيف');
      debugPrint('   - ID: ${_user?.id}');
      debugPrint('   - Name: ${_user?.name}');
      debugPrint('   - Role: ${_user?.role}');
      debugPrint('   - isGuest: $_isGuest');
    } catch (e) {
      debugPrint('❌ ERROR: خطأ في تسجيل الدخول كضيف: $e');
      _error = 'فشل تسجيل الدخول كضيف';
      _user = null;
      _isGuest = false;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('🔵 END: تسجيل الدخول كضيف');
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    // منع الاستدعاء المزدوج
    if (_isLoading) {
      debugPrint('تسجيل الخروج قيد التنفيذ بالفعل');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (!_isGuest) {
        try {
          await _repository.logout();
          debugPrint('✅ تم تسجيل الخروج من السيرفر');
        } catch (e) {
          // تجاهل خطأ 401 (Unauthenticated) لأنه يعني أن المستخدم مسجل خروج بالفعل
          if (e.toString().contains('401') ||
              e.toString().contains('Unauthenticated')) {
            debugPrint('المستخدم مسجل خروج بالفعل من السيرفر');
          } else {
            debugPrint('خطأ في تسجيل الخروج: $e');
          }
        }
      }

      // مسح حالة المستخدم المحلية
      _user = null;
      _isGuest = false;
      _error = null;

      debugPrint('✅ تم حذف بيانات المستخدم المحلية');
    } catch (e) {
      debugPrint('خطأ في تسجيل الخروج: $e');
      _user = null;
      _isGuest = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// التحقق من أن المستخدم ليس ضيف
  bool requiresAuthentication(BuildContext context, {String? feature}) {
    debugPrint('🔍 CHECK: requiresAuthentication - isGuest: $_isGuest');

    if (_isGuest) {
      showGuestRestrictionDialog(context, feature: feature);
      return false;
    }
    return true;
  }

  /// عرض نافذة تنبيه للضيف
  void showGuestRestrictionDialog(BuildContext context, {String? feature}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIcons.lock_key_fill,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'تسجيل الدخول مطلوب',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                feature != null
                    ? 'للوصول إلى $feature، يجب عليك تسجيل الدخول.'
                    : 'للوصول إلى هذه الميزة، يجب عليك تسجيل الدخول.',
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        AppLocalizations.ofOrThrow(context).get('later'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        AppLocalizations.ofOrThrow(context).get('login'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> updateProfile(UserModel updatedUser, {Map<String, dynamic>? additionalData}) async {
    if (_isGuest) {
      _error = 'لا يمكن تحديث الملف في وضع الضيف';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.updateProfile(updatedUser, additionalData: additionalData);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (_isGuest) {
      _error = 'لا يمكن تحديث كلمة المرور في وضع الضيف';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (_isGuest) {
      _error = 'لا يمكن حذف الحساب في وضع الضيف';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteAccount();
      _user = null;
      _isGuest = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _extractErrorMessage(String error) {
    if (error.startsWith('Exception: ')) {
      error = error.substring(11);
    }

    final patterns = [
      'فشل التسجيل: ',
      'فشل تسجيل الدخول: ',
      'فشل تحديث الملف الشخصي: ',
      'فشل تحديث كلمة المرور: ',
      'فشل حذف الحساب: ',
    ];

    for (final pattern in patterns) {
      if (error.startsWith(pattern)) {
        error = error.substring(pattern.length);
        break;
      }
    }

    return error;
  }

  void reset() {
    _user = null;
    _isLoading = false;
    _error = null;
    _isGuest = false;
    _initialized = false;
    notifyListeners();
  }
}
