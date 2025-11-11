// lib/core/utils/guest_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/user_provider.dart';
import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';

/// نظام حماية للتحقق من صلاحيات المستخدم الضيف
class GuestGuard {
  /// التحقق من أن المستخدم ليس ضيفاً
  /// إذا كان ضيفاً، يعرض رسالة ويعيد false
  /// إذا كان مسجلاً، يعيد true
  static bool check(BuildContext context, {String? feature}) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.isGuest) {
      showGuestRestrictionDialog(context, feature: feature);
      return false;
    }
    
    return true;
  }
  
  /// عرض نافذة تنبيه للضيف
  static void showGuestRestrictionDialog(
    BuildContext context, {
    String? feature,
  }) {
    final localizations = AppLocalizations.ofOrThrow(context);
    
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
              // أيقونة القفل
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
              
              // العنوان
              Text(
                localizations.get('login_required'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // الوصف
              Text(
                feature != null
                    ? localizations.get('access_specific_feature_desc').replaceAll('{feature}', feature)
                    : localizations.get('access_feature_desc'),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // مميزات الحساب المسجل
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          PhosphorIcons.check_circle_fill,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations.get('registered_account_features'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(localizations.get('save_favorite_paths'), context),
                    _buildFeatureItem(localizations.get('track_completed_trips'), context),
                    _buildFeatureItem(localizations.get('collect_achievements'), context),
                    _buildFeatureItem(localizations.get('share_experiences'), context),
                    _buildFeatureItem(localizations.get('access_all_features'), context),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizations.get('later'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        // الانتقال لشاشة التسجيل
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizations.get('login'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
  
  /// بناء عنصر من مميزات الحساب
  static Widget _buildFeatureItem(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            PhosphorIcons.check,
            color: AppColors.success,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// عرض Snackbar بسيط للضيف
  static void showGuestSnackBar(BuildContext context, {String? message}) {
    final localizations = AppLocalizations.ofOrThrow(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              PhosphorIcons.warning_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message ?? localizations.get('must_login_to_access'),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: localizations.get('login_short'),
          textColor: Colors.white,
          onPressed: () {
            context.go('/login');
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  /// Widget للحماية - يلف محتوى ويعرض رسالة إذا كان المستخدم ضيف
  static Widget protect({
    required BuildContext context,
    required Widget child,
    Widget? guestWidget,
    String? feature,
  }) {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.isGuest) {
      return guestWidget ?? _buildGuestPlaceholder(context, feature);
    }
    
    return child;
  }
  
  /// بناء عنصر بديل للضيف
  static Widget _buildGuestPlaceholder(BuildContext context, String? feature) {
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.lock_simple,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            feature != null ? localizations.get('feature_not_available') : localizations.get('not_available'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.get('login_to_access'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(PhosphorIcons.sign_in, size: 18),
            label: Text(localizations.get('login')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}