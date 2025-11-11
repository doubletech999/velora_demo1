import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/path_model.dart';
import '../../providers/saved_paths_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_indicator.dart';
import '../paths/widgets/path_card.dart';

class SavedPathsScreen extends StatelessWidget {
  const SavedPathsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Redirect guests to login
    if (userProvider.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return Scaffold(
        appBar: CustomAppBar(title: localizations.get('saved')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final savedPathsProvider = Provider.of<SavedPathsProvider>(context);
    final isLoading = savedPathsProvider.isLoading;
    final error = savedPathsProvider.error;
    final savedPaths = savedPathsProvider.savedPaths;

    return Scaffold(
      appBar: CustomAppBar(title: localizations.get('saved_paths')),
      body: _buildBody(
        context,
        isLoading: isLoading,
        error: error,
        savedPaths: savedPaths,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required bool isLoading,
    required String? error,
    required List<PathModel> savedPaths,
  }) {
    final localizations = AppLocalizations.ofOrThrow(context);

    if (isLoading) {
      return const LoadingIndicator();
    }

    if (error != null) {
      return CustomErrorWidget(
        message: error,
        onRetry: () {
          final savedPathsProvider = Provider.of<SavedPathsProvider>(
            context,
            listen: false,
          );
          savedPathsProvider.refreshSavedPaths();
        },
      );
    }

    if (savedPaths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.bookmark_simple,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.get('no_saved_paths'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.get('no_saved_paths_description'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/paths');
              },
              icon: const Icon(PhosphorIcons.map_trifold),
              label: Text(localizations.get('explore_paths')),
            ),
          ],
        ),
      );
    }

    final savedPathsProvider = Provider.of<SavedPathsProvider>(
      context,
      listen: false,
    );

    return RefreshIndicator(
      onRefresh: () async {
        await savedPathsProvider.refreshSavedPaths();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedPaths.length,
        itemBuilder: (context, index) {
          final path = savedPaths[index];
          final pathId = path.id;
          return Dismissible(
            key: Key(pathId),
            background: Container(
              color: AppColors.error,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(PhosphorIcons.trash, color: Colors.white),
            ),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) async {
              await savedPathsProvider.removeSavedPath(pathId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations
                          .get('path_removed_from_saved')
                          .replaceAll('{path}', path.nameAr ?? ''),
                    ),
                    action: SnackBarAction(
                      label: localizations.get('undo'),
                      onPressed: () async {
                        await savedPathsProvider.savePath(pathId);
                      },
                    ),
                  ),
                );
              }
            },
            child: PathCard(
              path: path,
              onTap: () => context.go('/paths/${path.id}'),
            ),
          );
        },
      ),
    );
  }
}
