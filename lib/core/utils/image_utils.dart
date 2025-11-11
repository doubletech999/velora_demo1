// lib/core/utils/image_utils.dart
import 'package:flutter/services.dart' show rootBundle;

class ImageUtils {
  // التحقق من وجود الصورة وإرجاع مسار بديل إذا لم تكن موجودة
  static Future<String> getValidImagePath(String imagePath, String fallbackPath) async {
    try {
      // التحقق من وجود الصورة
      await rootBundle.load(imagePath);
      return imagePath;
    } catch (e) {
      print('صورة غير موجودة: $imagePath، استخدام البديل');
      return fallbackPath;
    }
  }
  
  // الحصول على قائمة بالصور المتاحة في المجلد
  static List<String> getAvailableImages() {
    return [
      'assets/images/logo.png',
      'assets/images/galilee1.jpg',
      'assets/images/galilee2.jpg',
      'assets/images/galilee3.jpg',
      'assets/images/battir1.jpg',
      'assets/images/battir2.jpg',
      'assets/images/battir3.jpg',
      'assets/images/jericho1.jpg',
      'assets/images/jericho2.jpg',
      'assets/images/jericho3.jpg',
      'assets/images/hebron1.jpg',
      'assets/images/hebron2.jpg',
      'assets/images/hebron3.jpg',
      'assets/images/sebastia1.jpg',
      'assets/images/sebastia2.jpg',
      'assets/images/sebastia3.jpg',
      'assets/images/makhrour1.jpg',
      'assets/images/makhrour2.jpg',
      'assets/images/makhrour3.jpg',
      'assets/images/ramallah1.jpg',
      'assets/images/ramallah2.jpg',
      'assets/images/ramallah3.jpg',
      'assets/images/rashayda1.jpg',
      'assets/images/rashayda2.jpg',
      'assets/images/rashayda3.jpg',
    ];
  }
  
  // التحقق من وجود صورة بنمط معين
  static String getImageByPattern(String pattern) {
    final availableImages = getAvailableImages();
    for (final imagePath in availableImages) {
      if (imagePath.contains(pattern)) {
        return imagePath;
      }
    }
    return 'assets/images/logo.png'; // صورة افتراضية
  }
}