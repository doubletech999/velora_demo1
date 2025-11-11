// lib/presentation/screens/reviews/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/review_model.dart';
import '../../providers/reviews_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

class ReviewsScreen extends StatefulWidget {
  final String? siteId;
  final String? pathName;

  const ReviewsScreen({super.key, required this.siteId, this.pathName});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reviewsProvider = Provider.of<ReviewsProvider>(
        context,
        listen: false,
      );
      reviewsProvider.fetchReviews(siteId: widget.siteId);
      reviewsProvider.fetchReviewStats(siteId: widget.siteId);
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقائق';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} أشهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.ofOrThrow(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.get('reviews'),
        showBackButton: true,
      ),
      body: Consumer<ReviewsProvider>(
        builder: (context, reviewsProvider, child) {
          if (reviewsProvider.isLoading && reviewsProvider.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewsProvider.error != null &&
              reviewsProvider.reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.warning_circle,
                    size: context.iconSize(isLarge: true),
                    color: AppColors.error,
                  ),
                  SizedBox(height: context.md),
                  Text(
                    reviewsProvider.error!,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: context.fontSize(14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.lg),
                  ElevatedButton(
                    onPressed: () {
                      reviewsProvider.fetchReviews(siteId: widget.siteId);
                    },
                    child: Text(localizations.get('retry')),
                  ),
                ],
              ),
            );
          }

          final stats = reviewsProvider.getStats(widget.siteId);

          return Column(
            children: [
              // Stats Header
              if (stats != null)
                Container(
                  padding: EdgeInsets.all(context.lg),
                  margin: EdgeInsets.all(context.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(context.adaptive(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            stats.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: context.fontSize(28),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: context.xs),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < stats.averageRating.floor()
                                    ? PhosphorIcons.star_fill
                                    : (index == stats.averageRating.floor() &&
                                        stats.averageRating % 1 > 0)
                                    ? PhosphorIcons.star_half
                                    : PhosphorIcons.star,
                                color: Colors.amber,
                                size: context.iconSize(),
                              );
                            }),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                      Column(
                        children: [
                          Text(
                            '${stats.totalReviews}',
                            style: TextStyle(
                              fontSize: context.fontSize(24),
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: context.xs),
                          Text(
                            localizations.get('reviews'),
                            style: TextStyle(
                              fontSize: context.fontSize(14),
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Reviews List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await reviewsProvider.fetchReviews(siteId: widget.siteId);
                    await reviewsProvider.fetchReviewStats(
                      siteId: widget.siteId,
                    );
                  },
                  child:
                      reviewsProvider.reviews.isEmpty
                          ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIcons.chat_circle_text,
                                      size: context.iconSize(isLarge: true) * 2,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                    SizedBox(height: context.lg),
                                    Text(
                                      'لا توجد تقييمات بعد',
                                      style: TextStyle(
                                        fontSize: context.fontSize(16),
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          : ListView.builder(
                            padding: EdgeInsets.all(context.md),
                            itemCount: reviewsProvider.reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviewsProvider.reviews[index];
                              return _buildReviewCard(
                                review,
                                context,
                                colorScheme,
                              );
                            },
                          ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(
    ReviewModel review,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: context.md),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(context.adaptive(12)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: context.adaptive(20),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child:
                    review.userImageUrl != null
                        ? ClipOval(
                          child: Image.network(
                            review.userImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                PhosphorIcons.user,
                                color: AppColors.primary,
                                size: context.iconSize(),
                              );
                            },
                          ),
                        )
                        : Icon(
                          PhosphorIcons.user,
                          color: AppColors.primary,
                          size: context.iconSize(),
                        ),
              ),
              SizedBox(width: context.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'مستخدم',
                      style: TextStyle(
                        fontSize: context.fontSize(16),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: context.xs),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? PhosphorIcons.star_fill
                                : PhosphorIcons.star,
                            color: Colors.amber,
                            size: context.fontSize(14),
                          );
                        }),
                        SizedBox(width: context.sm),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: context.fontSize(12),
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: context.md),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: context.fontSize(14),
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
