// lib/presentation/screens/profile/profile_screen.dart - محسن ومنسق
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/guest_guard.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../providers/saved_paths_provider.dart';
import '../../widgets/common/loading_indicator.dart';

import 'completed_trips_sheet.dart';
import 'edit_profile_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // وظائف التحميل والبيانات
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
  }

  // ═══════════════════════════════════════════════════════════════════
  // وظائف تسجيل الخروج
  // ═══════════════════════════════════════════════════════════════════

  void _showLogoutConfirmation() {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.get('logout')),
        content: Text(
          languageProvider.isArabic 
            ? 'هل أنت متأكد من تسجيل الخروج؟'
            : 'Are you sure you want to logout?'
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(localizations.get('logout')),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();
    
    if (mounted) {
      context.go('/login');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // وظائف فتح الروابط
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      _showSnackBar(
        message: languageProvider.isArabic 
          ? 'لا يمكن فتح الرابط'
          : 'Cannot open link',
        isError: true,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // وظائف حول التطبيق
  // ═══════════════════════════════════════════════════════════════════


  // ═══════════════════════════════════════════════════════════════════
  // وظائف تغيير اللغة
  // ═══════════════════════════════════════════════════════════════════

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<LanguageProvider>(
        builder: (context, provider, child) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(height: 16),

              // العنوان
              Text(
                provider.isArabic ? 'اختر اللغة' : 'Choose Language',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // خيار اللغة العربية
              _LanguageOption(
                flag: 'ع',
                title: 'العربية',
                subtitle: 'Arabic',
                isSelected: provider.isArabic,
                onTap: () {
                  provider.changeLanguage('ar');
                  Navigator.pop(context);
                  _showLanguageChangeSnackBar('ar');
                },
              ),
              
              // خيار اللغة الإنجليزية
              _LanguageOption(
                flag: 'En',
                title: 'English',
                subtitle: 'الإنجليزية',
                isSelected: provider.isEnglish,
                onTap: () {
                  provider.changeLanguage('en');
                  Navigator.pop(context);
                  _showLanguageChangeSnackBar('en');
                },
              ),
              
              const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showLanguageChangeSnackBar(String newLanguage) {
    final message = newLanguage == 'ar' 
        ? 'تم تغيير اللغة إلى العربية'
        : 'Language changed to English';
        
    _showSnackBar(
      message: message,
      icon: PhosphorIcons.check_circle,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // وظائف مساعدة
  // ═══════════════════════════════════════════════════════════════════

  void _showSnackBar({
    required String message,
    IconData? icon,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    return Divider(
      color: theme.dividerColor,
      thickness: 1,
      height: 1,
      indent: context.responsive(mobile: 60, tablet: 70, desktop: 80),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // البناء الرئيسي للواجهة
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    
    final userProvider = Provider.of<UserProvider>(context);
    final savedPathsProvider = Provider.of<SavedPathsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    
    final user = userProvider.user;
    final savedPathsCount = savedPathsProvider.savedPaths.length;
    
    // شاشة التحميل
    if (_isLoading || user == null) {
      return Scaffold(
        body: LoadingIndicator(
          message: languageProvider.isArabic 
            ? 'جاري تحميل البيانات...'
            : 'Loading data...',
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // شريط التطبيق مع معلومات المستخدم
          _buildProfileHeader(languageProvider, user),
          
          // إحصائيات المستخدم
          _buildUserStats(localizations, user, savedPathsCount),
          
          SliverToBoxAdapter(
            child: SizedBox(height: context.responsive(mobile: 16, tablet: 20, desktop: 24)),
          ),
          
          // قائمة الخيارات الأساسية
          _buildMainOptions(localizations, languageProvider),
          
          SliverToBoxAdapter(
            child: SizedBox(height: context.responsive(mobile: 16, tablet: 20, desktop: 24)),
          ),
          
          // الإعدادات والمساعدة
          _buildSettingsOptions(localizations, languageProvider),
          
          SliverToBoxAdapter(
            child: SizedBox(height: context.responsive(mobile: 16, tablet: 20, desktop: 24)),
          ),
          
          // زر تسجيل الخروج
          _buildLogoutOption(localizations, languageProvider),
          
          // مساحة إضافية في الأسفل
          SliverToBoxAdapter(
            child: SizedBox(
              height: context.responsive(mobile: 100, tablet: 120, desktop: 140),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // بناء أقسام الواجهة
  // ═══════════════════════════════════════════════════════════════════

  SliverAppBar _buildProfileHeader(LanguageProvider languageProvider, user) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SliverAppBar(
      expandedHeight: context.responsive(mobile: 240, tablet: 280, desktop: 300),
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        // زر تغيير اللغة
        Container(
          margin: EdgeInsets.all(context.responsive(mobile: 8, tablet: 10)),
          child: Material(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(context.responsive(mobile: 20, tablet: 24)),
            child: InkWell(
              borderRadius: BorderRadius.circular(context.responsive(mobile: 20, tablet: 24)),
              onTap: _showLanguageBottomSheet,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(mobile: 12, tablet: 14),
                  vertical: context.responsive(mobile: 6, tablet: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.translate,
                      color: AppColors.primary,
                      size: context.iconSize(),
                    ),
                    SizedBox(width: context.xs),
                    Text(
                      languageProvider.isArabic ? 'EN' : 'ع',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: context.fontSize(context.responsive(mobile: 14, tablet: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // زر الإعدادات
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(context.responsive(mobile: 8, tablet: 10)),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.gear,
              color: AppColors.primary,
              size: context.iconSize(),
            ),
          ),
          onPressed: () {
            if (!GuestGuard.check(context, feature: 'الإعدادات')) {
              return;
            }
            context.go('/profile/settings');
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // الخلفية المتدرجة
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            // الحافة المنحنية السفلية
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: context.responsive(mobile: 25, tablet: 30, desktop: 35),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.responsive(mobile: 30, tablet: 35, desktop: 40)),
                    topRight: Radius.circular(context.responsive(mobile: 30, tablet: 35, desktop: 40)),
                  ),
                ),
              ),
            ),
            
            // معلومات المستخدم
            Positioned(
              bottom: context.responsive(mobile: 30, tablet: 40, desktop: 50),
              left: 0,
              right: 0,
              child: _buildUserInfo(user),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildUserInfo(user) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        // صورة المستخدم
        Container(
          width: context.responsive(mobile: 100, tablet: 120, desktop: 140),
          height: context.responsive(mobile: 100, tablet: 120, desktop: 140),
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.cardColor,
              width: context.responsive(mobile: 3, tablet: 4, desktop: 5),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                blurRadius: context.responsive(mobile: 10, tablet: 15, desktop: 20),
                offset: Offset(0, context.responsive(mobile: 5, tablet: 7, desktop: 10)),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.responsive(mobile: 50, tablet: 60, desktop: 70)),
            child: user.profileImageUrl != null
                ? Image.network(
                    user.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: context.fontSize(context.responsive(mobile: 40, tablet: 50, desktop: 60)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: context.fontSize(context.responsive(mobile: 40, tablet: 50, desktop: 60)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(height: context.responsive(mobile: 8, tablet: 12, desktop: 16)),
        
        // اسم المستخدم
        Text(
          user.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.fontSize(context.responsive(mobile: 20, tablet: 24, desktop: 28)),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: context.responsive(mobile: 4, tablet: 6, desktop: 8)),
        
        // بريد المستخدم الإلكتروني
        Text(
          user.email,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: context.fontSize(context.responsive(mobile: 15, tablet: 17, desktop: 19)),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildUserStats(localizations, user, int savedPathsCount) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.responsive(mobile: 16, tablet: 20, desktop: 24),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: context.responsive(mobile: 16, tablet: 24, desktop: 32),
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(context.responsive(mobile: 16, tablet: 20, desktop: 24)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: context.responsive(mobile: 10, tablet: 15, desktop: 20),
              offset: Offset(0, context.responsive(mobile: 2, tablet: 3, desktop: 4)),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                value: user.completedTrips.toString(),
                label: localizations.get('completed_trips'),
                icon: PhosphorIcons.check_circle,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: context.responsive(mobile: 8, tablet: 12, desktop: 16)),
            Expanded(
              child: _StatItem(
                value: savedPathsCount.toString(),
                label: localizations.get('saved_trips'),
                icon: PhosphorIcons.bookmark_simple,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: context.responsive(mobile: 8, tablet: 12, desktop: 16)),
            Expanded(
              child: _StatItem(
                value: user.achievements.toString(),
                label: localizations.get('achievements'),
                icon: PhosphorIcons.trophy,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMainOptions(localizations, LanguageProvider languageProvider) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(context.responsive(mobile: 16, tablet: 24, desktop: 32)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(context.responsive(mobile: 16, tablet: 20, desktop: 24)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: context.responsive(mobile: 10, tablet: 15, desktop: 20),
              offset: Offset(0, context.responsive(mobile: 2, tablet: 3, desktop: 4)),
            ),
          ],
        ),
        child: Column(
          children: [
            // حسابي
            _MenuItem(
              icon: PhosphorIcons.user,
              title: languageProvider.isArabic ? 'حسابي' : 'My Account',
              subtitle: languageProvider.isArabic 
                ? 'تعديل المعلومات الشخصية'
                : 'Edit personal information',
              onTap: () {
                if (!GuestGuard.check(context, feature: 'تعديل الحساب')) {
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const EditProfileSheet(),
                );
              },
            ),
            _buildDivider(),

            // المحفوظات
            _MenuItem(
              icon: PhosphorIcons.bookmark_simple,
              title: localizations.get('saved'),
              subtitle: languageProvider.isArabic 
                ? 'عرض وإدارة المسارات المحفوظة'
                : 'View and manage saved paths',
              onTap: () {
                if (!GuestGuard.check(context, feature: 'المسارات المحفوظة')) {
                  return;
                }
                context.go('/profile/saved');
              },
            ),
            _buildDivider(),

            // رحلاتي
            _MenuItem(
              icon: PhosphorIcons.check_circle,
              title: localizations.get('my_trips'),
              subtitle: languageProvider.isArabic 
                ? 'المسارات التي أكملتها'
                : 'Paths you have completed',
              onTap: () {
                if (!GuestGuard.check(context, feature: 'رحلاتي المكتملة')) {
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const CompletedTripsSheet(),
                );
              },
            ),
            _buildDivider(),

            // الإنجازات
            _MenuItem(
              icon: PhosphorIcons.trophy,
              title: localizations.get('achievements'),
              subtitle: languageProvider.isArabic 
                ? 'الإنجازات التي حققتها'
                : 'Achievements you have earned',
              onTap: () {
                if (!GuestGuard.check(context, feature: 'الإنجازات')) {
                  return;
                }
                context.go('/profile/achievements');
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSettingsOptions(localizations, LanguageProvider languageProvider) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.responsive(mobile: 16, tablet: 24, desktop: 32),
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(context.responsive(mobile: 16, tablet: 20, desktop: 24)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: context.responsive(mobile: 10, tablet: 15, desktop: 20),
              offset: Offset(0, context.responsive(mobile: 2, tablet: 3, desktop: 4)),
            ),
          ],
        ),
        child: Column(
          children: [
            // الإعدادات
            _MenuItem(
              icon: PhosphorIcons.gear,
              title: localizations.get('settings'),
              subtitle: languageProvider.isArabic 
                ? 'تخصيص التطبيق'
                : 'Customize the app',
              onTap: () {
                if (!GuestGuard.check(context, feature: 'الإعدادات')) {
                  return;
                }
                context.go('/profile/settings');
              },
            ),
            _buildDivider(),

            // اللغة
            _MenuItem(
              icon: PhosphorIcons.translate,
              title: localizations.get('language'),
              subtitle: languageProvider.isArabic 
                ? 'تغيير لغة التطبيق'
                : 'Change app language',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      languageProvider.isArabic ? 'العربية' : 'English',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIcons.caret_right,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
              onTap: _showLanguageBottomSheet,
            ),
            _buildDivider(),

            // المساعدة والدعم
            _MenuItem(
              icon: PhosphorIcons.question,
              title: localizations.get('help_support'),
              subtitle: languageProvider.isArabic 
                ? 'الأسئلة الشائعة والدعم الفني'
                : 'FAQ and technical support',
              onTap: () => _openUrl(AppConstants.faqUrl),
            ),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLogoutOption(localizations, LanguageProvider languageProvider) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(context.responsive(mobile: 16, tablet: 24, desktop: 32)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(context.responsive(mobile: 16, tablet: 20, desktop: 24)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: context.responsive(mobile: 10, tablet: 15, desktop: 20),
              offset: Offset(0, context.responsive(mobile: 2, tablet: 3, desktop: 4)),
            ),
          ],
        ),
        child: _MenuItem(
          icon: PhosphorIcons.sign_out,
          title: localizations.get('logout'),
          subtitle: languageProvider.isArabic 
            ? 'الخروج من حسابك'
            : 'Sign out of your account',
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          onTap: _showLogoutConfirmation,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// عنصر الإحصائيات
// ═══════════════════════════════════════════════════════════════════

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // أيقونة الإحصائية
        Container(
          width: context.responsive(mobile: 40, tablet: 50, desktop: 60),
          height: context.responsive(mobile: 40, tablet: 50, desktop: 60),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: context.iconSize(isLarge: true),
            ),
          ),
        ),
        SizedBox(height: context.responsive(mobile: 8, tablet: 12, desktop: 16)),

        // القيمة
        Text(
          value,
          style: TextStyle(
            fontSize: context.fontSize(context.responsive(mobile: 18, tablet: 22, desktop: 26)),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: context.responsive(mobile: 4, tablet: 6, desktop: 8)),

        // التسمية
        Text(
          label,
          style: TextStyle(
            fontSize: context.fontSize(context.responsive(mobile: 12, tablet: 14, desktop: 16)),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// عنصر القائمة
// ═══════════════════════════════════════════════════════════════════

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.responsive(mobile: 16, tablet: 20, desktop: 24),
        vertical: context.responsive(mobile: 8, tablet: 12, desktop: 16),
      ),
      leading: Container(
        width: context.responsive(mobile: 40, tablet: 48, desktop: 56),
        height: context.responsive(mobile: 40, tablet: 48, desktop: 56),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: context.iconSize(isLarge: true),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: context.fontSize(context.responsive(mobile: 16, tablet: 18, desktop: 20)),
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: context.fontSize(context.responsive(mobile: 12, tablet: 14, desktop: 16)),
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ?? Icon(
        PhosphorIcons.caret_right,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        size: context.iconSize(),
      ),
      onTap: onTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// خيار اللغة
// ═══════════════════════════════════════════════════════════════════

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : (isDark ? theme.colorScheme.surface : Colors.grey[100]!),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            flag,
            style: TextStyle(
              fontSize: flag == 'En' ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: isSelected 
                ? AppColors.primary 
                : (isDark ? theme.textTheme.bodyMedium?.color : Colors.grey[600]!),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: isSelected
          ? const Icon(
              PhosphorIcons.check_circle_fill,
              color: AppColors.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}