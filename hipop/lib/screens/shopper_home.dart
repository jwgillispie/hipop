import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../widgets/common/simple_places_widget.dart';
import '../services/places_service.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/settings_dropdown.dart';
import '../widgets/common/favorite_button.dart';
import '../services/market_service.dart';
import '../models/market.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({super.key});

  @override
  State<ShopperHome> createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  String _searchLocation = '';
  PlaceDetails? _selectedSearchPlace;
  List<Market> _markets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllMarkets();
  }


  void _loadAllMarkets() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load from common cities
      final cities = ['Atlanta', 'Decatur', 'Marietta', 'Sandy Springs', 'Buckhead', 'Tucker'];
      final Set<Market> allMarkets = {};
      
      for (final city in cities) {
        try {
          final cityMarkets = await MarketService.getMarketsByCity(city);
          allMarkets.addAll(cityMarkets);
        } catch (e) {
          debugPrint('Error loading markets for $city: $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _markets = allMarkets.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _searchMarketsByLocation(String location) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final markets = await MarketService.getMarketsByCity(location);
      if (mounted) {
        setState(() {
          _markets = markets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _clearSearch() {
    setState(() {
      _searchLocation = '';
      _selectedSearchPlace = null;
    });
    _loadAllMarkets();
  }
  
  void _performPlaceSearch(PlaceDetails? placeDetails) {
    if (placeDetails == null) {
      _clearSearch();
      return;
    }
    
    setState(() {
      _searchLocation = placeDetails.formattedAddress;
      _selectedSearchPlace = placeDetails;
    });
    
    // Extract city from place details for market search
    final locationParts = placeDetails.formattedAddress.split(',');
    final city = locationParts.length > 1 ? locationParts[1].trim() : locationParts[0];
    
    _searchMarketsByLocation(city);
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
            title: const Text('HiPop Markets'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            actions: [
              BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, favoritesState) {
                  final totalFavorites = favoritesState.totalFavorites;
                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () => context.pushNamed('favorites'),
                        icon: const Icon(Icons.favorite),
                        tooltip: 'My Favorites',
                      ),
                      if (totalFavorites > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$totalFavorites',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                onPressed: () => context.pushNamed('shopperCalendar'),
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Market Calendar',
              ),
              const SettingsDropdown(),
            ],
          ),
          body: SingleChildScrollView(
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
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Find Local Markets',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Discover markets and vendors near you',
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
                  'Find Markets Near You',
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
                            'or browse all markets',
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
                    if (_searchLocation.isNotEmpty || _selectedSearchPlace != null) ...[ 
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Show All Markets'),
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
                          ? 'All Markets' 
                          : 'Markets in $_searchLocation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_markets.isNotEmpty)
                      Text(
                        '${_markets.length} found',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMarketsList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketsList() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading markets...');
    }

    if (_markets.isEmpty) {
      return _buildNoResultsMessage();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _markets.length,
      itemBuilder: (context, index) {
        final market = _markets[index];
        return _buildMarketCard(market);
      },
    );
  }
  
  Widget _buildMarketCard(Market market) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _handleMarketTap(market),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.store_mall_directory,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          market.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Market • ${market.operatingDays.length} days/week',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  FavoriteButton(
                    itemId: market.id,
                    type: FavoriteType.market,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      market.address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              if (market.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  market.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No markets found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchLocation.isEmpty
                ? 'Markets will appear here as they join'
                : 'No markets found in $_searchLocation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchLocation.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show All Markets'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleMarketTap(Market market) {
    context.pushNamed('marketDetail', extra: market);
  }
}