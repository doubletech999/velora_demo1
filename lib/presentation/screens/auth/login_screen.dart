// lib/presentation/screens/auth/login_screen.dart - محسّنة لجميع الأجهزة
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/arabic_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isResendingVerification = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadRememberMeState();
  }

  /// تحميل حالة "تذكرني" المحفوظة
  Future<void> _loadRememberMeState() async {
    try {
      final authService = AuthService.instance;
      final rememberMe = await authService.getRememberMe();
      if (mounted) {
        setState(() {
          _rememberMe = rememberMe;
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحميل حالة تذكرني: $e');
    }
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      debugPrint('🔵 محاولة تسجيل الدخول...');

      final success = await userProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      final localizations = AppLocalizations.ofOrThrow(context);

      if (success && mounted) {
        debugPrint('✅ تم تسجيل الدخول بنجاح');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.get('login_welcome_message')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );

        context.go('/');
      } else if (mounted) {
        debugPrint('❌ فشل تسجيل الدخول: ${userProvider.error}');

        if (userProvider.requiresEmailVerification) {
          final emailForVerification =
              userProvider.pendingVerificationEmail ??
              _emailController.text.trim();
          final message =
              userProvider.infoMessage ??
              localizations.get('email_not_verified');

          await _showEmailVerificationPrompt(
            email: emailForVerification,
            message: message,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userProvider.error ?? localizations.get('login_failed'),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول: $e');

      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.get('error')}: ${e.toString()}'),
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final localizations = AppLocalizations.ofOrThrow(context);

      debugPrint('🔵 بدء تسجيل الدخول كضيف من LoginScreen...');

      await userProvider.loginAsGuest();

      debugPrint('🔍 بعد loginAsGuest:');
      debugPrint('   - user: ${userProvider.user?.name}');
      debugPrint('   - isGuest: ${userProvider.isGuest}');
      debugPrint('   - isLoggedIn: ${userProvider.isLoggedIn}');

      if (mounted) {
        if (userProvider.user != null) {
          debugPrint('✅ نجح تسجيل الدخول كضيف - الانتقال للصفحة الرئيسية');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    PhosphorIcons.user_circle,
                    color: Colors.white,
                    size: context.iconSize(),
                  ),
                  SizedBox(width: context.sm),
                  Expanded(
                    child: Text(localizations.get('guest_login_welcome')),
                  ),
                ],
              ),
              backgroundColor: AppColors.info,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              duration: const Duration(seconds: 4),
            ),
          );

          context.go('/');
        } else {
          debugPrint('❌ فشل تسجيل الدخول كضيف - user is null');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.get('guest_login_failed')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول كضيف: $e');

      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.get('error')}: ${e.toString()}'),
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEmailVerificationPrompt({
    required String email,
    required String message,
  }) async {
    if (!mounted) return;
    final localizations = AppLocalizations.ofOrThrow(context);
    final normalizedEmail =
        email.trim().isNotEmpty ? email.trim() : _emailController.text.trim();

    if (normalizedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.get('enter_your_email')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 24 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.envelope_simple_open,
                    color: AppColors.primary,
                    size: context.iconSize() * 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.get('verify_email_title'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.at,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          normalizedEmail,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.get('open_email_and_verify'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isResendingVerification
                            ? null
                            : () => _resendVerificationEmail(
                              email: normalizedEmail,
                              sheetContext: sheetContext,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        _isResendingVerification
                            ? SizedBox(
                              width: context.iconSize(),
                              height: context.iconSize(),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.arrow_counter_clockwise,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.get('resend_verification_link'),
                                ),
                              ],
                            ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(localizations.get('back_to_login')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _resendVerificationEmail({
    required String email,
    required BuildContext sheetContext,
  }) async {
    if (_isResendingVerification) return;
    final localizations = AppLocalizations.ofOrThrow(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() => _isResendingVerification = true);

    try {
      final success = await userProvider.resendVerificationEmail(email: email);
      final message =
          success
              ? (userProvider.infoMessage ??
                  localizations.get('verification_email_sent'))
              : (userProvider.error ??
                  localizations.get('verification_email_user_not_found'));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

      if (success && Navigator.of(sheetContext).canPop()) {
        Navigator.of(sheetContext).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.get('error')}: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResendingVerification = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // خلفية متدرجة محسّنة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [
                          AppColors.primary.withOpacity(0.9),
                          AppColors.primary.withOpacity(0.7),
                          colorScheme.surface,
                        ]
                        : [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                          Colors.white,
                        ],
                stops: isDark ? const [0.0, 0.4, 1.0] : const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // المحتوى الرئيسي
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  mobile: context.md,
                  tablet: (context.xl * 2).toDouble(),
                  desktop: screenWidth * 0.2,
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      screenHeight -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // مساحة علوية ديناميكية
                    SizedBox(
                      height:
                          isKeyboardOpen
                              ? context.responsive(
                                mobile: context.md,
                                tablet: context.lg,
                              )
                              : context.responsive(
                                mobile: context.xl,
                                tablet: (context.xl * 1.5).toDouble(),
                              ),
                    ),

                    // الشعار والعنوان
                    if (!isKeyboardOpen)
                      _buildHeader(context, isDark, localizations),

                    // كارت تسجيل الدخول
                    _buildLoginCard(
                      context,
                      isDark,
                      colorScheme,
                      localizations,
                      screenWidth,
                    ),

                    // مساحة سفلية
                    SizedBox(
                      height:
                          isKeyboardOpen
                              ? context.responsive(
                                mobile: context.md,
                                tablet: context.lg,
                              )
                              : context.responsive(
                                mobile: context.lg,
                                tablet: context.xl,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations localizations,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // شعار التطبيق
          Container(
            width: context.responsive(mobile: 100, tablet: 130, desktop: 150),
            height: context.responsive(mobile: 100, tablet: 130, desktop: 150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                padding: EdgeInsets.all(
                  context.responsive(mobile: 14, tablet: 18, desktop: 20),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      PhosphorIcons.compass,
                      size: context.responsive(
                        mobile: 56,
                        tablet: 72,
                        desktop: 80,
                      ),
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ),
          ),

          SizedBox(
            height: context.responsive(mobile: context.lg, tablet: context.xl),
          ),

          // اسم التطبيق
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: context.fontSize(
                context.responsive(mobile: 28, tablet: 32, desktop: 36),
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.6),
                  blurRadius: isDark ? 8 : 14,
                  offset: const Offset(0, 2),
                ),
                if (!isDark)
                  Shadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(
            height: context.responsive(mobile: context.xs, tablet: context.sm),
          ),

          // رسالة الترحيب
          Text(
            localizations.get('welcome_back'),
            style: TextStyle(
              fontSize: context.fontSize(
                context.responsive(mobile: 14, tablet: 16, desktop: 18),
              ),
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.white,
              height: 1.5,
              shadows: [
                Shadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.4),
                  blurRadius: isDark ? 6 : 10,
                  offset: const Offset(0, 1),
                ),
                if (!isDark)
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 0.5),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(
            height: context.responsive(
              mobile: context.xl,
              tablet: (context.xl * 1.5).toDouble(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    AppLocalizations localizations,
    double screenWidth,
  ) {
    final maxCardWidth = context.responsive(
      mobile: double.infinity,
      tablet: 500.0,
      desktop: 450.0,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxCardWidth),
        child: SlideTransition(
          position: _slideAnimation,
          child: Card(
            elevation: isDark ? 12 : 8,
            shadowColor:
                isDark
                    ? Colors.black.withOpacity(0.8)
                    : AppColors.primary.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                context.responsive(mobile: 20, tablet: 24, desktop: 28),
              ),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: context.responsive(mobile: 0, tablet: context.md),
            ),
            child: Container(
              padding: EdgeInsets.all(
                context.responsive(
                  mobile: context.lg,
                  tablet: context.xl,
                  desktop: (context.xl * 1.2).toDouble(),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // عنوان النموذج
                    Text(
                      localizations.get('login'),
                      style: TextStyle(
                        fontSize: context.fontSize(
                          context.responsive(
                            mobile: 22,
                            tablet: 26,
                            desktop: 28,
                          ),
                        ),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: context.responsive(
                        mobile: context.xs,
                        tablet: context.sm,
                      ),
                    ),

                    Text(
                      localizations.get('enter_details_to_continue'),
                      style: TextStyle(
                        fontSize: context.fontSize(
                          context.responsive(
                            mobile: 13,
                            tablet: 14,
                            desktop: 15,
                          ),
                        ),
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: context.responsive(
                        mobile: context.lg,
                        tablet: context.xl,
                      ),
                    ),

                    // حقل البريد الإلكتروني
                    ArabicTextField(
                      controller: _emailController,
                      labelText: localizations.get('email'),
                      hintText: localizations.get('enter_your_email'),
                      prefixIcon: PhosphorIcons.envelope,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(
                      height: context.responsive(
                        mobile: context.md,
                        tablet: context.lg,
                      ),
                    ),

                    // حقل كلمة المرور
                    ArabicTextField(
                      controller: _passwordController,
                      labelText: localizations.get('password'),
                      hintText: localizations.get('enter_password'),
                      prefixIcon: PhosphorIcons.lock,
                      obscureText: !_isPasswordVisible,
                      validator: Validators.validatePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? PhosphorIcons.eye_slash
                              : PhosphorIcons.eye,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          size: context.iconSize(),
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),

                    SizedBox(
                      height: context.responsive(
                        mobile: context.sm,
                        tablet: context.md,
                      ),
                    ),

                    // تذكرني ونسيت كلمة المرور
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // تذكرني
                        Flexible(
                          flex: 2,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: context.responsive(
                                    mobile: 20,
                                    tablet: 24,
                                  ),
                                  height: context.responsive(
                                    mobile: 20,
                                    tablet: 24,
                                  ),
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                SizedBox(width: context.xs),
                                Flexible(
                                  child: Text(
                                    localizations.get('remember_me'),
                                    style: TextStyle(
                                      fontSize: context.fontSize(
                                        context.responsive(
                                          mobile: 13,
                                          tablet: 14,
                                        ),
                                      ),
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // نسيت كلمة المرور
                        Flexible(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.push('/forgot-password');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.xs,
                                  vertical: context.xs,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                localizations.get('forgot_password'),
                                style: TextStyle(
                                  fontSize: context.fontSize(
                                    context.responsive(mobile: 13, tablet: 14),
                                  ),
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: context.responsive(
                        mobile: context.lg,
                        tablet: context.xl,
                      ),
                    ),

                    // زر تسجيل الدخول
                    SizedBox(
                      width: double.infinity,
                      height: context.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.adaptive(24),
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.responsive(mobile: 12, tablet: 14),
                            ),
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: context.iconSize(),
                                  height: context.iconSize(),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                )
                                : Text(
                                  localizations.get('login'),
                                  style: TextStyle(
                                    fontSize: context.fontSize(
                                      context.responsive(
                                        mobile: 15,
                                        tablet: 16,
                                        desktop: 17,
                                      ),
                                    ),
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                      ),
                    ),

                    SizedBox(
                      height: context.responsive(
                        mobile: context.md,
                        tablet: context.lg,
                      ),
                    ),

                    // زر الدخول كضيف
                    SizedBox(
                      width: double.infinity,
                      height: context.buttonHeight,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _loginAsGuest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary,
                            width: context.responsive(mobile: 1.5, tablet: 2),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.adaptive(16),
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.responsive(mobile: 12, tablet: 14),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.user_circle,
                              size: context.iconSize(),
                            ),
                            SizedBox(
                              width: context.responsive(
                                mobile: context.xs,
                                tablet: context.sm,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                localizations.get('login_as_guest_view_only'),
                                style: TextStyle(
                                  fontSize: context.fontSize(
                                    context.responsive(
                                      mobile: 14,
                                      tablet: 15,
                                      desktop: 16,
                                    ),
                                  ),
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: context.responsive(
                        mobile: context.lg,
                        tablet: context.xl,
                      ),
                    ),

                    // رابط التسجيل
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: context.xs,
                      children: [
                        Text(
                          localizations.get('dont_have_account'),
                          style: TextStyle(
                            fontSize: context.fontSize(
                              context.responsive(mobile: 13, tablet: 14),
                            ),
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.xs,
                              vertical: context.xs,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            localizations.get('create_account'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: context.fontSize(
                                context.responsive(mobile: 13, tablet: 14),
                              ),
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
