// lib/presentation/screens/profile/profile_screen.dart - محسن ومنسق
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_utils.dart';
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

  void _showAboutDialog() {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showAboutDialog(
      context: context,
      applicationName: 'Velora',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/logo.png',
          width: 64,
          height: 64,
        ),
      ),
      children: [
        Text(
          languageProvider.isArabic 
            ? 'تطبيق لاستكشاف المسارات السياحية في فلسطين'
            : 'An app for exploring tourist routes in Palestine'
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => _openUrl(AppConstants.termsUrl),
              child: Text(
                languageProvider.isArabic 
                  ? 'شروط الاستخدام'
                  : 'Terms of Service'
              ),
            ),
            TextButton(
              onPressed: () => _openUrl(AppConstants.privacyUrl),
              child: Text(
                languageProvider.isArabic 
                  ? 'سياسة الخصوصية'
                  : 'Privacy Policy'
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // وظائف تغيير اللغة
  // ═══════════════════════════════════════════════════════════════════

  void _showLanguageBottomSheet() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<LanguageProvider>(
        builder: (context, provider, child) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
        ),
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
    return const Divider(
      color: AppColors.divider,
      thickness: 1,
      height: 1,
      indent: 60,
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
          
          // قائمة الخيارات الأساسية
          _buildMainOptions(localizations, languageProvider),
          
          // الإعدادات والمساعدة
          _buildSettingsOptions(localizations, languageProvider),
          
          // زر تسجيل الخروج
          _buildLogoutOption(localizations, languageProvider),
          
          // مساحة إضافية في الأسفل
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // بناء أقسام الواجهة
  // ═══════════════════════════════════════════════════════════════════

  SliverAppBar _buildProfileHeader(LanguageProvider languageProvider, user) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        // زر تغيير اللغة
        Container(
          margin: const EdgeInsets.all(8),
          child: Material(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _showLanguageBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.translate,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      languageProvider.isArabic ? 'EN' : 'ع',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIcons.gear,
              color: AppColors.primary,
            ),
          ),
          onPressed: () => context.go('/profile/settings'),
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
                height: 25,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            
            // معلومات المستخدم
            Positioned(
              bottom: 30,
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
    return Column(
      children: [
        // صورة المستخدم
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: user.profileImageUrl != null
                ? Image.network(
                    user.profileImageUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        
        // اسم المستخدم
        Text(
          user.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // بريد المستخدم الإلكتروني
        Text(
          user.email,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildUserStats(localizations, user, int savedPathsCount) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
            Expanded(
              child: _StatItem(
                value: savedPathsCount.toString(),
                label: localizations.get('saved_trips'),
                icon: PhosphorIcons.bookmark_simple,
                color: AppColors.primary,
              ),
            ),
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
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
              onTap: () => context.go('/profile/saved'),
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
              onTap: () => context.go('/profile/achievements'),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSettingsOptions(localizations, LanguageProvider languageProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
              onTap: () => context.go('/profile/settings'),
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
                    color: AppColors.textSecondary,
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
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
    return Column(
      children: [
        // أيقونة الإحصائية
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // القيمة
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),

        // التسمية
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing ?? Icon(
        PhosphorIcons.caret_right,
        color: AppColors.textSecondary,
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
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : Colors.grey[100],
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
                : Colors.grey[600],
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
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