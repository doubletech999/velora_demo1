// lib/data/models/activity_model.dart - تحديث لتحسين التصنيفات
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class ActivityModel {
  final String id;
  final String name;
  final String nameAr;
  final IconData icon;
  final Color color;
  final String description;

  ActivityModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.color,
    required this.description,
  });

  static List<ActivityModel> getAllActivities() {
    return [
      ActivityModel(
        id: 'hiking',
        name: 'Hiking',
        nameAr: 'المشي لمسافات طويلة',
        icon: PhosphorIcons.person_simple_walk,
        color: Colors.green,
        description: 'استكشف المسارات الجبلية والطبيعية سيراً على الأقدام',
      ),
      ActivityModel(
        id: 'camping',
        name: 'Camping',
        nameAr: 'التخييم',
        icon: PhosphorIcons.campfire,
        color: Colors.orange,
        description: 'قضاء ليلة أو أكثر في الطبيعة مع التخييم',
      ),
      ActivityModel(
        id: 'climbing',
        name: 'Climbing',
        nameAr: 'التسلق',
        icon: PhosphorIcons.mountains,
        color: Colors.red,
        description: 'تسلق الجبال والصخور للوصول إلى القمم',
      ),
      ActivityModel(
        id: 'religious',
        name: 'Religious',
        nameAr: 'زيارات دينية',
        icon: PhosphorIcons.house,
        color: Colors.purple,
        description: 'زيارة المواقع الدينية والمقدسة',
      ),
      ActivityModel(
        id: 'cultural',
        name: 'Cultural',
        nameAr: 'ثقافية',
        icon: PhosphorIcons.buildings,
        color: Colors.blue,
        description: 'اكتشاف التراث الثقافي والأحياء التاريخية',
      ),
      ActivityModel(
        id: 'nature',
        name: 'Nature',
        nameAr: 'طبيعة',
        icon: PhosphorIcons.tree,
        color: Colors.teal,
        description: 'استكشاف المحميات الطبيعية والبيئة',
      ),
      ActivityModel(
        id: 'archaeological',
        name: 'Archaeological',
        nameAr: 'آثار',
        icon: PhosphorIcons.columns,
        color: Colors.brown,
        description: 'زيارة المواقع الأثرية والحضارات القديمة',
      ),
    ];
  }
}