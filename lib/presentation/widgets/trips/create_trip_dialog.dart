// lib/presentation/widgets/trips/create_trip_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/path_model.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';

class CreateTripDialog extends StatefulWidget {
  final PathModel path;

  const CreateTripDialog({super.key, required this.path});

  @override
  State<CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<CreateTripDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _participantsController = TextEditingController();
  final PageController _pageController = PageController();

  // Form fields
  TripActivityType _selectedActivity = TripActivityType.hiking;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  int _estimatedDuration = 4;
  List<String> _participants = [];
  int _participantCount = 1;
  bool _useParticipantNames = false;
  bool _isLoading = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize with path estimated duration
    _estimatedDuration = widget.path.estimatedDuration.inHours;

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _participantsController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addParticipant() {
    final name = _participantsController.text.trim();
    if (name.isNotEmpty && !_participants.contains(name)) {
      setState(() {
        _participants.add(name);
        _participantsController.clear();
        _participantCount = _participants.length;
      });
    }
  }

  void _removeParticipant(String participant) {
    setState(() {
      _participants.remove(participant);
      _participantCount = _participants.length;
    });
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    if (userProvider.user == null) {
      _showError('يجب تسجيل الدخول لحفظ الرحلة');
      setState(() => _isLoading = false);
      return;
    }

    // Create trip object
    final trip = Trip(
      id: '', // Will be generated in provider
      pathId: widget.path.id,
      pathName: widget.path.nameAr,
      pathLocation: widget.path.locationAr,
      pathLength: widget.path.length,
      pathDifficulty: _getDifficultyText(widget.path.difficulty),
      activityType: _selectedActivity,
      scheduledDate: _selectedDate,
      scheduledTime: _selectedTime,
      estimatedDurationHours: _estimatedDuration,
      notes: _notesController.text,
      participants: _useParticipantNames ? _participants : [],
      participantCount: _participantCount,
      status: TripStatus.planned,
      createdAt: DateTime.now(),
      userId: userProvider.user!.id,
    );

    // Save trip
    final success = await tripProvider.addTrip(trip);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(PhosphorIcons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('تم تسجيل الرحلة بنجاح!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (mounted) {
      _showError(tripProvider.error ?? 'حدث خطأ غير متوقع');
    }

    setState(() => _isLoading = false);
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

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.medium:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.difficultyEasy;
      case DifficultyLevel.medium:
        return AppColors.difficultyMedium;
      case DifficultyLevel.hard:
        return AppColors.difficultyHard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Path info card
                          _buildPathInfoCard(),
                          const SizedBox(height: 24),

                          // Activity type selection
                          _buildActivityTypeSelection(),
                          const SizedBox(height: 24),

                          // Date and time selection
                          _buildDateTimeSelection(),
                          const SizedBox(height: 24),

                          // Duration selection
                          _buildDurationSelection(),
                          const SizedBox(height: 24),

                          // Participants section
                          _buildParticipantsSection(),
                          const SizedBox(height: 24),

                          // Notes section
                          _buildNotesSection(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer with action buttons
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIcons.calendar_plus,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'تسجيل رحلة جديدة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildPathInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.map_pin, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل المسار',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.path.nameAr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.path.locationAr,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(
                    widget.path.difficulty,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDifficultyText(widget.path.difficulty),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getDifficultyColor(widget.path.difficulty),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildPathStat(PhosphorIcons.ruler, '${widget.path.length} كم'),
              const SizedBox(width: 16),
              _buildPathStat(
                PhosphorIcons.clock,
                '${widget.path.estimatedDuration.inHours} ساعات',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPathStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActivityTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع النشاط',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              TripActivityType.values.map((activity) {
                final isSelected = _selectedActivity == activity;
                return GestureDetector(
                  onTap: () => setState(() => _selectedActivity = activity),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getActivityIcon(activity),
                          size: 18,
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getActivityText(activity),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تاريخ ووقت الرحلة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                icon: PhosphorIcons.calendar,
                label: 'التاريخ',
                value:
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeButton(
                icon: PhosphorIcons.clock,
                label: 'الوقت',
                value: _selectedTime.format(context),
                onTap: () => _selectTime(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المدة المتوقعة (بالساعات)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Slider(
                value: _estimatedDuration.toDouble(),
                min: 1,
                max: 24,
                divisions: 23,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _estimatedDuration = value.round();
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_estimatedDuration ساعات',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المشاركون',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Toggle between count and names
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('عدد المشاركين فقط'),
                value: false,
                groupValue: _useParticipantNames,
                onChanged: (value) {
                  setState(() {
                    _useParticipantNames = value!;
                    if (!_useParticipantNames) {
                      _participants.clear();
                    }
                  });
                },
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('أسماء المشاركين'),
                value: true,
                groupValue: _useParticipantNames,
                onChanged: (value) {
                  setState(() {
                    _useParticipantNames = value!;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (!_useParticipantNames) ...[
          // Participant count selector
          Row(
            children: [
              const Text('عدد المشاركين: '),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(PhosphorIcons.minus),
                      onPressed:
                          _participantCount > 1
                              ? () => setState(() => _participantCount--)
                              : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_participantCount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIcons.plus),
                      onPressed:
                          _participantCount < 50
                              ? () => setState(() => _participantCount++)
                              : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Participant names input
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _participantsController,
                  decoration: InputDecoration(
                    labelText: 'اسم المشارك',
                    hintText: 'أدخل اسم المشارك',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(PhosphorIcons.user),
                  ),
                  onFieldSubmitted: (_) => _addParticipant(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIcons.plus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: _addParticipant,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Participants list
          if (_participants.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _participants.map((participant) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            participant,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeParticipant(participant),
                            child: Icon(
                              PhosphorIcons.x,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملاحظات إضافية',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'أضف أي ملاحظات حول الرحلة (اختياري)...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(PhosphorIcons.calendar_plus),
              label: Text(_isLoading ? 'جاري الحفظ...' : 'تسجيل الرحلة'),
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityText(TripActivityType activity) {
    switch (activity) {
      case TripActivityType.hiking:
        return 'مشي';
      case TripActivityType.camping:
        return 'تخييم';
      case TripActivityType.religious:
        return 'ديني';
      case TripActivityType.cultural:
        return 'ثقافي';
      case TripActivityType.other:
        return 'آخر';
    }
  }

  IconData _getActivityIcon(TripActivityType activity) {
    switch (activity) {
      case TripActivityType.hiking:
        return PhosphorIcons.person_simple_walk;
      case TripActivityType.camping:
        return PhosphorIcons.campfire;
      case TripActivityType.religious:
        return PhosphorIcons.star;
      case TripActivityType.cultural:
        return PhosphorIcons.book_open;
      case TripActivityType.other:
        return PhosphorIcons.dots_three;
    }
  }
}
