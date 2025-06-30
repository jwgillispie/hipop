import 'package:flutter/material.dart';
import '../models/market.dart';
import '../models/vendor_market.dart';
import '../models/vendor_post.dart';
import '../services/market_service.dart';
import '../repositories/vendor_posts_repository.dart';
import '../widgets/common/google_places_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../services/places_service.dart';
import '../widgets/common/settings_dropdown.dart';
import 'market_detail_screen.dart';

class MarketDiscoveryScreen extends StatefulWidget {
  const MarketDiscoveryScreen({super.key});

  @override
  State<MarketDiscoveryScreen> createState() => _MarketDiscoveryScreenState();
}

class _MarketDiscoveryScreenState extends State<MarketDiscoveryScreen> {
  String _selectedCity = 'Atlanta'; // Default to Atlanta
  List<Market> _markets = [];
  Map<String, List<VendorMarket>> _marketVendors = {};
  Map<String, int> _marketActiveVendorsToday = {};
  Map<String, int> _marketVendorCounts = {};
  bool _isLoading = true;
  String? _error;
  
  final VendorPostsRepository _vendorPostsRepository = VendorPostsRepository();

  @override
  void initState() {
    super.initState();
    _loadMarketsForCity(_selectedCity);
  }

  Future<void> _loadMarketsForCity(String city) async {
    debugPrint('Loading markets for city: "$city"');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load markets for the selected city
      final markets = await MarketService.getMarketsByCity(city);
      debugPrint('Found ${markets.length} markets for city "$city"');
      
      // Debug: Log all markets to see what cities we have in the database
      if (markets.isEmpty) {
        debugPrint('No markets found. Checking what cities exist in the database...');
        final allMarkets = await MarketService.getAllActiveMarkets();
        debugPrint('All active markets in database (${allMarkets.length} total):');
        for (final market in allMarkets) {
          debugPrint('  - ${market.name} in ${market.city}, ${market.state}');
        }
      }
      
      // Load vendor counts for each market
      final Map<String, List<VendorMarket>> marketVendors = {};
      final Map<String, int> activeVendorsToday = {};
      final Map<String, int> marketVendorCounts = {};
      
      for (final market in markets) {
        try {
          // Get all vendors for this market (legacy vendor-market relationships)
          final vendors = await MarketService.getMarketVendors(market.id);
          marketVendors[market.id] = vendors;
          
          // Get vendors active today (legacy)
          final activeToday = await MarketService.getActiveVendorsForMarketToday(market.id);
          activeVendorsToday[market.id] = activeToday.length;
          
          // Get unique vendor count from posts (new system)
          final marketPosts = await _vendorPostsRepository.getMarketPosts(market.id).first;
          final uniqueVendorIds = marketPosts.map((post) => post.vendorId).toSet();
          marketVendorCounts[market.id] = uniqueVendorIds.length;
        } catch (e) {
          debugPrint('Error loading vendors for market ${market.name}: $e');
          marketVendors[market.id] = [];
          activeVendorsToday[market.id] = 0;
          marketVendorCounts[market.id] = 0;
        }
      }

      setState(() {
        _markets = markets;
        _marketVendors = marketVendors;
        _marketActiveVendorsToday = activeVendorsToday;
        _marketVendorCounts = marketVendorCounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load markets: $e';
        _isLoading = false;
      });
    }
  }

  void _onCitySelected(PlaceDetails placeDetails) {
    debugPrint('Place selected - Name: ${placeDetails.name}, FormattedAddress: ${placeDetails.formattedAddress}');
    
    // Extract city name from the formatted address or name
    String cityName = _extractCityFromPlace(placeDetails);
    debugPrint('Extracted city name: $cityName');
    
    setState(() {
      _selectedCity = cityName;
    });
    _loadMarketsForCity(cityName);
  }
  
  String _extractCityFromPlace(PlaceDetails placeDetails) {
    debugPrint('Extracting city from place: ${placeDetails.name} - ${placeDetails.formattedAddress}');
    
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
            debugPrint('Extracted city from address: $part');
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
    
    debugPrint('Using place name as city: $name');
    return _cleanCityName(name);
  }
  
  String _cleanCityName(String cityName) {
    // Remove common suffixes that aren't part of the city name
    String cleaned = cityName
        .replaceAll(RegExp(r',\s*(GA|Georgia|AL|Alabama|FL|Florida|SC|South Carolina|NC|North Carolina|TN|Tennessee)\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r',\s*USA\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+(County|Metro|Metropolitan|Area)\s*$', caseSensitive: false), '')
        .trim();
        
    debugPrint('Cleaned city name: "$cityName" -> "$cleaned"');
    return cleaned;
  }

  void _onMarketTapped(Market market) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketDetailScreen(market: market),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        backgroundColor: Colors.orange,
        actions: [
          const SettingsDropdown(),
        ],
      ),
      body: Column(
        children: [
          // City Search Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.orange.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Markets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                GooglePlacesWidget(
                  onPlaceSelected: _onCitySelected,
                  initialLocation: _selectedCity,
                ),
              ],
            ),
          ),
          
          // Markets List
          Expanded(
            child: _buildMarketsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketsContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading markets...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        title: 'Error Loading Markets',
        message: _error!,
        onRetry: () => _loadMarketsForCity(_selectedCity),
      );
    }

    if (_markets.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City Results Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Markets in $_selectedCity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_markets.length} markets found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Markets Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3.5,
                mainAxisSpacing: 12,
              ),
              itemCount: _markets.length,
              itemBuilder: (context, index) {
                final market = _markets[index];
                return _buildMarketCard(market);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketCard(Market market) {
    final vendorCount = _marketVendorCounts[market.id] ?? 0;
    final activeToday = _marketActiveVendorsToday[market.id] ?? 0;
    final isOpenToday = market.isOpenToday;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _onMarketTapped(market),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Market Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isOpenToday ? Colors.green.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  color: isOpenToday ? Colors.green.shade700 : Colors.grey.shade600,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Market Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            market.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOpenToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'OPEN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      market.address.split(',').first, // Show just street address
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        if (activeToday > 0) ...[
                          Icon(Icons.people, size: 16, color: Colors.orange.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '$activeToday active today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '$vendorCount vendors',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        
                        const Spacer(),
                        
                        if (isOpenToday && market.todaysHours != null) ...[
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            market.todaysHours!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No markets found in $_selectedCity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for a different city or check back later as we add more markets.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCity = 'Atlanta';
                });
                _loadMarketsForCity('Atlanta');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Try Atlanta'),
            ),
          ],
        ),
      ),
    );
  }
}