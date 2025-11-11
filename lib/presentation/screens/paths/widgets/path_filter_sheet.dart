import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/path_model.dart';
import '../../../providers/paths_provider.dart';

class PathFilterSheet extends StatefulWidget {
  const PathFilterSheet({super.key});

  @override
  State<PathFilterSheet> createState() => _PathFilterSheetState();
}

class _PathFilterSheetState extends State<PathFilterSheet> {
  ActivityType? selectedActivity;
  DifficultyLevel? selectedDifficulty;
  String? selectedLocation;
  
  @override
  void initState() {
    super.initState();
    // لا نحتاج لقراءة القيم من provider هنا
    // لأن هذه filter sheet مستقلة
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'فلتر المسارات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          
          // Activity type filter
          Text(
            'نوع النشاط',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ActivityType.values.map((activity) {
              return FilterChip(
                label: Text(_getActivityText(activity, context)),
                selected: selectedActivity == activity,
                onSelected: (selected) {
                  setState(() {
                    selectedActivity = selected ? activity : null;
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Difficulty filter
          Text(
            'مستوى الصعوبة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DifficultyLevel.values.map((difficulty) {
              return FilterChip(
                label: Text(_getDifficultyText(difficulty, context)),
                selected: selectedDifficulty == difficulty,
                onSelected: (selected) {
                  setState(() {
                    selectedDifficulty = selected ? difficulty : null;
                  });
                },
                selectedColor: _getDifficultyColor(difficulty).withOpacity(0.2),
                checkmarkColor: _getDifficultyColor(difficulty),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Location filter
          Text(
            'الموقع',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['north', 'center', 'south'].map((locationKey) {
              final localizations = AppLocalizations.ofOrThrow(context);
              final location = localizations.get(locationKey);
              return FilterChip(
                label: Text(location),
                selected: selectedLocation == locationKey,
                onSelected: (selected) {
                  setState(() {
                    selectedLocation = selected ? locationKey : null;
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedActivity = null;
                      selectedDifficulty = null;
                      selectedLocation = null;
                    });
                  },
                  child: Text(localizations.get('clear_all')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final provider = context.read<PathsProvider>();
                    provider.setActivityFilter(selectedActivity);
                    provider.setDifficultyFilter(selectedDifficulty);
                    provider.setLocationFilter(selectedLocation);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(localizations.get('apply')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  String _getActivityText(ActivityType activity, BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    switch (activity) {
      case ActivityType.hiking:
        return localizations.get('hiking');
      case ActivityType.camping:
        return localizations.get('camping');
      case ActivityType.climbing:
        return localizations.get('climbing');
      case ActivityType.religious:
        return localizations.get('religious');
      case ActivityType.cultural:
        return localizations.get('cultural');
      case ActivityType.nature:
        return localizations.get('nature');
      case ActivityType.archaeological:
        return localizations.get('archaeological');
    }
  }
  
  String _getDifficultyText(DifficultyLevel difficulty, BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    switch (difficulty) {
      case DifficultyLevel.easy:
        return localizations.get('easy');
      case DifficultyLevel.medium:
        return localizations.get('medium');
      case DifficultyLevel.hard:
        return localizations.get('hard');
    }
  }
  
  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.success;
      case DifficultyLevel.medium:
        return AppColors.warning;
      case DifficultyLevel.hard:
        return AppColors.error;
    }
  }
}