// lib/presentation/screens/auth/forgot_password_screen.dart
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  
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
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // إرسال رابط إعادة تعيين كلمة المرور للخادم
      // Send password reset link to server
      final apiService = ApiService.instance;
      await apiService.sendPasswordResetEmail(email: _emailController.text.trim());
      
      setState(() {
        _emailSent = true;
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
                  child: Text(localizations.get('password_reset_sent')),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        String errorMessage = localizations.get('error');
        
        // Extract error message from exception
        // استخراج رسالة الخطأ من الاستثناء
        if (e.toString().contains('message')) {
          try {
            final errorStr = e.toString();
            // Try to extract a more user-friendly message
            // محاولة استخراج رسالة أكثر وضوحاً للمستخدم
            if (errorStr.contains('email')) {
              errorMessage = 'البريد الإلكتروني غير موجود';
            } else if (errorStr.contains('throttle') || errorStr.contains('rate limit')) {
              errorMessage = 'تم إرسال طلب سابق. يرجى الانتظار قبل المحاولة مرة أخرى';
            } else {
              errorMessage = errorStr.length > 100 
                  ? '${errorStr.substring(0, 100)}...' 
                  : errorStr;
            }
          } catch (_) {
            errorMessage = e.toString();
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage'),
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
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.get('forgot_password').replaceAll('?', ''),
      ),
      body: Stack(
        children: [
          // الخلفية المتدرجة
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
          
          // المحتوى
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
                  child: _emailSent 
                      ? _buildSuccessView(localizations)
                      : _buildFormView(localizations),
                ),
              ),
            ),
          ),
          
          // مؤشر التحميل
          if (_isLoading)
            LoadingIndicator(
              isOverlay: true,
              message: localizations.get('password_reset_loading'),
            ),
        ],
      ),
    );
  }

  Widget _buildFormView(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          
          // أيقونة كبيرة
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
          
          // العنوان
          Text(
            localizations.get('password_reset_title'),
            style: TextStyle(
              fontSize: context.fontSize(28),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // الوصف
          Text(
            localizations.get('password_reset_description'),
            style: TextStyle(
              fontSize: context.fontSize(16),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // حقل البريد الإلكتروني
          ArabicTextField(
            controller: _emailController,
            labelText: localizations.get('email'),
            hintText: localizations.get('enter_email'),
            prefixIcon: PhosphorIcons.envelope,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetLink(),
          ),
          const SizedBox(height: 32),
          
          // زر إرسال الرابط
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendResetLink,
              icon: const Icon(PhosphorIcons.paper_plane_tilt),
              label: Text(
                localizations.get('password_reset_button'),
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
          
          // رابط العودة لتسجيل الدخول
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.get('remember_password'),
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
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
    );
  }

  Widget _buildSuccessView(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        
        // أيقونة النجاح
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
        
        // العنوان
        Text(
          localizations.get('password_reset_success_title'),
          style: TextStyle(
            fontSize: context.fontSize(28),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // الوصف
        Text(
          '${localizations.get('password_reset_check_email')}\n${_emailController.text}',
          style: TextStyle(
            fontSize: context.fontSize(16),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // معلومات إضافية
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                PhosphorIcons.info,
                color: AppColors.info,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations.get('password_reset_spam_warning'),
                  style: TextStyle(
                    fontSize: context.fontSize(13),
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        
        // زر إعادة الإرسال
        OutlinedButton.icon(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          icon: const Icon(PhosphorIcons.arrow_clockwise),
          label: Text(localizations.get('send_new_link')),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // زر العودة لتسجيل الدخول
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(PhosphorIcons.arrow_left),
            label: Text(localizations.get('back_to_login')),
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
      ],
    );
  }
}