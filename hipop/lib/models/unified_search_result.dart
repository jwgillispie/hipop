import 'market.dart';
import 'vendor_post.dart';

class UnifiedSearchResults {
  final List<Market> markets;
  final List<VendorPost> independentVendorPosts;
  final int totalCount;

  UnifiedSearchResults({
    required this.markets,
    required this.independentVendorPosts,
    required this.totalCount,
  });

  List<SearchResultItem> get allResults {
    final List<SearchResultItem> results = [];
    
    // Add markets as search result items
    for (final market in markets) {
      results.add(SearchResultItem.fromMarket(market));
    }
    
    // Add independent vendor posts as search result items
    for (final vendorPost in independentVendorPosts) {
      results.add(SearchResultItem.fromVendorPost(vendorPost));
    }
    
    // Sort by distance if available, otherwise by name/title
    results.sort((a, b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return a.title.compareTo(b.title);
    });
    
    return results;
  }

  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => !isEmpty;
}

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? distance; // in km
  final SearchResultType type;
  final Market? market;
  final VendorPost? vendorPost;

  SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    this.latitude,
    this.longitude,
    this.distance,
    required this.type,
    this.market,
    this.vendorPost,
  });

  factory SearchResultItem.fromMarket(Market market, {double? distance}) {
    return SearchResultItem(
      id: market.id,
      title: market.name,
      subtitle: 'Market • ${market.operatingDays.length} days/week',
      location: market.address,
      latitude: market.latitude,
      longitude: market.longitude,
      distance: distance,
      type: SearchResultType.market,
      market: market,
    );
  }

  factory SearchResultItem.fromVendorPost(VendorPost vendorPost, {double? distance}) {
    final DateTime now = DateTime.now();
    final bool isToday = vendorPost.popUpStartDateTime.day == now.day &&
        vendorPost.popUpStartDateTime.month == now.month &&
        vendorPost.popUpStartDateTime.year == now.year;
    
    final String timeInfo = isToday 
        ? 'Today ${vendorPost.popUpStartDateTime.hour}:${vendorPost.popUpStartDateTime.minute.toString().padLeft(2, '0')}'
        : '${vendorPost.popUpStartDateTime.month}/${vendorPost.popUpStartDateTime.day}';

    return SearchResultItem(
      id: vendorPost.id,
      title: vendorPost.vendorName,
      subtitle: 'Independent Pop-up • $timeInfo',
      location: vendorPost.location,
      latitude: vendorPost.latitude,
      longitude: vendorPost.longitude,
      distance: distance,
      type: SearchResultType.independentVendor,
      vendorPost: vendorPost,
    );
  }
}

enum SearchResultType {
  market,
  independentVendor,
}