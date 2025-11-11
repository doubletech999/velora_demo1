// lib/presentation/screens/auth/register_screen.dart - محدث للعمل مع Laravel API
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/arabic_text_field.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/password_strength_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  // مؤشر قوة كلمة المرور
  double _passwordStrength = 0.0;
  String _passwordStrengthText = 'ضعيفة';
  Color _passwordStrengthColor = Colors.red;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  List<String> _steps = [];

  @override
  void initState() {
    super.initState();

    // إعداد متحكم الرسوم المتحركة
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

    // مراقبة تغييرات كلمة المرور لحساب القوة
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _initializeSteps(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    _steps = [
      localizations.get('personal_information'),
      localizations.get('account_information'),
      localizations.get('confirmation'),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    final localizations = AppLocalizations.ofOrThrow(context);
    double strength = 0.0;
    String strengthText = localizations.get('weak');
    Color strengthColor = Colors.red;

    if (password.isEmpty) {
      strength = 0.0;
      strengthText = localizations.get('weak');
      strengthColor = Colors.red;
    } else if (password.length < 6) {
      strength = 0.2;
      strengthText = localizations.get('weak');
      strengthColor = Colors.red;
    } else if (password.length < 8) {
      strength = 0.4;
      strengthText = localizations.get('medium');
      strengthColor = Colors.orange;
    } else {
      // تحقق من تعقيد كلمة المرور
      final hasUppercase = password.contains(RegExp(r'[A-Z]'));
      final hasLowercase = password.contains(RegExp(r'[a-z]'));
      final hasDigits = password.contains(RegExp(r'[0-9]'));
      final hasSpecialChars = password.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      );

      final complexity =
          [
            hasUppercase,
            hasLowercase,
            hasDigits,
            hasSpecialChars,
          ].where((c) => c).length;

      if (complexity == 1) {
        strength = 0.4;
        strengthText = localizations.get('medium');
        strengthColor = Colors.orange;
      } else if (complexity == 2) {
        strength = 0.6;
        strengthText = localizations.get('medium');
        strengthColor = Colors.orange;
      } else if (complexity == 3) {
        strength = 0.8;
        strengthText = localizations.get('strong');
        strengthColor = Colors.green;
      } else if (complexity == 4) {
        strength = 1.0;
        strengthText = localizations.get('very_strong');
        strengthColor = Colors.green.shade700;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  void _nextStep() {
    // تحقق من صحة الخطوة الحالية
    if (_currentStep == 0) {
      // Validate name (required) - phone is optional
      final nameError = Validators.validateName(_nameController.text);
      if (nameError != null) {
        _showError(nameError);
        return;
      }

      // Phone is optional, but if provided, it should be valid
      final phoneError = Validators.validatePhone(_phoneController.text);
      if (phoneError != null) {
        _showError(phoneError);
        return;
      }
    } else if (_currentStep == 1) {
      // Validate email (required) - must be valid format
      final emailError = Validators.validateEmail(_emailController.text);
      if (emailError != null) {
        _showError(emailError);
        return;
      }

      final localizations = AppLocalizations.ofOrThrow(context);
      if (_passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showError(localizations.get('please_complete_required_fields'));
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showError(localizations.get('passwords_dont_match'));
        return;
      }

      if (_passwordStrength < 0.4) {
        _showError(localizations.get('password_too_weak'));
        return;
      }
    }

    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _register() async {
    final localizations = AppLocalizations.ofOrThrow(context);
    if (!_acceptTerms) {
      _showError(localizations.get('must_agree_to_terms'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // استدعاء register مع جميع البيانات المطلوبة
      final success = await userProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        language: 'ar', // اللغة الافتراضية
      );

      if (success && mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final message =
            userProvider.infoMessage ??
            localizations.get('check_email_and_confirm');

        await _showVerificationDialog(message: message);
      } else if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        _showError(
          userProvider.error ?? localizations.get('account_created_failed'),
        );
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        _showError('${localizations.get('error')}: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openTermsAndConditions() async {
    context.push('/terms-and-conditions');
  }

  Future<void> _openPrivacyPolicy() async {
    final localizations = AppLocalizations.ofOrThrow(context);
    final uri = Uri.parse(AppConstants.privacyUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError(localizations.get('cannot_open_link'));
    }
  }

  Future<void> _showVerificationDialog({required String message}) async {
    if (!mounted) return;
    final localizations = AppLocalizations.ofOrThrow(context);

    final shouldGoToLogin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(localizations.get('verify_email_title')),
          content: Text(
            message,
            textAlign: TextAlign.start,
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.get('later')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(localizations.get('go_to_login')),
            ),
          ],
        );
      },
    );

    if (shouldGoToLogin == true && mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenWidth = MediaQuery.of(context).size.width;

    // Initialize steps with localization
    if (_steps.isEmpty) {
      _initializeSteps(context);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.get('create_new_account'),
        showBackButton: true,
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // المحتوى الرئيسي
          SafeArea(
            child: Column(
              children: [
                // مؤشر الخطوات (يُخفى عند فتح لوحة المفاتيح على الشاشات الصغيرة)
                if (!isKeyboardOpen ||
                    ResponsiveUtils.isTablet ||
                    ResponsiveUtils.isDesktop)
                  _buildStepIndicator(),
                if (!isKeyboardOpen ||
                    ResponsiveUtils.isTablet ||
                    ResponsiveUtils.isDesktop)
                  SizedBox(
                    height: context.responsive(
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    ),
                  ),

                // محتوى النموذج
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsive(
                            mobile: context.lg,
                            tablet: context.xl * 1.5,
                            desktop: screenWidth * 0.15,
                          ),
                          vertical: context.responsive(
                            mobile: isKeyboardOpen ? context.sm : context.lg,
                            tablet: context.xl,
                            desktop: context.xl * 1.5,
                          ),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: context.responsive(
                                mobile: double.infinity,
                                tablet: 600,
                                desktop: 700,
                              ),
                              minHeight:
                                  constraints.maxHeight -
                                  (isKeyboardOpen
                                      ? 0
                                      : (context.responsive(
                                        mobile: 100,
                                        tablet: 120,
                                        desktop: 140,
                                      ))),
                            ),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // محتوى الخطوة الحالية
                                      if (_currentStep == 0)
                                        _buildPersonalInfoStep(),
                                      if (_currentStep == 1)
                                        _buildAccountInfoStep(),
                                      if (_currentStep == 2)
                                        _buildConfirmationStep(),

                                      SizedBox(
                                        height: context.responsive(
                                          mobile: isKeyboardOpen ? 16 : 32,
                                          tablet: 40,
                                          desktop: 48,
                                        ),
                                      ),

                                      // أزرار التنقل
                                      _buildNavigationButtons(localizations),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // مؤشر التحميل
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(
                      context.responsive(mobile: 20, tablet: 24, desktop: 28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: context.iconSize(isLarge: true),
                          height: context.iconSize(isLarge: true),
                          child: const CircularProgressIndicator(),
                        ),
                        SizedBox(
                          height: context.responsive(
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          ),
                        ),
                        Text(
                          localizations.get('creating_account'),
                          style: TextStyle(
                            fontSize: context.fontSize(
                              context.responsive(
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: ResponsiveUtils.isSmallPhone ? 8.0 : 16.0,
          tablet: 24.0,
          desktop: 32.0,
        ),
        vertical: context.responsive(
          mobile: ResponsiveUtils.isSmallPhone ? 12.0 : 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          // حجم الدائرة متجاوب
          final circleSize = context.responsive(
            mobile: ResponsiveUtils.isSmallPhone ? 36.0 : 40.0,
            tablet: 48.0,
            desktop: 56.0,
          );

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // صف الدوائر والخطوط
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الدائرة مع الرقم داخلها
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isActive
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[300]),
                        boxShadow:
                            isActive
                                ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? Icon(
                                  PhosphorIcons.check_bold,
                                  color: Colors.white,
                                  size: context.iconSize(
                                    isLarge:
                                        ResponsiveUtils.isTablet ||
                                        ResponsiveUtils.isDesktop,
                                  ),
                                )
                                : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color:
                                        isActive
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.fontSize(
                                      context.responsive(
                                        mobile:
                                            ResponsiveUtils.isSmallPhone
                                                ? 14
                                                : 16,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    // الخط الفاصل بين الدوائر
                    if (index < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: context.responsive(
                            mobile: 2,
                            tablet: 3,
                            desktop: 4,
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: context.responsive(
                              mobile: ResponsiveUtils.isSmallPhone ? 2 : 4,
                              tablet: 6,
                              desktop: 8,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color:
                                isCompleted
                                    ? AppColors.primary
                                    : (isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300]),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: context.responsive(
                    mobile: ResponsiveUtils.isSmallPhone ? 6 : 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                // نص الخطوة
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsive(
                      mobile: ResponsiveUtils.isSmallPhone ? 2 : 4,
                      tablet: 8,
                      desktop: 12,
                    ),
                  ),
                  child: Text(
                    _steps[index],
                    style: TextStyle(
                      fontSize: context.fontSize(
                        context.responsive(
                          mobile: ResponsiveUtils.isSmallPhone ? 10 : 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                      color:
                          isActive
                              ? AppColors.primary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight:
                          index == _currentStep
                              ? FontWeight.bold
                              : FontWeight.normal,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(AppLocalizations localizations) {
    ResponsiveUtils.init(context);

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: SizedBox(
              height: context.buttonHeight,
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsive(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                  side: BorderSide(
                    color: AppColors.primary,
                    width: context.responsive(mobile: 1.5, tablet: 2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.responsive(mobile: 12, tablet: 14, desktop: 16),
                    ),
                  ),
                ),
                child: Text(
                  localizations.get('previous'),
                  style: TextStyle(
                    fontSize: context.fontSize(
                      context.responsive(mobile: 15, tablet: 16, desktop: 17),
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        if (_currentStep > 0)
          SizedBox(
            width: context.responsive(mobile: 16, tablet: 20, desktop: 24),
          ),
        Expanded(
          flex: _currentStep > 0 ? 1 : 1,
          child: SizedBox(
            height: context.buttonHeight,
            child: ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : (_currentStep < _steps.length - 1
                          ? _nextStep
                          : _register),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  vertical: context.responsive(
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    context.responsive(mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
                elevation: 2,
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        width: context.iconSize(),
                        height: context.iconSize(),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        _currentStep < _steps.length - 1
                            ? localizations.get('next')
                            : localizations.get('create_account'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.fontSize(
                            context.responsive(
                              mobile: 15,
                              tablet: 16,
                              desktop: 17,
                            ),
                          ),
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.get('enter_personal_info'),
          style: TextStyle(
            fontSize: context.fontSize(
              context.responsive(mobile: 14, tablet: 16, desktop: 18),
            ),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(
          height: context.responsive(mobile: 24, tablet: 32, desktop: 40),
        ),
        ArabicTextField(
          controller: _nameController,
          labelText: localizations.get('full_name'),
          hintText: localizations.get('enter_full_name'),
          prefixIcon: PhosphorIcons.user,
          validator: Validators.validateName,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(
          height: context.responsive(mobile: 16, tablet: 20, desktop: 24),
        ),
        ArabicTextField(
          controller: _phoneController,
          labelText: localizations.get('phone_number_optional'),
          hintText: localizations.get('enter_phone_number'),
          prefixIcon: PhosphorIcons.phone,
          keyboardType: TextInputType.phone,
          validator: Validators.validatePhone,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildAccountInfoStep() {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.get('enter_account_info'),
          style: TextStyle(
            fontSize: context.fontSize(
              context.responsive(mobile: 14, tablet: 16, desktop: 18),
            ),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(
          height: context.responsive(mobile: 24, tablet: 32, desktop: 40),
        ),
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
          height: context.responsive(mobile: 16, tablet: 20, desktop: 24),
        ),
        ArabicTextField(
          controller: _passwordController,
          labelText: localizations.get('password'),
          hintText: localizations.get('enter_password'),
          prefixIcon: PhosphorIcons.lock,
          obscureText: !_isPasswordVisible,
          validator: Validators.validatePassword,
          textInputAction: TextInputAction.next,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? PhosphorIcons.eye_slash : PhosphorIcons.eye,
              color: AppColors.textSecondary,
              size: context.iconSize(),
            ),
            onPressed: _togglePasswordVisibility,
          ),
        ),
        SizedBox(
          height: context.responsive(mobile: 8, tablet: 12, desktop: 16),
        ),
        PasswordStrengthIndicator(
          strength: _passwordStrength,
          text: _passwordStrengthText,
          color: _passwordStrengthColor,
        ),
        SizedBox(
          height: context.responsive(mobile: 16, tablet: 20, desktop: 24),
        ),
        ArabicTextField(
          controller: _confirmPasswordController,
          labelText: localizations.get('confirm_password'),
          hintText: localizations.get('re_enter_password'),
          prefixIcon: PhosphorIcons.lock_key,
          obscureText: !_isConfirmPasswordVisible,
          validator: (value) {
            final localizations = AppLocalizations.ofOrThrow(context);
            if (value != _passwordController.text) {
              return localizations.get('passwords_dont_match');
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? PhosphorIcons.eye_slash
                  : PhosphorIcons.eye,
              color: AppColors.textSecondary,
              size: context.iconSize(),
            ),
            onPressed: _toggleConfirmPasswordVisibility,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.get('verify_info_and_complete'),
          style: TextStyle(
            fontSize: context.fontSize(
              context.responsive(mobile: 14, tablet: 16, desktop: 18),
            ),
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(
          height: context.responsive(mobile: 24, tablet: 32, desktop: 40),
        ),

        // ملخص البيانات
        Card(
          elevation: 0,
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.responsive(mobile: 12, tablet: 16, desktop: 20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              context.responsive(mobile: 16, tablet: 20, desktop: 24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  localizations.get('full_name'),
                  _nameController.text,
                ),
                SizedBox(
                  height: context.responsive(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                SizedBox(
                  height: context.responsive(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                _buildInfoRow(
                  localizations.get('phone_number'),
                  _phoneController.text.isEmpty
                      ? localizations.get('not_specified')
                      : _phoneController.text,
                ),
                SizedBox(
                  height: context.responsive(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                SizedBox(
                  height: context.responsive(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                _buildInfoRow(
                  localizations.get('email'),
                  _emailController.text,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: context.responsive(mobile: 24, tablet: 32, desktop: 40),
        ),

        // الشروط والأحكام
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.responsive(mobile: 24, tablet: 28, desktop: 32),
              height: context.responsive(mobile: 24, tablet: 28, desktop: 32),
              child: Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    context.responsive(mobile: 4, tablet: 6),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: context.responsive(mobile: 12, tablet: 16, desktop: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.get('i_agree_to'),
                    style: TextStyle(
                      fontSize: context.fontSize(
                        context.responsive(mobile: 14, tablet: 15, desktop: 16),
                      ),
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(
                    height: context.responsive(
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                  ),
                  Wrap(
                    spacing: context.responsive(
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                    runSpacing: context.responsive(
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                    children: [
                      GestureDetector(
                        onTap: _openTermsAndConditions,
                        child: Text(
                          localizations.get('terms_conditions'),
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: context.fontSize(
                              context.responsive(
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' ${localizations.get('and')} ',
                        style: TextStyle(
                          fontSize: context.fontSize(
                            context.responsive(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openPrivacyPolicy,
                        child: Text(
                          localizations.get('privacy_policy'),
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: context.fontSize(
                              context.responsive(
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.responsive(mobile: 8, tablet: 12, desktop: 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.responsive(mobile: 120, tablet: 140, desktop: 160),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize(
                  context.responsive(mobile: 14, tablet: 15, desktop: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: context.fontSize(
                  context.responsive(mobile: 16, tablet: 17, desktop: 18),
                ),
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
