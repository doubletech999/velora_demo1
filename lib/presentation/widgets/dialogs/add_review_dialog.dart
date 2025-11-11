// lib/presentation/widgets/dialogs/add_review_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/reviews_provider.dart';

class AddReviewDialog extends StatefulWidget {
  final String? siteId;
  final String? pathName;

  const AddReviewDialog({
    super.key,
    required this.siteId,
    this.pathName,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _starAnimationController;

  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
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
      siteId: widget.siteId,
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
                SizedBox(width: context.sm),
                Text(localizations.get('review_sent_successfully')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } else {
        // عرض رسالة خطأ واضحة
        final errorMessage = reviewsProvider.error ?? 'فشل إضافة التقييم';
        
        // إذا كان الخطأ هو 409 Conflict، عرض رسالة خاصة
        final isConflictError = errorMessage.contains('قيمت') || 
                                errorMessage.contains('مسبقاً') ||
                                errorMessage.contains('تعارض') ||
                                errorMessage.contains('409') ||
                                errorMessage.contains('Conflict');
        
        // عرض رسالة خطأ واضحة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: isConflictError ? 5 : 4), // زيادة المدة لخطأ 409
            behavior: SnackBarBehavior.floating,
            action: isConflictError
                ? SnackBarAction(
                    label: 'عرض التقييمات',
                    textColor: Colors.white,
                    onPressed: () {
                      // إغلاق dialog والانتقال إلى صفحة التقييمات
                      Navigator.of(context).pop();
                      if (widget.siteId != null) {
                        // يمكن إضافة navigation إلى صفحة التقييمات هنا إذا لزم الأمر
                      }
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  Widget _buildStarRating() {
    final theme = Theme.of(context);
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
                  padding: EdgeInsets.symmetric(horizontal: context.sm),
                  child: Icon(
                    index < _rating ? PhosphorIcons.star_fill : PhosphorIcons.star,
                    color: index < _rating
                        ? Colors.amber
                        : (theme.brightness == Brightness.dark
                            ? Colors.grey[600]
                            : Colors.grey[300]),
                    size: context.iconSize(isLarge: true),
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
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.ofOrThrow(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.adaptive(20)),
      ),
      child: Container(
        padding: EdgeInsets.all(context.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.get('add_review'),
                  style: TextStyle(
                    fontSize: context.fontSize(20),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(PhosphorIcons.x),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (widget.pathName != null) ...[
              SizedBox(height: context.sm),
              Text(
                widget.pathName!,
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: context.lg),
            Text(
              localizations.get('how_was_experience'),
              style: TextStyle(
                fontSize: context.fontSize(16),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.md),
            _buildStarRating(),
            SizedBox(height: context.lg),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'أضف تعليقك (${localizations.get('optional')})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.adaptive(12)),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              maxLines: 4,
              style: TextStyle(
                fontSize: context.fontSize(14),
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.adaptive(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.adaptive(12)),
                      ),
                    ),
                    child: Text(localizations.get('cancel')),
                  ),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: context.adaptive(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.adaptive(12)),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: context.iconSize(),
                            height: context.iconSize(),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(PhosphorIcons.paper_plane_tilt, size: 18),
                              SizedBox(width: context.sm),
                              Text(localizations.get('submit')),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


