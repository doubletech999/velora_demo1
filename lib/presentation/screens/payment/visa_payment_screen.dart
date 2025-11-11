// lib/presentation/screens/payment/visa_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class VisaPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String pathName;
  final Function(bool success, Map<String, dynamic>? paymentData) onPaymentComplete;

  const VisaPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.pathName,
    required this.onPaymentComplete,
  });

  @override
  State<VisaPaymentScreen> createState() => _VisaPaymentScreenState();
}

class _VisaPaymentScreenState extends State<VisaPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _zipCodeController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    // Remove all non-digits
    String numbersOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Format as XXXX XXXX XXXX XXXX
    if (numbersOnly.isEmpty) return '';
    if (numbersOnly.length <= 4) return numbersOnly;
    if (numbersOnly.length <= 8) return '${numbersOnly.substring(0, 4)} ${numbersOnly.substring(4)}';
    if (numbersOnly.length <= 12) return '${numbersOnly.substring(0, 4)} ${numbersOnly.substring(4, 8)} ${numbersOnly.substring(8)}';
    return '${numbersOnly.substring(0, 4)} ${numbersOnly.substring(4, 8)} ${numbersOnly.substring(8, 12)} ${numbersOnly.substring(12, 16)}';
  }

  String _formatExpiryDate(String value) {
    String numbersOnly = value.replaceAll(RegExp(r'\D'), '');
    if (numbersOnly.isEmpty) return '';
    if (numbersOnly.length <= 2) return numbersOnly;
    return '${numbersOnly.substring(0, 2)}/${numbersOnly.substring(2, 4)}';
  }

  bool _validateCardNumber(String value) {
    String numbersOnly = value.replaceAll(RegExp(r'\D'), '');
    return numbersOnly.length == 16;
  }

  bool _validateExpiryDate(String value) {
    String numbersOnly = value.replaceAll(RegExp(r'\D'), '');
    if (numbersOnly.length != 4) return false;
    
    int month = int.tryParse(numbersOnly.substring(0, 2)) ?? 0;
    int year = int.tryParse(numbersOnly.substring(2, 4)) ?? 0;
    
    // Check if month is valid (01-12)
    if (month < 1 || month > 12) return false;
    
    // Check if year is in the future
    int currentYear = DateTime.now().year % 100;
    int currentMonth = DateTime.now().month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return false;
    }
    
    return true;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, always succeed
    // In a real app, you would integrate with a payment gateway here
    
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      final paymentData = {
        'success': true,
        'cardLast4': _cardNumberController.text.replaceAll(' ', '').substring(12),
        'cardType': 'Visa',
        'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
      };

      widget.onPaymentComplete(true, paymentData);
      Navigator.of(context).pop(paymentData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.ofOrThrow(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
          color: theme.appBarTheme.foregroundColor,
        ),
        title: Text(
          localizations.get('pay_with_visa'),
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.shopping_cart,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ملخص الطلب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المسار:',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.pathName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ الإجمالي:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            '\$${widget.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Card Number
                Text(
                  'رقم البطاقة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '1234 5678 9012 3456',
                    prefixIcon: const Icon(PhosphorIcons.credit_card),
                    suffixIcon: Icon(
                      PhosphorIcons.credit_card,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final formatted = _formatCardNumber(newValue.text);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم البطاقة';
                    }
                    if (!_validateCardNumber(value)) {
                      return 'رقم البطاقة غير صحيح (يجب أن يكون 16 رقم)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Card Holder Name
                Text(
                  'اسم حامل البطاقة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cardHolderController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'John Doe',
                    prefixIcon: const Icon(PhosphorIcons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم حامل البطاقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Expiry and CVV Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاريخ الانتهاء',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _expiryDateController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'MM/YY',
                              prefixIcon: const Icon(PhosphorIcons.calendar),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                final formatted = _formatExpiryDate(newValue.text);
                                return TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              }),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'مطلوب';
                              }
                              if (!_validateExpiryDate(value)) {
                                return 'تاريخ غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CVV',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '123',
                              prefixIcon: const Icon(PhosphorIcons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'مطلوب';
                              }
                              if (value.length != 3) {
                                return 'يجب أن يكون 3 أرقام';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ZIP Code
                Text(
                  'الرمز البريدي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _zipCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '12345',
                    prefixIcon: const Icon(PhosphorIcons.map_pin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الرمز البريدي';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Security Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIcons.shield_check,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'جميع معلومات الدفع آمنة ومشفرة. لن نقوم بتخزين بيانات بطاقتك الائتمانية.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(PhosphorIcons.lock_key),
                              const SizedBox(width: 8),
                              Text(
                                'تأكيد الدفع \$${widget.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

