// lib/presentation/widgets/dialogs/simple_trip_registration_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/path_model.dart';
import '../../../data/models/trip_registration_model.dart';
import '../../providers/trip_registration_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/payment/visa_payment_screen.dart';

class SimpleTripRegistrationDialog extends StatefulWidget {
  final PathModel path;
  final VoidCallback onTripRegistered;

  const SimpleTripRegistrationDialog({
    super.key,
    required this.path,
    required this.onTripRegistered,
  });

  @override
  State<SimpleTripRegistrationDialog> createState() =>
      _SimpleTripRegistrationDialogState();
}

class _SimpleTripRegistrationDialogState
    extends State<SimpleTripRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  int _numberOfParticipants = 1;
  bool _isSubmitting = false;
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      _nameController.text = userProvider.user!.name;
      _emailController.text = userProvider.user!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip Info Card
                      _buildTripInfoCard(),
                      const SizedBox(height: 24),

                      // Registration Form
                      Text(
                        localizations.get('registration_info'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '${localizations.get('full_name')} *',
                          prefixIcon: const Icon(PhosphorIcons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => Validators.validateName(value),
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: '${localizations.get('phone_number')} *',
                          prefixIcon: const Icon(PhosphorIcons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => Validators.validatePhone(value),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '${localizations.get('email')} *',
                          prefixIcon: const Icon(PhosphorIcons.envelope),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => Validators.validateEmail(value),
                      ),
                      const SizedBox(height: 24),

                      // Number of Participants
                      Text(
                        localizations.get('number_of_participants'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.surface : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // النص في سطر منفصل
    Text(
      AppLocalizations.of(context)?.get('number_of_people') ?? 'Number of people',
      style: const TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 12),
    // الأزرار في سطر منفصل - في المنتصف
    Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _numberOfParticipants > 1
                ? () => setState(() => _numberOfParticipants--)
                : null,
            icon: const Icon(PhosphorIcons.minus_circle),
            color: AppColors.primary,
            iconSize: 28,
          ),
          Container(
            width: 50,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$_numberOfParticipants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _numberOfParticipants < 50
                ? () => setState(() => _numberOfParticipants++)
                : null,
            icon: const Icon(PhosphorIcons.plus_circle),
            color: AppColors.primary,
            iconSize: 28,
          ),
        ],
      ),
    ),
  ],
), ),
                      const SizedBox(height: 24),

                      // Notes Field
                      Text(
                        localizations.get('additional_notes'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.get('notes_hint'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: localizations.get('example_notes'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Method Section
                      Text(
                        localizations.get('payment_method'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 16),

                      // Price Summary Card
                      _buildPriceSummary(),
                      const SizedBox(height: 24),

                      // Important Note
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
                              PhosphorIcons.info,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.get('important_note'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.get('reg_review_note'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.clipboard_text,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      Text(
                        AppLocalizations.of(context)?.get('register_for_trip') ?? 'Register for Trip',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                const SizedBox(height: 4),
                Text(
                  _getLocalizedName(context),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIcons.x, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard() {
    final localizations = AppLocalizations.ofOrThrow(context);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.map_pin,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  languageProvider.isArabic ? widget.path.locationAr : widget.path.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: PhosphorIcons.ruler,
                  label: localizations.get('distance'),
                  value: '${widget.path.length} ${localizations.get('km')}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoItem(
                  icon: PhosphorIcons.clock,
                  label: localizations.get('duration'),
                  value: '${widget.path.estimatedDuration.inHours} ${localizations.get('hours')}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(localizations.get('cancel')),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(PhosphorIcons.paper_plane_tilt),
              label: Text(_isSubmitting ? localizations.get('submitting') : localizations.get('submit_request')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final localizations = AppLocalizations.ofOrThrow(context);
    
    // التحقق من اختيار طريقة الدفع
    if (_selectedPaymentMethod == null) {
      _showErrorSnackBar(localizations.get('select_payment_method'));
      return;
    }

    // Get route price from path (all routes have guides with prices)
    final routePrice = widget.path.price;
    final totalPrice = routePrice;

    // إذا كانت طريقة الدفع فيزا، انتقل إلى صفحة الدفع
    if (_selectedPaymentMethod == PaymentMethod.visa) {
      Navigator.of(context).pop(); // إغلاق dialog التسجيل
      
      // انتقل إلى صفحة الدفع بالفيسا
      final paymentResult = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => VisaPaymentScreen(
            totalAmount: totalPrice,
            pathName: _getLocalizedName(context),
            onPaymentComplete: (success, paymentData) {
              // هذا callback سيتم استدعاؤه من صفحة الدفع
            },
          ),
        ),
      );

      // بعد الانتهاء من الدفع (سواء نجح أم لا)
      if (paymentResult != null && paymentResult['success'] == true) {
        // الدفع نجح، أكمل التسجيل
        await _completeRegistration(totalPrice, paymentResult);
      }
      // إذا فشل الدفع أو ألغى المستخدم، لن نكمل التسجيل
      return;
    }

    // إذا كانت طريقة الدفع نقدي، أكمل التسجيل مباشرة
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _completeRegistration(totalPrice, null);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _completeRegistration(double totalPrice, Map<String, dynamic>? paymentData) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final tripProvider =
          Provider.of<TripRegistrationProvider>(context, listen: false);
      final localizations = AppLocalizations.ofOrThrow(context);

      // Get route price from path (all routes have guides with prices)
      final routePrice = widget.path.price;

      final registration = TripRegistrationModel(
        id: const Uuid().v4(),
        pathId: widget.path.id,
        pathName: _getLocalizedName(context),
        pathLocation: _getLocalizedLocation(context),
        userId: userProvider.user?.id ?? 'anonymous',
        organizerName: _nameController.text.trim(),
        organizerPhone: _phoneController.text.trim(),
        organizerEmail: _emailController.text.trim(),
        numberOfParticipants: _numberOfParticipants,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        pricePerPerson: routePrice, // Route price (fixed per route)
        totalPrice: totalPrice,
        paymentMethod: _selectedPaymentMethod,
      );

      final success = await tripProvider.registerTrip(registration, path: widget.path);

      if (success) {
        widget.onTripRegistered();
        if (paymentData == null) {
          // إذا لم يكن هناك صفحة دفع (نقدي)، أغلق dialog وأظهر رسالة النجاح
          Navigator.of(context).pop();
        }
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(localizations.get('send_error'));
      }
    } catch (e) {
      final localizations = AppLocalizations.ofOrThrow(context);
      _showErrorSnackBar('${localizations.get('unexpected_error')}: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    // Get route price from path (all routes have guides with prices)
    final routePrice = widget.path.price;
    final totalPrice = routePrice;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        final localizations = AppLocalizations.ofOrThrow(context);
        
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.check_circle,
                  color: AppColors.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.get('registration_success'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Payment Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.get('total_amount'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.get('payment_method'),
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedPaymentMethod?.displayNameAr ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              Text(
                localizations.get('reg_success_message'),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(localizations.get('done')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(PhosphorIcons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = PaymentMethod.cash),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == PaymentMethod.cash
                    ? AppColors.primary.withOpacity(0.1)
                    : isDark ? theme.colorScheme.surface : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPaymentMethod == PaymentMethod.cash
                      ? AppColors.primary
                      : isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
                  width: _selectedPaymentMethod == PaymentMethod.cash ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.money,
                    size: 32,
                    color: _selectedPaymentMethod == PaymentMethod.cash
                        ? AppColors.primary
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.get('cash'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedPaymentMethod == PaymentMethod.cash
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedPaymentMethod == PaymentMethod.cash
                          ? AppColors.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = PaymentMethod.visa),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == PaymentMethod.visa
                    ? AppColors.primary.withOpacity(0.1)
                    : isDark ? theme.colorScheme.surface : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPaymentMethod == PaymentMethod.visa
                      ? AppColors.primary
                      : isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
                  width: _selectedPaymentMethod == PaymentMethod.visa ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.credit_card,
                    size: 32,
                    color: _selectedPaymentMethod == PaymentMethod.visa
                        ? AppColors.primary
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.get('visa_card'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedPaymentMethod == PaymentMethod.visa
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedPaymentMethod == PaymentMethod.visa
                          ? AppColors.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final theme = Theme.of(context);
    // Get route price from path (all routes have guides with prices)
    final routePrice = widget.path.price;
    final totalPrice = routePrice;
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Container(
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
                PhosphorIcons.receipt,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                localizations.get('payment_summary'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سعر المسار',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                '\$${routePrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.get('number_of_participants'),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                '$_numberOfParticipants',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.get('total_amount'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (_selectedPaymentMethod != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedPaymentMethod == PaymentMethod.cash
                        ? PhosphorIcons.money
                        : PhosphorIcons.credit_card,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${localizations.get('payment_method')}: ${_selectedPaymentMethod == PaymentMethod.cash ? localizations.get('cash') : localizations.get('visa_card')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? widget.path.nameAr : widget.path.name;
  }
  
  String _getLocalizedLocation(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? widget.path.locationAr : widget.path.location;
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}