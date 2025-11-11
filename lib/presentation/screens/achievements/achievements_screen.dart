// lib/presentation/screens/achievements/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Redirect guests to login
    if (userProvider.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      final localizations = AppLocalizations.ofOrThrow(context);
      return Scaffold(
        appBar: CustomAppBar(title: localizations.get('achievements_title')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = userProvider.user;
    final localizations = AppLocalizations.ofOrThrow(context);

    return Scaffold(
      appBar: CustomAppBar(title: localizations.get('achievements_title')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Stats Card
          Card(
            color: AppColors.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${user?.achievements ?? 0}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.get('completed_achievements'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.get('keep_exploring'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Achievements List
          _AchievementCategory(
            title: localizations.get('paths_category'),
            achievements: [
              _Achievement(
                title: localizations.get('beginner_explorer'),
                description: localizations.get('beginner_explorer_desc'),
                icon: PhosphorIcons.boat,
                isCompleted: true,
                progress: 1.0,
              ),
              _Achievement(
                title: localizations.get('intermediate_explorer'),
                description: localizations.get('intermediate_explorer_desc'),
                icon: PhosphorIcons.backpack,
                isCompleted: false,
                progress: 0.3,
                progressText: '5/15',
              ),
              _Achievement(
                title: localizations.get('advanced_explorer'),
                description: localizations.get('advanced_explorer_desc'),
                icon: PhosphorIcons.mountains,
                isCompleted: false,
                progress: 0.16,
                progressText: '5/30',
              ),
            ],
          ),

          _AchievementCategory(
            title: localizations.get('regions_category'),
            achievements: [
              _Achievement(
                title: localizations.get('north_explorer'),
                description: localizations.get('north_explorer_desc'),
                icon: PhosphorIcons.tree,
                isCompleted: false,
                progress: 0.4,
                progressText: '2/5',
              ),
              _Achievement(
                title: localizations.get('center_explorer'),
                description: localizations.get('center_explorer_desc'),
                icon: PhosphorIcons.buildings,
                isCompleted: true,
                progress: 1.0,
              ),
              _Achievement(
                title: localizations.get('south_explorer'),
                description: localizations.get('south_explorer_desc'),
                icon: PhosphorIcons.campfire_light,
                isCompleted: false,
                progress: 0.6,
                progressText: '3/5',
              ),
            ],
          ),

          _AchievementCategory(
            title: localizations.get('contributions_category'),
            achievements: [
              _Achievement(
                title: localizations.get('active_contributor'),
                description: localizations.get('active_contributor_desc'),
                icon: PhosphorIcons.star,
                isCompleted: false,
                progress: 0.66,
                progressText: '2/3',
              ),
              _Achievement(
                title: localizations.get('path_photographer'),
                description: localizations.get('path_photographer_desc'),
                icon: PhosphorIcons.camera,
                isCompleted: false,
                progress: 0.2,
                progressText: '1/5',
              ),
            ],
          ),

          _AchievementCategory(
            title: localizations.get('challenges_category'),
            achievements: [
              _Achievement(
                title: localizations.get('height_lover'),
                description: localizations.get('height_lover_desc'),
                icon: PhosphorIcons.mountains_light,
                isCompleted: false,
                progress: 0.33,
                progressText: '1/3',
              ),
              _Achievement(
                title: localizations.get('night_traveler'),
                description: localizations.get('night_traveler_desc'),
                icon: PhosphorIcons.moon_stars,
                isCompleted: true,
                progress: 1.0,
              ),
              _Achievement(
                title: localizations.get('archaeology_enthusiast'),
                description: localizations.get('archaeology_enthusiast_desc'),
                icon: PhosphorIcons.columns,
                isCompleted: false,
                progress: 0.75,
                progressText: '3/4',
              ),
            ],
          ),

          _AchievementCategory(
            title: localizations.get('special_category'),
            achievements: [
              _Achievement(
                title: localizations.get('dead_sea_explorer'),
                description: localizations.get('dead_sea_explorer_desc'),
                icon: PhosphorIcons.waves,
                isCompleted: true,
                progress: 1.0,
              ),
              _Achievement(
                title: localizations.get('heritage_lover'),
                description: localizations.get('heritage_lover_desc'),
                icon: PhosphorIcons.globe,
                isCompleted: false,
                progress: 0.66,
                progressText: '2/3',
              ),
              _Achievement(
                title: localizations.get('desert_adventurer'),
                description: localizations.get('desert_adventurer_desc'),
                icon: PhosphorIcons.campfire_fill,
                isCompleted: true,
                progress: 1.0,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AchievementCategory extends StatelessWidget {
  final String title;
  final List<_Achievement> achievements;

  const _AchievementCategory({required this.title, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...achievements,
        const Divider(height: 32),
      ],
    );
  }
}

class _Achievement extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final double progress;
  final String? progressText;

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.progress,
    this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color:
                    isCompleted
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                isCompleted
                                    ? AppColors.success
                                    : AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (progressText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        progressText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            isCompleted
                ? Icon(PhosphorIcons.trophy, color: Colors.amber)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
