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
import '../services/url_launcher_service.dart';
import '../models/market.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({super.key});

  @override
  State<ShopperHome> createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  String _searchLocation = '';
  PlaceDetails? _selectedSearchPlace;
  String _selectedCity = '';

  void _clearSearch() {
    setState(() {
      _searchLocation = '';
      _selectedSearchPlace = null;
      _selectedCity = '';
    });
  }
  
  void _performPlaceSearch(PlaceDetails? placeDetails) {
    if (placeDetails == null) {
      _clearSearch();
      return;
    }
    
    setState(() {
      _searchLocation = placeDetails.formattedAddress;
      _selectedSearchPlace = placeDetails;
      
      // Extract city from place details for market search using better logic
      _selectedCity = _extractCityFromPlace(placeDetails);
    });
  }
  
  String _extractCityFromPlace(PlaceDetails placeDetails) {
    debugPrint('ShopperHome: Extracting city from ${placeDetails.name} - ${placeDetails.formattedAddress}');
    
    // First try to extract city from the formatted address
    final addressParts = placeDetails.formattedAddress.split(', ');
    
    // For US addresses, the format is usually:
    // "Street Address, City, State ZIP" or "City, State" or "Neighborhood, City, State"
    if (addressParts.length >= 2) {
      // Look for the part that contains the city (before state)
      for (int i = 0; i < addressParts.length - 1; i++) {
        final part = addressParts[i].trim();
        // Skip if it looks like a street address (contains numbers at start)
        if (!RegExp(r'^\d').hasMatch(part)) {
          // Check if next part looks like a state (2 letters) or state + ZIP
          final nextPart = addressParts[i + 1].trim();
          if (RegExp(r'^[A-Z]{2}(\s+\d{5})?$').hasMatch(nextPart) || 
              RegExp(r'^(Georgia|Alabama|Florida|South Carolina|North Carolina|Tennessee)').hasMatch(nextPart)) {
            debugPrint('ShopperHome: Extracted city from address: $part');
            return _cleanCityName(part);
          }
        }
      }
    }
    
    // Try using the place name if it looks like a city
    String name = placeDetails.name;
    
    // If name is the same as formatted address, try to extract the first meaningful part
    if (name == placeDetails.formattedAddress && addressParts.isNotEmpty) {
      // Use the first part if it doesn't start with a number
      final firstPart = addressParts[0].trim();
      if (!RegExp(r'^\d').hasMatch(firstPart)) {
        name = firstPart;
      }
    }
    
    debugPrint('ShopperHome: Using place name as city: $name');
    return _cleanCityName(name);
  }
  
  String _cleanCityName(String cityName) {
    // Remove common suffixes that aren't part of the city name
    String cleaned = cityName
        .replaceAll(RegExp(r',\s*(GA|Georgia|AL|Alabama|FL|Florida|SC|South Carolina|NC|North Carolina|TN|Tennessee)\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r',\s*USA\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+(County|Metro|Metropolitan|Area)\s*$', caseSensitive: false), '')
        .trim();
        
    debugPrint('ShopperHome: Cleaned city name: "$cityName" -> "$cleaned"');
    return cleaned;
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
                onPressed: () => context.pushNamed('shopperRecipes'),
                icon: const Icon(Icons.restaurant_menu),
                tooltip: 'Recipes',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchLocation.isEmpty 
                        ? 'All Markets' 
                        : 'Markets in $_searchLocation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_searchLocation.isNotEmpty && _selectedCity != _searchLocation) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Searching for: $_selectedCity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _buildMarketsStream(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketsStream() {
    return StreamBuilder<List<Market>>(
      stream: _selectedCity.isEmpty 
          ? MarketService.getAllActiveMarketsStream()
          : MarketService.getMarketsByCityStream(_selectedCity),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading markets...');
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading markets',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final markets = snapshot.data ?? [];

        if (markets.isEmpty) {
          return _buildNoResultsMessage();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${markets.length} found',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: markets.length,
              itemBuilder: (context, index) {
                final market = markets[index];
                return _buildMarketCard(market);
              },
            ),
          ],
        );
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
                    child: InkWell(
                      onTap: () => _launchMaps(market.address),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          market.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
                : 'No markets found in $_searchLocation\n\nTry searching for:\n• "Atlanta" or "ATL" for Atlanta area\n• "Decatur" or "DEC" for Decatur area\n• Other Georgia cities',
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
  
  Future<void> _launchMaps(String address) async {
    try {
      await UrlLauncherService.launchMaps(address);
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        if (message.contains('Please copy this URL:')) {
          // Show dialog with copyable URL
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Open in Maps'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Copy this address to open in your maps app:'),
                  const SizedBox(height: 8),
                  SelectableText(
                    address,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open maps: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}