import 'dart:math';
import '../models/unified_search_result.dart';
import '../models/market.dart';
import '../models/vendor_post.dart';
import '../repositories/vendor_posts_repository.dart';
import '../services/market_service.dart';

class UnifiedSearchService {
  final VendorPostsRepository _vendorPostsRepository = VendorPostsRepository();

  /// Search for both markets and independent vendor posts by location
  Future<UnifiedSearchResults> searchByLocation({
    required String location,
    double? latitude,
    double? longitude,
    double? radiusKm = 50.0,
  }) async {
    try {
      // Search both markets and vendor posts in parallel for better performance
      final results = await Future.wait([
        _searchMarkets(location, latitude, longitude, radiusKm),
        _searchIndependentVendorPosts(location, latitude, longitude, radiusKm),
      ]);

      final markets = results[0] as List<Market>;
      final vendorPosts = results[1] as List<VendorPost>;

      return UnifiedSearchResults(
        markets: markets,
        independentVendorPosts: vendorPosts,
        totalCount: markets.length + vendorPosts.length,
      );
    } catch (e) {
      print('Error in unified search: $e');
      return UnifiedSearchResults(
        markets: [],
        independentVendorPosts: [],
        totalCount: 0,
      );
    }
  }

  /// Search for markets by location with proximity support
  Future<List<Market>> _searchMarkets(
    String location,
    double? latitude,
    double? longitude,
    double? radiusKm,
  ) async {
    try {
      // Get all markets (since MarketService doesn't support proximity search yet)
      final allMarkets = await _getAllMarkets();
      
      if (latitude != null && longitude != null && radiusKm != null) {
        // Filter markets by proximity
        return allMarkets.where((market) {
          if (market.latitude == 0 || market.longitude == 0) return false;
          
          final distance = _calculateDistance(
            latitude, longitude,
            market.latitude, market.longitude,
          );
          
          return distance <= radiusKm;
        }).toList();
      } else {
        // Filter markets by location text matching
        final locationLower = location.toLowerCase();
        return allMarkets.where((market) {
          return market.name.toLowerCase().contains(locationLower) ||
                 market.address.toLowerCase().contains(locationLower) ||
                 market.city.toLowerCase().contains(locationLower);
        }).toList();
      }
    } catch (e) {
      print('Error searching markets: $e');
      return [];
    }
  }

  /// Search for independent vendor posts (marketId is null)
  Future<List<VendorPost>> _searchIndependentVendorPosts(
    String location,
    double? latitude,
    double? longitude,
    double? radiusKm,
  ) async {
    try {
      Stream<List<VendorPost>> postsStream;
      
      if (latitude != null && longitude != null && radiusKm != null) {
        // Use proximity search for vendor posts
        postsStream = _vendorPostsRepository.searchPostsByLocationAndProximity(
          location: location,
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );
      } else {
        // Use text-based location search for vendor posts
        postsStream = _vendorPostsRepository.searchPostsByLocation(location);
      }
      
      // Get first result from stream and filter for independent posts only
      final allPosts = await postsStream.first;
      
      // Filter for independent vendor posts (marketId is null)
      return allPosts.where((post) => post.marketId == null).toList();
    } catch (e) {
      print('Error searching independent vendor posts: $e');
      return [];
    }
  }

  /// Get all markets from MarketService
  Future<List<Market>> _getAllMarkets() async {
    try {
      // Try common city names first, then combine results
      final cities = ['Atlanta', 'Decatur', 'Marietta', 'Sandy Springs', 'Buckhead'];
      final Set<Market> allMarkets = {};
      
      for (final city in cities) {
        try {
          final cityMarkets = await MarketService.getMarketsByCity(city);
          allMarkets.addAll(cityMarkets);
        } catch (e) {
          // Continue with other cities if one fails
          print('Error getting markets for $city: $e');
        }
      }
      
      return allMarkets.toList();
    } catch (e) {
      print('Error getting all markets: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double lat1Rad = lat1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double deltaLat = (lat2 - lat1) * (pi / 180);
    final double deltaLon = (lon2 - lon1) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Search with filtering by result type
  Future<UnifiedSearchResults> searchByLocationWithFilter({
    required String location,
    double? latitude,
    double? longitude,
    double? radiusKm = 50.0,
    SearchResultType? filterType,
  }) async {
    final allResults = await searchByLocation(
      location: location,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );

    if (filterType == null) return allResults;

    return UnifiedSearchResults(
      markets: filterType == SearchResultType.market ? allResults.markets : [],
      independentVendorPosts: filterType == SearchResultType.independentVendor 
          ? allResults.independentVendorPosts 
          : [],
      totalCount: filterType == SearchResultType.market 
          ? allResults.markets.length
          : allResults.independentVendorPosts.length,
    );
  }
}