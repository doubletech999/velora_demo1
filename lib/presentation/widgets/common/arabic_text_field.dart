// lib/presentation/widgets/common/arabic_text_field.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class ArabicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final bool autofocus;

  const ArabicTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: context.fontSize(context.responsive(mobile: 15, tablet: 16, desktop: 17)),
        height: 1.5,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive(mobile: 12, tablet: 14),
          ),
          child: Icon(
            prefixIcon,
            size: context.iconSize(),
            color: AppColors.primary,
          ),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark 
            ? Colors.grey[800]!.withOpacity(0.5)
            : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsive(
            mobile: 12,
            tablet: 14,
            desktop: 16,
          )),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsive(
            mobile: 12,
            tablet: 14,
            desktop: 16,
          )),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsive(
            mobile: 12,
            tablet: 14,
            desktop: 16,
          )),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsive(
            mobile: 12,
            tablet: 14,
            desktop: 16,
          )),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsive(
            mobile: 12,
            tablet: 14,
            desktop: 16,
          )),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.responsive(mobile: 16, tablet: 18, desktop: 20),
          vertical: context.responsive(mobile: 16, tablet: 18, desktop: 20),
        ),
        labelStyle: TextStyle(
          fontSize: context.fontSize(context.responsive(mobile: 14, tablet: 15, desktop: 16)),
          height: 1.5,
          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
        ),
        hintStyle: TextStyle(
          fontSize: context.fontSize(context.responsive(mobile: 14, tablet: 15, desktop: 16)),
          height: 1.5,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
        errorStyle: TextStyle(
          fontSize: context.fontSize(context.responsive(mobile: 12, tablet: 13)),
          height: 1.3,
          color: AppColors.error,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          height: 1.5,
          fontSize: context.fontSize(context.responsive(mobile: 14, tablet: 15, desktop: 16)),
        ),
      ),
    );
  }
}