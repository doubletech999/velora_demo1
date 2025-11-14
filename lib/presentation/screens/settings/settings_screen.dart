// lib/presentation/screens/settings/settings_screen.dart - نسخة محسنة للوضع الداكن
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/user_provider.dart';
import '../profile/edit_profile_sheet.dart';
import 'change_password_sheet.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_switch.dart';
import '../../../core/services/fcm_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _appVersion = '';
  final double _switchScale = 0.8;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Redirect guests to login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isGuest) {
        context.go('/login');
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _getAppVersion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _showEditProfileSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileSheet(),
    );
  }

  Future<void> _showChangePasswordSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChangePasswordSheet(),
    );
  }

  Future<void> _showFCMTokenDialog(BuildContext context) async {
    final token = FCMService.instance.fcmToken;
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يتم الحصول على FCM Token بعد. تأكد من أن الإشعارات مفعلة.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(PhosphorIcons.key, color: AppColors.primary),
            SizedBox(width: 8),
            Text('FCM Token'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'استخدم هذا Token لاختبار الإشعارات من Firebase Console:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                token,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 نصيحة: انسخ Token وأرسل إشعار من Firebase Console',
              style: TextStyle(fontSize: 11, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم نسخ Token إلى الحافظة'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(PhosphorIcons.copy, size: 18),
            label: const Text('نسخ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmation(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final localizations = AppLocalizations.ofOrThrow(context);

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.get('reset_settings_title')),
            content: Text(localizations.get('reset_settings_confirm')),
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
                  settingsProvider.resetSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.get('reset_settings_success'),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: Text(localizations.get('reset_settings')),
              ),
            ],
          ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localizations = AppLocalizations.ofOrThrow(context);

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.get('logout_title')),
            content: Text(localizations.get('logout_confirm')),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.get('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await userProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${localizations.get('error')}: $e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(localizations.get('logout')),
              ),
            ],
          ),
    );
  }

  Future<void> _openWebsite(String url) async {
    final localizations = AppLocalizations.ofOrThrow(context);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.get('cannot_open_link')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    final localizations = AppLocalizations.ofOrThrow(context);
    final emailUri = Uri(
      scheme: 'mailto',
      path: AppConstants.appEmail,
      queryParameters: {
        'subject': localizations.get('inquiry_subject'),
        'body': localizations.get('inquiry_body'),
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.get('cannot_open_email')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showAboutApp() async {
    final localizations = AppLocalizations.ofOrThrow(context);

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Image.asset(AppConstants.logoPath, width: 36, height: 36),
                const SizedBox(width: 12),
                Text(localizations.get('about_app_label')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.get('about_app_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${localizations.get('app_version')} $_appVersion',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.get('about_app_description'),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '${localizations.get('copyright')} ${DateTime.now().year} ${localizations.get('all_rights_reserved')}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _openWebsite(AppConstants.termsUrl),
                icon: const Icon(PhosphorIcons.file_text, size: 16),
                label: Text(localizations.get('terms_conditions')),
              ),
              TextButton.icon(
                onPressed: () => _openWebsite(AppConstants.privacyUrl),
                icon: const Icon(PhosphorIcons.shield, size: 16),
                label: Text(localizations.get('privacy_policy')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.get('close')),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    final localizations = AppLocalizations.ofOrThrow(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final bool isGuest = userProvider.isGuest;

    // الحصول على الألوان من الـ Theme
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.get('settings'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.info),
            onPressed: _showAboutApp,
          ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // قسم الحساب
                _buildSectionHeader(
                  context,
                  title: localizations.get('account'),
                  icon: PhosphorIcons.user_circle,
                ),
                _buildSettingsCard(
                  context,
                  children: [
                    // معلومات المستخدم
                    if (userProvider.user != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child:
                                  userProvider.user!.profileImageUrl != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(
                                          userProvider.user!.profileImageUrl!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Text(
                                        userProvider.user!.name
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userProvider.user!.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    userProvider.user!.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                PhosphorIcons.pencil_simple,
                                color: AppColors.primary,
                              ),
                              onPressed:
                                  isGuest
                                      ? null
                                      : () {
                                        HapticFeedback.lightImpact();
                                        _showEditProfileSheet();
                                      },
                              tooltip: localizations.get('edit_profile'),
                            ),
                          ],
                        ),
                      ),

                    _SettingItem(
                      title: localizations.get('edit_profile'),
                      subtitle: localizations.get('update_profile_info'),
                      icon: PhosphorIcons.user_focus,
                      onTap:
                          isGuest
                              ? null
                              : () {
                                HapticFeedback.lightImpact();
                                _showEditProfileSheet();
                              },
                      enabled: !isGuest,
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('change_password'),
                      subtitle: localizations.get('update_password'),
                      icon: PhosphorIcons.lock_key,
                      onTap:
                          isGuest
                              ? null
                              : () {
                                HapticFeedback.lightImpact();
                                _showChangePasswordSheet();
                              },
                      enabled: !isGuest,
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('language'),
                      subtitle: localizations.get('change_language'),
                      icon: PhosphorIcons.translate,
                      trailing: DropdownButton<String>(
                        value: languageProvider.currentLanguage,
                        underline: const SizedBox(),
                        icon: Icon(
                          PhosphorIcons.caret_down,
                          color: secondaryTextColor,
                          size: 18,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text(localizations.get('arabic')),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(localizations.get('english')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            HapticFeedback.mediumImpact();
                            languageProvider.changeLanguage(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // قسم التطبيق
                _buildSectionHeader(
                  context,
                  title: localizations.get('app_settings'),
                  icon: PhosphorIcons.gear,
                ),
                _buildSettingsCard(
                  context,
                  children: [
                    _SettingItem(
                      title: localizations.get('notifications'),
                      subtitle: localizations.get('enable_notifications'),
                      icon: PhosphorIcons.bell,
                      trailing: Transform.scale(
                        scale: _switchScale,
                        child: CustomSwitch(
                          value: settingsProvider.notificationsEnabled,
                          onChanged: (value) {
                            HapticFeedback.mediumImpact();
                            settingsProvider.setNotificationsEnabled(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    // FCM Token for testing (Development only)
                    // FCM Token للاختبار (للتطوير فقط)
                    _SettingItem(
                      title: 'FCM Token (للاختبار)',
                      subtitle: 'عرض Token لاختبار الإشعارات',
                      icon: PhosphorIcons.key,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showFCMTokenDialog(context);
                      },
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('dark_mode'),
                      subtitle: localizations.get('enable_dark_mode'),
                      icon: PhosphorIcons.moon,
                      trailing: Transform.scale(
                        scale: _switchScale,
                        child: CustomSwitch(
                          value: settingsProvider.darkModeEnabled,
                          onChanged: (value) {
                            HapticFeedback.mediumImpact();
                            settingsProvider.setDarkModeEnabled(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('map_type'),
                      subtitle: localizations.get('choose_map_type'),
                      icon: PhosphorIcons.map_trifold,
                      trailing: DropdownButton<String>(
                        value: settingsProvider.mapType,
                        underline: const SizedBox(),
                        icon: Icon(
                          PhosphorIcons.caret_down,
                          color: secondaryTextColor,
                          size: 18,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'standard',
                            child: Text(localizations.get('standard')),
                          ),
                          DropdownMenuItem(
                            value: 'satellite',
                            child: Text(localizations.get('satellite')),
                          ),
                          DropdownMenuItem(
                            value: 'terrain',
                            child: Text(localizations.get('terrain')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            HapticFeedback.mediumImpact();
                            settingsProvider.setMapType(value);
                          }
                        },
                      ),
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('temperature_unit'),
                      subtitle: localizations.get('change_temperature_unit'),
                      icon: PhosphorIcons.thermometer,
                      trailing: DropdownButton<bool>(
                        value: settingsProvider.useCelsius,
                        underline: const SizedBox(),
                        icon: Icon(
                          PhosphorIcons.caret_down,
                          color: secondaryTextColor,
                          size: 18,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text(localizations.get('celsius')),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(localizations.get('fahrenheit')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            HapticFeedback.mediumImpact();
                            settingsProvider.setUseCelsius(value);
                          }
                        },
                      ),
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('location_services'),
                      subtitle: localizations.get('enable_location_access'),
                      icon: PhosphorIcons.map_pin,
                      trailing: Transform.scale(
                        scale: _switchScale,
                        child: CustomSwitch(
                          value: settingsProvider.locationEnabled,
                          onChanged: (value) {
                            HapticFeedback.mediumImpact();
                            settingsProvider.setLocationEnabled(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // قسم الدعم
                _buildSectionHeader(
                  context,
                  title: localizations.get('support'),
                  icon: PhosphorIcons.question,
                ),
                _buildSettingsCard(
                  context,
                  children: [
                    _SettingItem(
                      title: localizations.get('help_and_faq'),
                      subtitle: localizations.get('get_help_using_app'),
                      icon: PhosphorIcons.info,
                      onTap: () => _openWebsite(AppConstants.faqUrl),
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('report_issue'),
                      subtitle: localizations.get('send_report_about_problem'),
                      icon: PhosphorIcons.warning,
                      onTap: _sendEmail,
                    ),
                    Divider(color: Theme.of(context).dividerTheme.color),

                    _SettingItem(
                      title: localizations.get('about_app'),
                      subtitle: localizations.get('app_info'),
                      icon: PhosphorIcons.info,
                      trailing: Text(
                        '${localizations.get('version')} $_appVersion',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      onTap: _showAboutApp,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // إعادة تعيين الإعدادات
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showResetConfirmation(context, settingsProvider);
                    },
                    icon: const Icon(PhosphorIcons.arrows_clockwise),
                    label: Text(localizations.get('reset_settings')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2C2C2E)
                              : Colors.grey[200],
                      foregroundColor: textColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // تسجيل الخروج
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showLogoutConfirmation(context);
                    },
                    icon: const Icon(PhosphorIcons.sign_out),
                    label: Text(localizations.get('logout')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const _SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, color: AppColors.primary, size: 20)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(PhosphorIcons.caret_right, color: secondaryTextColor)
                : null),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
