import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/arabic_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _passwordReset = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService.instance;
      await apiService.resetPassword(
        email: widget.email,
        token: widget.token,
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );

      setState(() {
        _passwordReset = true;
        _isLoading = false;
      });

      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(PhosphorIcons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(localizations.get('password_reset_success')),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to login after 2 seconds
        // الانتقال لصفحة تسجيل الدخول بعد ثانيتين
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        String errorMessage = localizations.get('error');

        // Extract error message
        if (e.toString().contains('token') || e.toString().contains('expired')) {
          errorMessage = 'الرابط منتهي الصلاحية أو غير صحيح. يرجى طلب رابط جديد';
        } else if (e.toString().contains('password')) {
          errorMessage = 'كلمة المرور غير صحيحة. تأكد من أن كلمة المرور تتطابق';
        } else {
          errorMessage = e.toString().length > 100
              ? '${e.toString().substring(0, 100)}...'
              : e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);

    if (_passwordReset) {
      return Scaffold(
        appBar: CustomAppBar(
          title: localizations.get('reset_password'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIcons.check_circle,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                localizations.get('password_reset_success'),
                style: TextStyle(
                  fontSize: context.fontSize(24),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'سيتم توجيهك لصفحة تسجيل الدخول...',
                style: TextStyle(
                  fontSize: context.fontSize(16),
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: CustomAppBar(
          title: localizations.get('reset_password'),
        ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: context.responsivePadding(
                horizontal: 24,
                vertical: 16,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),

                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            PhosphorIcons.lock_key,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'أدخل كلمة المرور الجديدة',
                          style: TextStyle(
                            fontSize: context.fontSize(28),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'أدخل كلمة مرور جديدة لحسابك',
                          style: TextStyle(
                            fontSize: context.fontSize(16),
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Password field
                        ArabicTextField(
                          controller: _passwordController,
                          labelText: localizations.get('password'),
                          hintText: 'أدخل كلمة المرور الجديدة',
                          prefixIcon: PhosphorIcons.lock,
                          obscureText: !_passwordVisible,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? PhosphorIcons.eye_slash
                                  : PhosphorIcons.eye,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Confirm password field
                        ArabicTextField(
                          controller: _confirmPasswordController,
                          labelText: 'تأكيد كلمة المرور',
                          hintText: 'أعد إدخال كلمة المرور',
                          prefixIcon: PhosphorIcons.lock_key,
                          obscureText: !_confirmPasswordVisible,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى تأكيد كلمة المرور';
                            }
                            if (value != _passwordController.text) {
                              return 'كلمة المرور غير متطابقة';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _resetPassword(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? PhosphorIcons.eye_slash
                                  : PhosphorIcons.eye,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible = !_confirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Reset button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _resetPassword,
                            icon: const Icon(PhosphorIcons.check_circle),
                            label: Text(
                              'إعادة تعيين كلمة المرور',
                              style: TextStyle(
                                fontSize: context.fontSize(16),
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Back to login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تذكرت كلمة المرور؟',
                              style: TextStyle(
                                fontSize: context.fontSize(14),
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(
                                localizations.get('login'),
                                style: TextStyle(
                                  fontSize: context.fontSize(14),
                                  fontWeight: FontWeight.bold,
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

          // Loading indicator
          if (_isLoading)
            LoadingIndicator(
              isOverlay: true,
              message: 'جاري إعادة تعيين كلمة المرور...',
            ),
        ],
      ),
    );
  }
}

