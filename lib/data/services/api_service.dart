import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class ApiService {
  // ═══════════════════════════════════════════════════════════════════
  // Singleton Pattern - لضمان استخدام instance واحد في كل التطبيق
  // ═══════════════════════════════════════════════════════════════════
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal() {
    print('🔧 ApiService: تم إنشاء instance (Singleton)');
  }
  // ═══════════════════════════════════════════════════════════════════
  // Configuration - الإعدادات
  // ═══════════════════════════════════════════════════════════════════

  // IP مخصص للأجهزة الحقيقية (يمكن تعيينه من SharedPreferences)
  String? _customBaseUrl;
  bool get hasCustomBaseUrl =>
      _customBaseUrl != null && _customBaseUrl!.isNotEmpty;

  /// اكتشاف البيئة تلقائياً واختيار العنوان المناسب
  /// - Flutter Web: https://velorify.pro/api
  /// - Android Emulator: https://velorify.pro/api
  /// - iOS Simulator: https://velorify.pro/api
  /// - Real Device (Custom IP/URL): يمكن تعيينه عبر setCustomBaseUrl()
  String get baseUrl {
    // إذا كان هناك URL مخصص (ngrok أو IP مخصص)، استخدمه
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      print('🌐 ApiService.baseUrl: $_customBaseUrl (مخصص)');
      return _customBaseUrl!;
    }

    // القيم الافتراضية حسب البيئة
    String defaultUrl;
    if (kIsWeb) {
      // Flutter Web - استخدم localhost
      defaultUrl = 'https://velorify.pro/api';
      print('🌐 ApiService.baseUrl: $defaultUrl (Web)');
    } else {
      // Mobile (Android/iOS)
      // كل المنصات تستخدم الآن العنوان الثابت للسيرفر الخارجي
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          defaultUrl = 'https://velorify.pro/api';
          print('🌐 ApiService.baseUrl: $defaultUrl (Android Emulator)');
          break;
        case TargetPlatform.iOS:
          defaultUrl = 'https://velorify.pro/api';
          print('🌐 ApiService.baseUrl: $defaultUrl (iOS Simulator)');
          break;
        default:
          defaultUrl = 'https://velorify.pro/api';
          print(
            '🌐 ApiService.baseUrl: $defaultUrl (منصة غير معروفة - تم اختيار localhost)',
          );
          break;
      }
      print('💡 لتغيير العنوان استخدم setCustomBaseUrl() في main.dart');
    }
    return defaultUrl;
  }

  /// الحصول على Base URL للصور (بدون /api)
  /// يستخدم نفس base URL لكن بدون /api في النهاية
  String get imagesBaseUrl {
    final url = baseUrl;
    // إذا كان baseUrl ينتهي بـ /api، أزله
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4); // إزالة '/api'
    }
    return url;
  }

  // Token للمصادقة
  String? _authToken;

  String? get authToken => _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  /// تعيين Base URL مخصص (للاستخدام مع ngrok أو الأجهزة الحقيقية)
  /// ⚠️ ملاحظة:
  /// - على Web: يمكن استخدام ngrok URL
  /// - على Mobile: يمكن استخدام ngrok URL أو IP مخصص
  /// - للمحاكي: يتم اكتشاف البيئة تلقائياً (لكن يمكن تجاوزها)
  ///
  /// أمثلة:
  /// - ngrok: 'https://trevally-unpatented-christia.ngrok-free.dev/api'
  /// - IP مخصص: 'http://192.168.88.4:8000/api'
  Future<void> setCustomBaseUrl(String? customUrl) async {
    _customBaseUrl = customUrl;
    if (customUrl != null && customUrl.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.customApiBaseUrlKey, customUrl);
        print('✅ ApiService: تم حفظ Base URL المخصص: $customUrl');

        if (customUrl.contains('ngrok')) {
          print('   🌐 ngrok URL: سيتم استخدامه على جميع المنصات (Web/Mobile)');
        } else if (kIsWeb) {
          print('   🌐 Web: سيتم استخدام هذا العنوان');
        } else {
          print(
            '   📱 Mobile: سيتم استخدام هذا العنوان على Emulator/Real Device',
          );
        }
      } catch (e) {
        print('❌ ApiService: خطأ في حفظ Base URL: $e');
      }
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.customApiBaseUrlKey);
        print('✅ ApiService: تم حذف Base URL المخصص');
        if (kIsWeb) {
          print('   🌐 Web: سيتم استخدام localhost');
        } else {
          print('   📱 Mobile: سيتم استخدام القيمة الافتراضية حسب البيئة');
        }
      } catch (e) {
        print('❌ ApiService: خطأ في حذف Base URL: $e');
      }
    }
  }

  Future<void> loadCustomBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customUrl = prefs.getString(AppConstants.customApiBaseUrlKey);
      if (customUrl != null && customUrl.isNotEmpty) {
        _customBaseUrl = customUrl;
        print('✅ ApiService: تم تحميل Base URL المخصص من التخزين: $customUrl');

        if (customUrl.contains('ngrok')) {
          print('   🌐 ngrok URL: سيتم استخدامه على جميع المنصات (Web/Mobile)');
        } else if (kIsWeb) {
          print('   🌐 Web: سيتم استخدام هذا العنوان');
        } else {
          print(
            '   📱 Mobile: سيتم استخدام هذا العنوان على Emulator/Real Device',
          );
        }
        print('   💡 لحذف URL المحفوظ: استخدم setCustomBaseUrl(null)');
      } else {
        print(
          'ℹ️ ApiService: لا يوجد Base URL مخصص - سيتم استخدام القيمة الافتراضية',
        );
        if (kIsWeb) {
          print('   🌐 Web: سيتم استخدام http://localhost:8000/api');
        } else {
          print(
            '   📱 Mobile: سيتم استخدام http://10.0.2.2:8000/api (Emulator/Simulator)',
          );
          print(
            '   💡 للجهاز الحقيقي أو ngrok: استخدم setCustomBaseUrl() في main.dart',
          );
        }
      }
    } catch (e) {
      print('❌ ApiService: خطأ في تحميل Base URL: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Headers
  // ═══════════════════════════════════════════════════════════════════

  Map<String, String> get _headers {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
  }

  Map<String, String> get _headersWithAuth {
    final headers = Map<String, String>.from(_headers);
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<void> loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.userTokenKey);
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        print('✅ تم تحميل Token');
      }
    } catch (e) {
      print('❌ خطأ في تحميل Token: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HTTP CORE
  // ═══════════════════════════════════════════════════════════════════

  Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request =
          http.Request('GET', uri)
            ..followRedirects = false
            ..headers.addAll(requiresAuth ? _headersWithAuth : _headers);

      final streamedResponse = await client
          .send(request)
          .timeout(AppConstants.apiTimeout);

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    } finally {
      client.close();
    }
  }

  Future<dynamic> post(
    String endpoint,
    dynamic body, {
    bool requiresAuth = false,
  }) async {
    final client = http.Client();
    try {
      if (requiresAuth && !isAuthenticated) {
        await loadTokenFromStorage();
      }

      final url = '$baseUrl$endpoint';
      print('POST → $url');
      print('Body: ${json.encode(body)}');
      print('Headers: ${requiresAuth ? _headersWithAuth : _headers}');

      final uri = Uri.parse(url);
      final request =
          http.Request('POST', uri)
            ..followRedirects = false
            ..headers.addAll(requiresAuth ? _headersWithAuth : _headers)
            ..body = json.encode(body);

      final streamedResponse = await client
          .send(request)
          .timeout(AppConstants.apiTimeout);

      final response = await http.Response.fromStream(streamedResponse);
      print('Response Headers: ${response.headers}');

      print('📥 Response → ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      throw _handleError(e);
    } finally {
      client.close();
    }
  }

  Future<dynamic> put(
    String endpoint,
    dynamic body, {
    bool requiresAuth = false,
  }) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request =
          http.Request('PUT', uri)
            ..followRedirects = false
            ..headers.addAll(requiresAuth ? _headersWithAuth : _headers)
            ..body = json.encode(body);

      final streamedResponse = await client
          .send(request)
          .timeout(AppConstants.apiTimeout);

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    } finally {
      client.close();
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request =
          http.Request('DELETE', uri)
            ..followRedirects = false
            ..headers.addAll(requiresAuth ? _headersWithAuth : _headers);

      final streamedResponse = await client
          .send(request)
          .timeout(AppConstants.apiTimeout);

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    } finally {
      client.close();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Authentication
  // ═══════════════════════════════════════════════════════════════════

  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? role,
    String? language,
    String? phone,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (role != null) 'role': role,
      if (language != null) 'language': language,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    print('📤 إرسال طلب التسجيل إلى Laravel:');
    print('  URL: $baseUrl/register');
    print('  Body: $body');

    try {
      final response = await post('/register', body, requiresAuth: false);
      print('✅ استجابة التسجيل من Laravel: $response');
      return response;
    } catch (e) {
      print('❌ خطأ في التسجيل: $e');
      rethrow;
    }
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final body = {'email': email, 'password': password};

    print('📤 إرسال طلب تسجيل الدخول إلى Laravel:');
    print('  URL: $baseUrl/login');
    print('  Body: {email: $email, password: ***}');

    try {
      final response = await post('/login', body, requiresAuth: false);
      print('✅ استجابة تسجيل الدخول من Laravel: $response');
      return response;
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      rethrow;
    }
  }

  Future<dynamic> resendVerificationEmail({required String email}) async {
    final body = {'email': email};

    print('📤 إعادة إرسال رابط التحقق:');
    print('  URL: $baseUrl/email/resend');
    print('  Body: $body');

    try {
      final response = await post('/email/resend', body, requiresAuth: false);
      print('✅ استجابة إعادة إرسال التحقق: $response');
      return response;
    } catch (e) {
      print('❌ خطأ في إعادة إرسال رابط التحقق: $e');
      rethrow;
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  /// Send password reset link
  Future<dynamic> sendPasswordResetEmail({required String email}) async {
    final body = {'email': email};

    print('📤 إرسال رابط إعادة تعيين كلمة المرور:');
    print('  URL: $baseUrl/password/email');
    print('  Body: {email: $email}');

    try {
      final response = await post('/password/email', body, requiresAuth: false);
      print('✅ استجابة إرسال رابط إعادة تعيين كلمة المرور: $response');
      return response;
    } catch (e) {
      print('❌ خطأ في إرسال رابط إعادة تعيين كلمة المرور: $e');
      rethrow;
    }
  }

  /// إعادة تعيين كلمة المرور باستخدام Token
  /// Reset password using token
  Future<dynamic> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final body = {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    print('📤 إعادة تعيين كلمة المرور:');
    print('  URL: $baseUrl/password/reset');
    print('  Body: {email: $email, token: ***, password: ***}');

    try {
      final response = await post('/password/reset', body, requiresAuth: false);
      print('✅ استجابة إعادة تعيين كلمة المرور: $response');
      return response;
    } catch (e) {
      print('❌ خطأ في إعادة تعيين كلمة المرور: $e');
      rethrow;
    }
  }

  Future<dynamic> logout() async {
    return await post('/logout', {}, requiresAuth: true);
  }

  Future<dynamic> getCurrentUser() async {
    return await get('/user', requiresAuth: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Sites
  // ═══════════════════════════════════════════════════════════════════

  Future<dynamic> getSites({String? type, String? search, int? page}) async {
    String queryString = '';

    if (type != null && type.isNotEmpty) {
      queryString += '&type=$type';
      print('🔍 ApiService.getSites: type=$type');
    }
    if (search != null && search.isNotEmpty) {
      queryString += '&search=$search';
    }
    if (page != null) {
      queryString += '&page=$page';
    }

    if (queryString.isNotEmpty) {
      queryString = '?${queryString.substring(1)}';
    }

    final url = '/sites$queryString';
    print('🌐 ApiService.getSites: $baseUrl$url');

    try {
      final response = await get(url, requiresAuth: true);
      print('✅ ApiService.getSites: نجح مع Auth');
      return response;
    } catch (e) {
      print('⚠️ ApiService.getSites: فشل مع Auth – نجرب بدون');
      try {
        final response = await get(url, requiresAuth: false);
        print('✅ ApiService.getSites: نجح بدون Auth');
        return response;
      } catch (e2) {
        print('❌ ApiService.getSites: فشل بدون Auth أيضاً: $e2');
        rethrow;
      }
    }
  }

  Future<dynamic> getSite(int siteId) async {
    try {
      return await get('/sites/$siteId', requiresAuth: true);
    } catch (e) {
      return await get('/sites/$siteId', requiresAuth: false);
    }
  }

  Future<dynamic> createSite({
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String type,
    String? imageUrl,
  }) async {
    return await post('/sites', {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      if (imageUrl != null) 'image_url': imageUrl,
    }, requiresAuth: true);
  }

  Future<dynamic> updateSite({
    required int siteId,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? type,
    String? imageUrl,
  }) async {
    Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (type != null) body['type'] = type;
    if (imageUrl != null) body['image_url'] = imageUrl;

    return await put('/sites/$siteId', body, requiresAuth: true);
  }

  Future<dynamic> deleteSite(int siteId) async {
    return await delete('/sites/$siteId', requiresAuth: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Guides Methods - طرق المرشدين
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على جميع المرشدين
  Future<dynamic> getGuides({
    String? languages,
    double? minRate,
    double? maxRate,
    String? search,
    int? page,
  }) async {
    String queryString = '';

    if (languages != null) queryString += '&languages=$languages';
    if (minRate != null) queryString += '&min_rate=$minRate';
    if (maxRate != null) queryString += '&max_rate=$maxRate';
    if (search != null) queryString += '&search=$search';
    if (page != null) queryString += '&page=$page';

    if (queryString.isNotEmpty) {
      queryString = '?${queryString.substring(1)}';
    }

    return await get('/guides$queryString', requiresAuth: true);
  }

  /// الحصول على مرشد محدد
  Future<dynamic> getGuide(int guideId) async {
    return await get('/guides/$guideId', requiresAuth: true);
  }

  /// إنشاء ملف مرشد
  Future<dynamic> createGuide({
    required String bio,
    required String languages,
    required String phone,
    required double hourlyRate,
  }) async {
    return await post('/guides', {
      'bio': bio,
      'languages': languages,
      'phone': phone,
      'hourly_rate': hourlyRate,
    }, requiresAuth: true);
  }

  /// تحديث ملف مرشد
  Future<dynamic> updateGuide({
    required int guideId,
    String? bio,
    String? languages,
    String? phone,
    double? hourlyRate,
  }) async {
    Map<String, dynamic> body = {};

    if (bio != null) body['bio'] = bio;
    if (languages != null) body['languages'] = languages;
    if (phone != null) body['phone'] = phone;
    if (hourlyRate != null) body['hourly_rate'] = hourlyRate;

    return await put('/guides/$guideId', body, requiresAuth: true);
  }

  /// حذف ملف مرشد
  Future<dynamic> deleteGuide(int guideId) async {
    return await delete('/guides/$guideId', requiresAuth: true);
  }

  /// الحصول على ملفي كمرشد
  Future<dynamic> getMyGuideProfile() async {
    return await get('/guides/my/profile', requiresAuth: true);
  }

  /// التحقق من توفر المرشد
  Future<dynamic> getGuideAvailability({
    required int guideId,
    required String date,
  }) async {
    return await get(
      '/guides/$guideId/availability?date=$date',
      requiresAuth: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Trips Methods - طرق الرحلات
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على رحلاتي
  Future<dynamic> getTrips({
    String? status,
    String? search,
    String? startDate,
    String? endDate,
    int? page,
  }) async {
    String queryString = '';

    if (status != null) queryString += '&status=$status';
    if (search != null) queryString += '&search=$search';
    if (startDate != null) queryString += '&start_date=$startDate';
    if (endDate != null) queryString += '&end_date=$endDate';
    if (page != null) queryString += '&page=$page';

    if (queryString.isNotEmpty) {
      queryString = '?${queryString.substring(1)}';
    }

    return await get('/trips$queryString', requiresAuth: true);
  }

  /// الحصول على رحلة محددة
  Future<dynamic> getTrip(int tripId) async {
    return await get('/trips/$tripId', requiresAuth: true);
  }

  /// إنشاء رحلة جديدة
  Future<dynamic> createTrip({
    required String tripName,
    required String startDate,
    required String endDate,
    String? description,
    required List<int> sites,
  }) async {
    return await post('/trips', {
      'trip_name': tripName,
      'start_date': startDate,
      'end_date': endDate,
      if (description != null) 'description': description,
      'sites': sites,
    }, requiresAuth: true);
  }

  /// تحديث رحلة
  Future<dynamic> updateTrip({
    required int tripId,
    String? tripName,
    String? startDate,
    String? endDate,
    String? description,
    List<int>? sites,
  }) async {
    Map<String, dynamic> body = {};

    if (tripName != null) body['trip_name'] = tripName;
    if (startDate != null) body['start_date'] = startDate;
    if (endDate != null) body['end_date'] = endDate;
    if (description != null) body['description'] = description;
    if (sites != null) body['sites'] = sites;

    return await put('/trips/$tripId', body, requiresAuth: true);
  }

  /// حذف رحلة
  Future<dynamic> deleteTrip(int tripId) async {
    return await delete('/trips/$tripId', requiresAuth: true);
  }

  /// إضافة موقع لرحلة
  Future<dynamic> addSiteToTrip({
    required int tripId,
    required int siteId,
  }) async {
    return await post('/trips/$tripId/sites', {
      'site_id': siteId,
    }, requiresAuth: true);
  }

  /// إزالة موقع من رحلة
  Future<dynamic> removeSiteFromTrip({
    required int tripId,
    required int siteId,
  }) async {
    return await delete(
      '/trips/$tripId/sites?site_id=$siteId',
      requiresAuth: true,
    );
  }

  /// نسخ رحلة
  Future<dynamic> duplicateTrip(int tripId) async {
    return await post('/trips/$tripId/duplicate', {}, requiresAuth: true);
  }

  /// إحصائيات الرحلات
  Future<dynamic> getTripsStats() async {
    return await get('/trips/stats', requiresAuth: true);
  }

  /// توصيات المواقع
  Future<dynamic> getTripRecommendations() async {
    return await get('/trips/recommendations', requiresAuth: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Reviews Methods - طرق التقييمات
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على التقييمات
  Future<dynamic> getReviews({
    String? type,
    int? siteId,
    int? guideId,
    int? rating,
    int? minRating,
    bool? myReviews,
    int? page,
  }) async {
    String queryString = '';

    if (type != null) queryString += '&type=$type';
    if (siteId != null) queryString += '&site_id=$siteId';
    if (guideId != null) queryString += '&guide_id=$guideId';
    if (rating != null) queryString += '&rating=$rating';
    if (minRating != null) queryString += '&min_rating=$minRating';
    if (myReviews != null) queryString += '&my_reviews=$myReviews';
    if (page != null) queryString += '&page=$page';

    if (queryString.isNotEmpty) {
      queryString = '?${queryString.substring(1)}';
    }

    final url = '/reviews$queryString';
    print('📤 جلب التقييمات من Laravel:');
    print('  URL: $baseUrl$url');
    print('  siteId: $siteId, guideId: $guideId');

    try {
      // محاولة مع authentication أولاً
      final response = await get(url, requiresAuth: true);
      print('✅ استجابة التقييمات من Laravel (مع Auth): $response');
      return response;
    } catch (e) {
      print('⚠️ فشل جلب التقييمات مع Auth – نجرب بدون');
      try {
        // محاولة بدون authentication (للضيوف)
        final response = await get(url, requiresAuth: false);
        print('✅ استجابة التقييمات من Laravel (بدون Auth): $response');
        return response;
      } catch (e2) {
        print('❌ فشل جلب التقييمات بدون Auth أيضاً: $e2');
        rethrow;
      }
    }
  }

  /// الحصول على تقييم محدد
  Future<dynamic> getReview(int reviewId) async {
    return await get('/reviews/$reviewId', requiresAuth: true);
  }

  /// إضافة تقييم
  Future<dynamic> createReview({
    int? siteId,
    int? guideId,
    required int rating,
    String? comment,
  }) async {
    print('📤 إرسال طلب إضافة التقييم إلى Laravel:');
    print('  URL: $baseUrl/reviews');
    print('  siteId: $siteId, guideId: $guideId, rating: $rating');

    try {
      final response = await post('/reviews', {
        if (siteId != null) 'site_id': siteId,
        if (guideId != null) 'guide_id': guideId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      }, requiresAuth: true);

      print('✅ استجابة إضافة التقييم من Laravel: $response');
      return response;
    } catch (e) {
      print('❌ خطأ في إضافة التقييم: $e');
      rethrow;
    }
  }

  /// تحديث تقييم
  Future<dynamic> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
  }) async {
    Map<String, dynamic> body = {};

    if (rating != null) body['rating'] = rating;
    if (comment != null) body['comment'] = comment;

    return await put('/reviews/$reviewId', body, requiresAuth: true);
  }

  /// حذف تقييم
  Future<dynamic> deleteReview(int reviewId) async {
    return await delete('/reviews/$reviewId', requiresAuth: true);
  }

  /// إحصائيات التقييمات
  Future<dynamic> getReviewStats({int? siteId, int? guideId}) async {
    String queryString = '';

    if (siteId != null) queryString += '&site_id=$siteId';
    if (guideId != null) queryString += '&guide_id=$guideId';

    if (queryString.isNotEmpty) {
      queryString = '?${queryString.substring(1)}';
    }

    final url = '/reviews/stats$queryString';
    print('📤 جلب إحصائيات التقييمات من Laravel:');
    print('  URL: $baseUrl$url');
    print('  siteId: $siteId, guideId: $guideId');

    try {
      // محاولة مع authentication أولاً
      final response = await get(url, requiresAuth: true);
      print('✅ استجابة إحصائيات التقييمات من Laravel (مع Auth): $response');
      return response;
    } catch (e) {
      print('⚠️ فشل جلب إحصائيات التقييمات مع Auth – نجرب بدون');
      try {
        // محاولة بدون authentication (للضيوف)
        final response = await get(url, requiresAuth: false);
        print('✅ استجابة إحصائيات التقييمات من Laravel (بدون Auth): $response');
        return response;
      } catch (e2) {
        print('❌ فشل جلب إحصائيات التقييمات بدون Auth أيضاً: $e2');
        rethrow;
      }
    }
  }

  /// تقييماتي
  Future<dynamic> getMyReviews() async {
    return await get('/reviews/my', requiresAuth: true);
  }

  /// التحقق من إمكانية التقييم
  Future<dynamic> canReview({int? siteId, int? guideId}) async {
    String queryString = '';

    if (siteId != null) queryString += '&site_id=$siteId';
    if (guideId != null) queryString += '&guide_id=$guideId';

    if (queryString.isNotEmpty) {
      queryString = '?${queryString.substring(1)}';
    }

    return await get('/reviews/can-review$queryString', requiresAuth: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Bookings Methods - طرق الحجوزات
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على الحجوزات
  Future<dynamic> getBookings({
    String? status,
    String? startDate,
    String? endDate,
    bool? upcoming,
    int? page,
  }) async {
    String queryString = '';

    if (status != null) queryString += '&status=$status';
    if (startDate != null) queryString += '&start_date=$startDate';
    if (endDate != null) queryString += '&end_date=$endDate';
    if (upcoming != null) queryString += '&upcoming=$upcoming';
    if (page != null) queryString += '&page=$page';

    if (queryString.isNotEmpty) {
      queryString = '?${queryString.substring(1)}';
    }

    return await get('/bookings$queryString', requiresAuth: true);
  }

  /// الحصول على حجز محدد
  Future<dynamic> getBooking(int bookingId) async {
    return await get('/bookings/$bookingId', requiresAuth: true);
  }

  /// إنشاء حجز جديد
  Future<dynamic> createBooking({
    required int guideId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    double? totalPrice,
    String? notes,
    String? pathId, // إضافة path_id أو site_id
    int? numberOfParticipants, // عدد المشاركين
    String? paymentMethod, // طريقة الدفع
  }) async {
    Map<String, dynamic> body = {
      'guide_id': guideId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
    };

    if (totalPrice != null) {
      body['total_price'] = totalPrice;
    }

    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    // إضافة الحقول الجديدة
    if (pathId != null) {
      body['path_id'] = pathId; // أو site_id حسب ما يستخدمه Laravel
      body['site_id'] = pathId; // إضافة كلا الحقلين للتوافق
    }

    if (numberOfParticipants != null) {
      body['number_of_participants'] = numberOfParticipants;
    }

    if (paymentMethod != null) {
      body['payment_method'] = paymentMethod;
    }

    print('📤 إرسال طلب حجز إلى Laravel:');
    print('  URL: $baseUrl/bookings');
    print('  Body: $body');

    try {
      final response = await post('/bookings', body, requiresAuth: true);
      print('✅ استجابة Laravel: $response');
      return response;
    } catch (e) {
      print('❌ خطأ في إرسال الحجز: $e');
      // محاولة بدون authentication (للمستخدمين الضيوف)
      print('⚠️ محاولة إرسال بدون authentication...');
      try {
        return await post('/bookings', body, requiresAuth: false);
      } catch (e2) {
        print('❌ فشل الإرسال بدون authentication أيضاً: $e2');
        rethrow;
      }
    }
  }

  /// تحديث حجز
  Future<dynamic> updateBooking({
    required int bookingId,
    String? bookingDate,
    String? startTime,
    String? endTime,
    String? status,
    String? notes,
  }) async {
    Map<String, dynamic> body = {};

    if (bookingDate != null) body['booking_date'] = bookingDate;
    if (startTime != null) body['start_time'] = startTime;
    if (endTime != null) body['end_time'] = endTime;
    if (status != null) body['status'] = status;
    if (notes != null) body['notes'] = notes;

    return await put('/bookings/$bookingId', body, requiresAuth: true);
  }

  /// إلغاء حجز
  Future<dynamic> cancelBooking(int bookingId) async {
    return await delete('/bookings/$bookingId', requiresAuth: true);
  }

  /// تأكيد حجز (للمرشدين فقط)
  Future<dynamic> confirmBooking(int bookingId) async {
    return await post('/bookings/$bookingId/confirm', {}, requiresAuth: true);
  }

  /// إحصائيات الحجوزات
  Future<dynamic> getBookingsStats() async {
    return await get('/bookings/stats', requiresAuth: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // User Profile Methods - طرق الملف الشخصي
  // ═══════════════════════════════════════════════════════════════════

  /// تحديث الملف الشخصي
  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    return await put('/user/profile', data, requiresAuth: true);
  }

  /// تحديث كلمة المرور
  Future<dynamic> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return await put('/user/password', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    }, requiresAuth: true);
  }

  /// حذف الحساب
  Future<dynamic> deleteAccount() async {
    return await delete('/user/account', requiresAuth: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Helper Methods - طرق مساعدة
  // ═══════════════════════════════════════════════════════════════════

  /// معالجة استجابة HTTP
  dynamic _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return json.decode(response.body);
        } catch (e) {
          final snippet =
              response.body.length > 300
                  ? '${response.body.substring(0, 300)}...'
                  : response.body;
          print('⚠️ Error decoding JSON: $e');
          print('⚠️ Response snippet: $snippet');
          throw FormatException('الاستجابة ليست JSON صالح. المحتوى:\n$snippet');
        }

      case 204:
        return {'success': true, 'message': 'No content'};

      case 400:
        throw BadRequestException(
          _extractErrorMessage(response.body) ?? 'طلب غير صالح',
        );

      case 401:
      case 403:
        throw UnauthorizedException(
          _extractErrorMessage(response.body) ?? 'غير مصرح',
        );

      case 404:
        throw NotFoundException(
          _extractErrorMessage(response.body) ?? 'غير موجود',
        );

      case 409:
        final errorMessage = _extractErrorMessage(response.body);
        print('⚠️ خطأ 409 Conflict: $errorMessage');
        // رسالة افتراضية واضحة للمستخدم
        final defaultMessage =
            'لقد قيمت هذا الموقع مسبقاً. يمكنك تحديث تقييمك من صفحة التقييمات';
        throw ConflictException(errorMessage ?? defaultMessage);

      case 422:
        final errorMessage = _extractErrorMessage(response.body);
        throw ValidationException(errorMessage ?? 'خطأ في التحقق من البيانات');

      case 500:
      default:
        throw ServerException('خطأ في الخادم (${response.statusCode})');
    }
  }

  /// استخراج رسالة الخطأ من الاستجابة
  String? _extractErrorMessage(String responseBody) {
    try {
      print(
        '🔍 استخراج رسالة الخطأ من: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}...',
      );

      final Map<String, dynamic> body = json.decode(responseBody);

      // محاولة 1: errors (Laravel validation errors)
      if (body.containsKey('errors')) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          // Get first error message
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          String? errorMsg;
          if (firstError is List && firstError.isNotEmpty) {
            errorMsg = firstError[0].toString();
          } else if (firstError is String) {
            errorMsg = firstError;
          } else {
            errorMsg = firstError.toString();
          }
          if (errorMsg.isNotEmpty && errorMsg != 'null') {
            print('✅ تم العثور على errors: $errorMsg');
            return errorMsg;
          }
        }
      }

      // محاولة 2: message مباشرة
      if (body.containsKey('message')) {
        final message = body['message'];
        if (message is String && message.isNotEmpty && message != 'null') {
          print('✅ تم العثور على message: $message');
          return message;
        }
      }

      // محاولة 3: error مباشرة
      if (body.containsKey('error')) {
        final error = body['error'];
        if (error is String && error.isNotEmpty && error != 'null') {
          print('✅ تم العثور على error: $error');
          return error;
        }
      }

      // محاولة 4: data.message (في بعض الحالات)
      if (body.containsKey('data') && body['data'] is Map) {
        final data = body['data'] as Map<String, dynamic>;
        if (data.containsKey('message')) {
          final message = data['message'];
          if (message is String && message.isNotEmpty && message != 'null') {
            print('✅ تم العثور على data.message: $message');
            return message;
          }
        }
      }

      print('⚠️ لم يتم العثور على رسالة خطأ في الاستجابة');
      return null;
    } catch (e) {
      print('❌ خطأ في استخراج رسالة الخطأ: $e');
      return null;
    }
  }

  /// معالجة الأخطاء
  Exception _handleError(dynamic error) {
    print('Error occurred: $error');
    print('Error type: ${error.runtimeType}');
    print('Base URL: $baseUrl');

    if (error is FormatException) {
      final decoded = _decodePercentEncoded(error.message);
      final message =
          decoded ?? 'استجابة غير صالحة من الخادم. يرجى المحاولة لاحقاً.';
      return ServerException(message);
    }

    if (error is http.ClientException) {
      final errorMessage = error.message;
      print('ClientException message: $errorMessage');

      // رسائل خطأ أكثر تفصيلاً
      if (errorMessage.contains('Failed to fetch') ||
          errorMessage.contains('Connection refused') ||
          errorMessage.contains('Network is unreachable')) {
        String platformHint =
            kIsWeb
                ? 'Flutter Web: استخدم http://localhost:8000/api'
                : 'Android Emulator: استخدم http://10.0.2.2:8000/api';

        return NetworkException(
          'لا يمكن الوصول إلى السيرفر. تأكد من:\n'
          '1. السيرفر يعمل: php artisan serve --host=0.0.0.0 --port=8000\n'
          '2. $platformHint\n'
          '3. السيرفر يستمع على 0.0.0.0 وليس localhost فقط\n'
          '4. العنوان الحالي: $baseUrl',
        );
      }

      return NetworkException('خطأ في الاتصال: $errorMessage');
    }

    if (error is TimeoutException ||
        error.toString().contains('TimeoutException')) {
      return NetworkException('انتهت مهلة الاتصال. تأكد من أن السيرفر يعمل');
    }

    if (error is AppException) {
      return error;
    }

    return ServerException('حدث خطأ غير متوقع: ${error.toString()}');
  }

  String? _decodePercentEncoded(String? input) {
    if (input == null || input.isEmpty) return null;
    final percentPattern = RegExp(r'%[0-9A-Fa-f]{2}');
    if (!percentPattern.hasMatch(input)) {
      return null;
    }

    try {
      return Uri.decodeComponent(input);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Test Connection - اختبار الاتصال
  // ═══════════════════════════════════════════════════════════════════

  /// اختبار الاتصال بالـ API
  Future<bool> testConnection() async {
    try {
      final response = await get('/test');
      return response != null;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// Custom Exceptions - استثناءات مخصصة
// ═══════════════════════════════════════════════════════════════════

class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException([this.message = '', this.prefix]);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class BadRequestException extends AppException {
  BadRequestException([String message = '']) : super(message, 'طلب غير صالح: ');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = '']) : super(message, 'غير مصرح: ');
}

class NotFoundException extends AppException {
  NotFoundException([String message = '']) : super(message, 'غير موجود: ');
}

class ValidationException extends AppException {
  ValidationException([String message = ''])
    : super(message, 'خطأ في التحقق: ');
}

class ConflictException extends AppException {
  ConflictException([String message = '']) : super(message, 'تعارض: ');
}

class ServerException extends AppException {
  ServerException([String message = '']) : super(message, 'خطأ في الخادم: ');
}

class NetworkException extends AppException {
  NetworkException([String message = '']) : super(message, 'خطأ في الشبكة: ');
}
