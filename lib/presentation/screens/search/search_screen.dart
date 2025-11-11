import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/path_model.dart';
import '../../providers/paths_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../paths/widgets/path_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isSearching = false;
  List<PathModel> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _query = query;
      _isSearching = true;
    });

    // Filtrar directamente las rutas basado en el query
    final pathsProvider = Provider.of<PathsProvider>(context, listen: false);
    final allPaths = pathsProvider.paths;
    
    // Filtrado simple por nombre, descripción o ubicación (esto reemplaza la llamada a searchPaths)
    final results = allPaths.where((path) {
      final lowerQuery = query.toLowerCase();
      return path.name.toLowerCase().contains(lowerQuery) ||
             path.nameAr.contains(lowerQuery) ||
             path.description.toLowerCase().contains(lowerQuery) ||
             path.descriptionAr.contains(lowerQuery) ||
             path.location.toLowerCase().contains(lowerQuery) ||
             path.locationAr.contains(lowerQuery);
    }).toList();
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: localizations.get('search_placeholder'),
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          onChanged: (value) {
            // Only search if the user pauses typing for a moment
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(PhosphorIcons.x),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final localizations = AppLocalizations.ofOrThrow(context);
    if (_isSearching) {
      return LoadingIndicator(message: localizations.get('searching'));
    }

    if (_query.isEmpty) {
      return Center(
        child: Text(localizations.get('search_placeholder_full')),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.magnifying_glass,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.get('no_search_results').replaceAll('{query}', _query),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.get('try_different_search'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final path = _searchResults[index];
        return PathCard(
          path: path,
          onTap: () => context.go('/paths/${path.id}'),
        );
      },
    );
  }
}