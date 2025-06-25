import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/common/simple_places_widget.dart';
import '../services/places_service.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../models/unified_search_result.dart';
import '../services/unified_search_service.dart';
import '../widgets/common/settings_dropdown.dart';
import '../widgets/search/unified_result_card.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({super.key});

  @override
  State<ShopperHome> createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  String _searchLocation = '';
  PlaceDetails? _selectedSearchPlace;
  double _searchRadius = 10.0; // Default 10km radius
  final UnifiedSearchService _unifiedSearchService = UnifiedSearchService();
  
  // Use unified search results instead of just vendor posts
  Future<UnifiedSearchResults>? _searchResults;
  SearchResultType? _filterType; // For filtering results
  bool _isLoading = false;
  
  static const List<double> _radiusOptions = [5.0, 10.0, 25.0, 50.0];

  @override
  void initState() {
    super.initState();
    // Initialize with empty search to show all results
    _performSearch('');
  }

  void _performSearch(String location) {
    setState(() {
      _searchLocation = location;
      _selectedSearchPlace = null; // Clear place when doing text search
      _isLoading = true;
      
      _searchResults = _unifiedSearchService.searchByLocationWithFilter(
        location: location,
        filterType: _filterType,
      );
    });
    
    _searchResults?.then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }).catchError((e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }
  
  void _clearSearch() {
    setState(() {
      _searchLocation = '';
      _selectedSearchPlace = null;
      _searchRadius = 10.0; // Reset to default
      _filterType = null; // Clear filter
    });
    _performSearch('');
  }
  
  void _performPlaceSearch(String location) {
    setState(() {
      _searchLocation = location;
      _selectedSearchPlace = null;
      _isLoading = true;
      
      _searchResults = _unifiedSearchService.searchByLocationWithFilter(
        location: location,
        filterType: _filterType,
      );
    });
    
    _searchResults?.then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }).catchError((e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }
  
  void _setResultFilter(SearchResultType? filterType) {
    setState(() {
      _filterType = filterType;
    });
    
    // Re-run search with new filter
    if (_selectedSearchPlace != null) {
      _performPlaceSearch(_searchLocation);
    } else {
      _performSearch(_searchLocation);
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: LoadingWidget(message: 'Signing you in...'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('HiPop'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            actions: [
              const SettingsDropdown(),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.shopping_bag, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  state.user.displayName ?? state.user.email ?? 'Shopper',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Find Pop-ups Near You',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    SimplePlacesWidget(
                      initialLocation: _searchLocation,
                      onLocationSelected: _performPlaceSearch,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or browse all',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedSearchPlace != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'Search Radius',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                const Spacer(),
                                DropdownButton<double>(
                                  value: _searchRadius,
                                  underline: const SizedBox(),
                                  items: _radiusOptions.map((radius) {
                                    return DropdownMenuItem<double>(
                                      value: radius,
                                      child: Text('${radius.toInt()} km'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _searchRadius = value;
                                      });
                                      _performPlaceSearch(_searchLocation);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_searchLocation.isNotEmpty || _selectedSearchPlace != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Show All Pop-ups'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _searchLocation.isEmpty 
                          ? 'All Pop-ups' 
                          : 'Pop-ups in $_searchLocation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FutureBuilder<UnifiedSearchResults>(
                      future: _searchResults,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Text(
                            '${snapshot.data!.totalCount} found',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilterBar(),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildUnifiedResults(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildFilterBar() {
    return Row(
      children: [
        Text(
          'Show: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        _buildFilterChip('All', null),
        const SizedBox(width: 8),
        _buildFilterChip('Markets', SearchResultType.market),
        const SizedBox(width: 8),
        _buildFilterChip('Vendors', SearchResultType.independentVendor),
      ],
    );
  }

  Widget _buildFilterChip(String label, SearchResultType? type) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _setResultFilter(selected ? type : null);
      },
      selectedColor: Colors.orange.withValues(alpha: 0.2),
      checkmarkColor: Colors.orange,
    );
  }

  Widget _buildUnifiedResults() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Searching for markets and vendors...');
    }

    if (_searchResults == null) {
      return const LoadingWidget(message: 'Loading...');
    }

    return FutureBuilder<UnifiedSearchResults>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Searching for markets and vendors...');
        }

        if (snapshot.hasError) {
          return ErrorDisplayWidget.network(
            onRetry: () => _performSearch(_searchLocation),
          );
        }

        final results = snapshot.data;
        if (results == null || results.isEmpty) {
          return _buildNoResultsMessage();
        }

        final allResults = results.allResults;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${allResults.length} result${allResults.length == 1 ? '' : 's'} found',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: allResults.length,
                itemBuilder: (context, index) {
                  final result = allResults[index];
                  return UnifiedResultCard(
                    result: result,
                    onTap: () => _handleResultTap(result),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchLocation.isEmpty
                ? 'Try searching for a location'
                : 'Try a different search term or location',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchLocation.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(''),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show All Results'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleResultTap(SearchResultItem result) {
    switch (result.type) {
      case SearchResultType.market:
        if (result.market != null) {
          context.pushNamed('marketDetail', extra: result.market);
        }
        break;
      case SearchResultType.independentVendor:
        if (result.vendorPost != null) {
          context.pushNamed('vendorPostDetail', extra: result.vendorPost);
        }
        break;
    }
  }

}