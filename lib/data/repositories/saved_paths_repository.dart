// lib/data/repositories/saved_paths_repository.dart
import '../models/path_model.dart';
import '../services/api_service.dart';

class SavedPathsRepository {
  final ApiService _apiService = ApiService();
  
  /// الحصول على المسارات المحفوظة
  Future<List<PathModel>> getSavedPaths() async {
    try {
      final response = await _apiService.get(
        '/saved-paths',
        requiresAuth: true,
      );
      
      if (response['status'] == 'success' && response['data'] != null) {
        List<dynamic> pathsData = response['data'] is List
            ? response['data']
            : response['data']['paths'] ?? [];
        
        return pathsData
            .map((json) => PathModel.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('فشل تحميل المسارات المحفوظة: $e');
    }
  }
  
  /// حفظ مسار
  Future<bool> savePath(String pathId) async {
    try {
      final response = await _apiService.post(
        '/saved-paths',
        {
          'path_id': pathId,
        },
        requiresAuth: true,
      );
      
      return response['status'] == 'success';
    } catch (e) {
      throw Exception('فشل حفظ المسار: $e');
    }
  }
  
  /// إزالة مسار من المحفوظات
  Future<bool> removeSavedPath(String pathId) async {
    try {
      final response = await _apiService.delete(
        '/saved-paths/$pathId',
        requiresAuth: true,
      );
      
      return response['status'] == 'success';
    } catch (e) {
      throw Exception('فشل إزالة المسار من المحفوظات: $e');
    }
  }
  
  /// التحقق من كون المسار محفوظاً
  Future<bool> isPathSaved(String pathId) async {
    try {
      final response = await _apiService.get(
        '/saved-paths/$pathId',
        requiresAuth: true,
      );
      
      return response['status'] == 'success' && response['data'] != null;
    } catch (e) {
      return false;
    }
  }
  
  /// تبديل حالة الحفظ
  Future<bool> toggleSavedPath(String pathId) async {
    try {
      final isSaved = await isPathSaved(pathId);
      
      if (isSaved) {
        return await removeSavedPath(pathId);
      } else {
        return await savePath(pathId);
      }
    } catch (e) {
      throw Exception('فشل تبديل حالة الحفظ: $e');
    }
  }
}








