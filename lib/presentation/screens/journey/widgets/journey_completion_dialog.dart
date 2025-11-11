// lib/presentation/screens/journey/widgets/journey_completion_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/guest_guard.dart';
import '../../../../data/models/path_model.dart';
import '../../../providers/reviews_provider.dart';

class JourneyCompletionDialog extends StatefulWidget {
  final PathModel path;
  final Duration elapsedTime;
  final VoidCallback onComplete;

  const JourneyCompletionDialog({
    super.key,
    required this.path,
    required this.elapsedTime,
    required this.onComplete,
  });

  @override
  State<JourneyCompletionDialog> createState() => _JourneyCompletionDialogState();
}

class _JourneyCompletionDialogState extends State<JourneyCompletionDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _starAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _showRatingAndComment = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starAnimationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _submitRatingAndComment() async {
    if (!GuestGuard.check(context, feature: 'إضافة التقييمات')) {
      return;
    }
    
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.ofOrThrow(context).get('please_provide_rating')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final reviewsProvider = Provider.of<ReviewsProvider>(context, listen: false);
    final localizations = AppLocalizations.ofOrThrow(context);

    final success = await reviewsProvider.addReview(
      siteId: widget.path.id,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(PhosphorIcons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(localizations.get('review_sent_successfully')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        setState(() {
          _showRatingAndComment = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reviewsProvider.error ?? localizations.get('review_send_failed')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareJourney() async {
    final String shareText = '''
🎉 لقد أكملت رحلة رائعة!

📍 المسار: ${widget.path.nameAr}
⏱️ الوقت: ${_formatDuration(widget.elapsedTime)}
📏 المسافة: ${widget.path.length} كم
📍 الموقع: ${widget.path.locationAr}

${_rating > 0 ? '⭐ التقييم: $_rating/5 نجوم' : ''}
${_commentController.text.isNotEmpty ? '💭 "${_commentController.text}"' : ''}

#Velora #استكشف_فلسطين #مغامرة
    ''';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.ofOrThrow(context).get('share_error').replaceAll('{error}', e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
            _starAnimationController.forward().then((_) {
              _starAnimationController.reverse();
            });
          },
          child: AnimatedBuilder(
            animation: _starAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _rating == index + 1 
                    ? 1.0 + (_starAnimationController.value * 0.3)
                    : 1.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating 
                        ? PhosphorIcons.star_fill 
                        : PhosphorIcons.star,
                    color: index < _rating 
                        ? Colors.amber 
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]
                            : Colors.grey[300]),
                    size: 32,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة النجاح
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success,
                            AppColors.success.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        PhosphorIcons.trophy_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // عنوان التهنئة
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.ofOrThrow(context);
                        return Column(
                          children: [
                            Text(
                              localizations.get('journey_congratulations'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.get('journey_completed_success'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // إحصائيات الرحلة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Builder(
                            builder: (context) {
                              final localizations = AppLocalizations.ofOrThrow(context);
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localizations.get('path_label'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          widget.path.nameAr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localizations.get('elapsed_time'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(widget.elapsedTime),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localizations.get('distance_label'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${widget.path.length} ${localizations.get('km')}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_showRatingAndComment) ...[
                      Builder(
                        builder: (context) {
                          final localizations = AppLocalizations.ofOrThrow(context);
                          return Column(
                            children: [
                              Text(
                                localizations.get('how_was_experience'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildStarRating(),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: localizations.get('add_comment_optional'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitRatingAndComment,
                                icon: const Icon(PhosphorIcons.paper_plane_tilt),
                                label: Text(localizations.get('send_button')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: _shareJourney,
                            icon: const Icon(PhosphorIcons.share_network),
                            label: Text(AppLocalizations.ofOrThrow(context).get('share')),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showRatingAndComment = true;
                              });
                            },
                            icon: const Icon(PhosphorIcons.star),
                            label: Text(AppLocalizations.ofOrThrow(context).get('rating')),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.ofOrThrow(context);
                        return ElevatedButton(
                          onPressed: widget.onComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          child: Text(
                            localizations.get('finish'),
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
