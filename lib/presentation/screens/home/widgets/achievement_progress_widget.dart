// lib/presentation/screens/home/widgets/achievement_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class AchievementProgressWidget extends StatefulWidget {
  const AchievementProgressWidget({super.key});

  @override
  State<AchievementProgressWidget> createState() =>
      _AchievementProgressWidgetState();
}

class _AchievementProgressWidgetState extends State<AchievementProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _starAnimationController;
  late Animation<double> _progressAnimation;

  // إضافة قائمة الإنجازات كمتغير
  final List<Achievement> achievements = [
    Achievement(
      id: 'explorer_beginner',
      title: 'مستكشف مبتدئ',
      description: 'أكمل 5 مسارات مختلفة',
      icon: PhosphorIcons.compass_fill,
      color: Colors.blue,
      currentProgress: 3,
      maxProgress: 5,
      isCompleted: false,
      reward: 'شارة المستكشف البرونزية',
    ),
    Achievement(
      id: 'distance_walker',
      title: 'ماشي المسافات',
      description: 'امش 50 كيلومتر إجمالي',
      icon: PhosphorIcons.fingerprint,
      color: Colors.green,
      currentProgress: 32,
      maxProgress: 50,
      isCompleted: false,
      reward: '100 نقطة تجربة',
    ),
    Achievement(
      id: 'peak_climber',
      title: 'متسلق القمم',
      description: 'تسلق 3 قمم جبلية',
      icon: PhosphorIcons.mountains_fill,
      color: Colors.orange,
      currentProgress: 1,
      maxProgress: 3,
      isCompleted: false,
      reward: 'لقب متسلق القمم',
    ),
    Achievement(
      id: 'heritage_lover',
      title: 'محب التراث',
      description: 'زر 5 مواقع تراثية',
      icon: PhosphorIcons.buildings_fill,
      color: Colors.purple,
      currentProgress: 5,
      maxProgress: 5,
      isCompleted: true,
      reward: 'شارة حارس التراث',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // إصلاح منحنى الرسوم المتحركة
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // تشغيل الرسوم المتحركة بعد البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _starAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.ofOrThrow(context);
    final completedCount = achievements.where((a) => a.isCompleted).length;
    final totalCount = achievements.length;
    final overallProgress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: EdgeInsets.all(context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Icon(
                PhosphorIcons.trophy_fill,
                color: Colors.amber,
                size: context.iconSize(),
              ),
              SizedBox(width: context.sm),
              Text(
                localizations.get('achievement_progress'),
                style: TextStyle(
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/profile/achievements'),
                child: Text(localizations.get('view_all')),
              ),
            ],
          ),

          SizedBox(height: context.md),

          // التقدم الإجمالي
          Container(
            padding: EdgeInsets.all(context.adaptive(20)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.1),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(context.adaptive(16)),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: context.adaptive(1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التقدم الإجمالي',
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: context.xs),
                          Text(
                            '$completedCount من $totalCount إنجازات مكتملة',
                            style: TextStyle(
                              fontSize: context.fontSize(14),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        // إصلاح القيمة لتكون ضمن النطاق الآمن
                        final safePercent = (overallProgress *
                                _progressAnimation.value)
                            .clamp(0.0, 1.0);

                        return CircularPercentIndicator(
                          radius: context.adaptive(35.0),
                          lineWidth: context.adaptive(8.0),
                          percent: safePercent,
                          center: Text(
                            '${(overallProgress * 100).round()}%',
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          progressColor: Colors.amber,
                          backgroundColor: Colors.amber.withOpacity(0.2),
                          circularStrokeCap: CircularStrokeCap.round,
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: context.md),

                // شريط المستوى
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.star_fill,
                      color: Colors.amber,
                      size: context.iconSize(),
                    ),
                    SizedBox(width: context.sm),
                    Text(
                      'المستوى 3',
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '450/600 نقطة',
                      style: TextStyle(
                        fontSize: context.fontSize(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.adaptive(10)),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      // إصلاح القيمة لتكون ضمن النطاق الآمن
                      final safePercent = (0.75 * _progressAnimation.value)
                          .clamp(0.0, 1.0);

                      return LinearPercentIndicator(
                        width:
                            MediaQuery.of(context).size.width -
                            context.adaptive(96),
                        lineHeight: context.adaptive(8.0),
                        percent: safePercent,
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        progressColor: Colors.amber,
                        barRadius: Radius.circular(context.adaptive(10)),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.sm),
                Text(
                  'المستوى التالي في 150 نقطة',
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: context.md),

          // قائمة الإنجازات
          ...achievements
              .take(3)
              .map((achievement) => _buildAchievementCard(achievement)),

          // بطاقة عرض المزيد
          if (achievements.length > 3)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => context.go('/profile/achievements'),
                child: Container(
                  padding: EdgeInsets.all(context.md),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: context.adaptive(1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.plus_circle,
                        color: AppColors.primary,
                        size: context.iconSize(),
                      ),
                      SizedBox(width: context.sm),
                      Text(
                        'عرض ${achievements.length - 3} إنجازات أخرى',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // حماية من القسمة على صفر
    final progress =
        achievement.maxProgress > 0
            ? achievement.currentProgress / achievement.maxProgress
            : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: context.adaptive(12)),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : achievement.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              achievement.isCompleted
                  ? achievement.color
                  : achievement.color.withOpacity(0.2),
          width: achievement.isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // أيقونة الإنجاز
          Container(
            width: context.adaptive(60),
            height: context.adaptive(60),
            decoration: BoxDecoration(
              color:
                  achievement.isCompleted
                      ? achievement.color
                      : achievement.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    achievement.icon,
                    color:
                        achievement.isCompleted
                            ? Colors.white
                            : achievement.color,
                    size: context.iconSize(isLarge: true),
                  ),
                ),
                if (achievement.isCompleted)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: context.iconSize(),
                      height: context.iconSize(),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: context.adaptive(2),
                        ),
                      ),
                      child: Icon(
                        PhosphorIcons.check,
                        color: Colors.white,
                        size: context.fontSize(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: context.md),

          // تفاصيل الإنجاز
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: context.fontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (achievement.isCompleted)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.sm,
                          vertical: context.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            context.adaptive(12),
                          ),
                        ),
                        child: Text(
                          'مكتمل',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: context.fontSize(12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: context.xs),

                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: context.sm),

                // شريط التقدم
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            // إصلاح القيمة لتكون ضمن النطاق الآمن
                            final safePercent = (progress *
                                    _progressAnimation.value)
                                .clamp(0.0, 1.0);

                            return LinearPercentIndicator(
                              width: context.adaptive(150),
                              lineHeight: context.adaptive(6.0),
                              percent: safePercent,
                              backgroundColor: achievement.color.withOpacity(
                                0.2,
                              ),
                              progressColor: achievement.color,
                              barRadius: Radius.circular(context.adaptive(10)),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: context.sm),
                    Text(
                      '${achievement.currentProgress}/${achievement.maxProgress}',
                      style: TextStyle(
                        fontSize: context.fontSize(12),
                        color: achievement.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.xs),

                // المكافأة
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.gift,
                      color: Colors.amber,
                      size: context.fontSize(14),
                    ),
                    SizedBox(width: context.xs),
                    Expanded(
                      child: Text(
                        achievement.reward,
                        style: TextStyle(
                          fontSize: context.fontSize(12),
                          color: Colors.amber,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int currentProgress;
  final int maxProgress;
  final bool isCompleted;
  final String reward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.currentProgress,
    required this.maxProgress,
    required this.isCompleted,
    required this.reward,
  });
}
