// lib/presentation/screens/home/widgets/achievement_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/constants/app_colors.dart';

class AchievementProgressWidget extends StatefulWidget {
  const AchievementProgressWidget({super.key});

  @override
  State<AchievementProgressWidget> createState() => _AchievementProgressWidgetState();
}

class _AchievementProgressWidgetState extends State<AchievementProgressWidget> 
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

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
      icon: PhosphorIcons.house,
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
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = achievements.where((a) => a.isCompleted).length;
    final totalCount = achievements.length;
    final overallProgress = completedCount / totalCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              const Icon(
                PhosphorIcons.trophy_fill,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'تقدم الإنجازات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/profile/achievements'),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // التقدم الإجمالي
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.1),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
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
                          const Text(
                            'التقدم الإجمالي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completedCount من $totalCount إنجازات مكتملة',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return CircularPercentIndicator(
                          radius: 35.0,
                          lineWidth: 8.0,
                          percent: overallProgress * _progressAnimation.value,
                          center: Text(
                            '${(overallProgress * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 16,
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
                
                const SizedBox(height: 16),
                
                // شريط المستوى
                Row(
                  children: [
                    const Icon(
                      PhosphorIcons.star_fill,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'المستوى 3',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '450/600 نقطة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 96,
                        lineHeight: 8.0,
                        percent: 0.75 * _progressAnimation.value,
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        progressColor: Colors.amber,
                        barRadius: const Radius.circular(10),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'المستوى التالي في 150 نقطة',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // قائمة الإنجازات
          ...achievements.take(3).map((achievement) => 
            _buildAchievementCard(achievement)
          ).toList(),
          
          // بطاقة عرض المزيد
          if (achievements.length > 3)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => context.go('/profile/achievements'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.plus_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
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
    final progress = achievement.currentProgress / achievement.maxProgress;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: achievement.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: achievement.isCompleted 
              ? achievement.color 
              : achievement.color.withOpacity(0.2),
          width: achievement.isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // أيقونة الإنجاز
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isCompleted 
                  ? achievement.color 
                  : achievement.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    achievement.icon,
                    color: achievement.isCompleted 
                        ? Colors.white 
                        : achievement.color,
                    size: 28,
                  ),
                ),
                if (achievement.isCompleted)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        PhosphorIcons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (achievement.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'مكتمل',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // شريط التقدم
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return LinearPercentIndicator(
                              width: 150,
                              lineHeight: 6.0,
                              percent: progress * _progressAnimation.value,
                              backgroundColor: achievement.color.withOpacity(0.2),
                              progressColor: achievement.color,
                              barRadius: const Radius.circular(10),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${achievement.currentProgress}/${achievement.maxProgress}',
                      style: TextStyle(
                        fontSize: 12,
                        color: achievement.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // المكافأة
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.gift,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      achievement.reward,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
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