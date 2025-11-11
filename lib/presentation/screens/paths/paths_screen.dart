import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../providers/paths_provider.dart';
import '../../../core/localization/app_localizations.dart';
import 'widgets/path_card.dart';
import 'widgets/path_filter_sheet.dart';

class PathsScreen extends StatefulWidget {
  const PathsScreen({super.key});

  @override
  State<PathsScreen> createState() => _PathsScreenState();
}

class _PathsScreenState extends State<PathsScreen> {
  @override
  void initState() {
    super.initState();
    // Load paths when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathsProvider = Provider.of<PathsProvider>(context, listen: false);
      // تحميل البيانات إذا لم تكن محملة
      // هذه الصفحة تعرض المواقع السياحية فقط
      if (pathsProvider.sites.isEmpty && !pathsProvider.isLoading) {
        pathsProvider.loadPaths();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get('sites')), // تغيير العنوان إلى "المواقع"
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.funnel),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Consumer<PathsProvider>(
        builder: (context, pathsProvider, child) {
          // Show loading indicator while loading
          if (pathsProvider.isLoading && pathsProvider.sites.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error if there's an error
          if (pathsProvider.error != null && pathsProvider.sites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.warning_circle,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.get('paths_loading_error'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      pathsProvider.loadPaths();
                    },
                    child: Text(localizations.get('retry')),
                  ),
                ],
              ),
            );
          }

          // عرض المواقع السياحية فقط (type='site')
          final sites = pathsProvider.filteredSites;

          if (sites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.buildings, // تغيير الأيقونة إلى buildings للمواقع
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.get('no_sites_available'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await pathsProvider.loadPaths();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sites.length,
              itemBuilder: (context, index) {
                final site = sites[index];
                return PathCard(path: site);
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const PathFilterSheet(),
    );
  }
}