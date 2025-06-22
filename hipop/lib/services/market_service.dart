import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market.dart';
import '../models/vendor_market.dart';

class MarketService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  static final CollectionReference _marketsCollection = _firestore.collection('markets');
  static final CollectionReference _vendorMarketsCollection = _firestore.collection('vendor_markets');

  // Market CRUD operations
  static Future<String> createMarket(Market market) async {
    try {
      final docRef = await _marketsCollection.add(market.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create market: $e');
    }
  }

  static Future<Market?> getMarket(String marketId) async {
    try {
      final doc = await _marketsCollection.doc(marketId).get();
      if (doc.exists) {
        return Market.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get market: $e');
    }
  }

  static Future<List<Market>> getMarketsByCity(String city) async {
    try {
      final querySnapshot = await _marketsCollection
          .where('city', isEqualTo: city)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Market.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get markets by city: $e');
    }
  }

  static Future<List<Market>> getAllActiveMarkets() async {
    try {
      final querySnapshot = await _marketsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('city')
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Market.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all markets: $e');
    }
  }

  static Future<void> updateMarket(String marketId, Map<String, dynamic> updates) async {
    try {
      await _marketsCollection.doc(marketId).update(updates);
    } catch (e) {
      throw Exception('Failed to update market: $e');
    }
  }

  static Future<void> deleteMarket(String marketId) async {
    try {
      await _marketsCollection.doc(marketId).update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to delete market: $e');
    }
  }

  // VendorMarket relationship operations
  static Future<String> createVendorMarketRelationship(VendorMarket vendorMarket) async {
    try {
      final docRef = await _vendorMarketsCollection.add(vendorMarket.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create vendor-market relationship: $e');
    }
  }

  static Future<List<VendorMarket>> getVendorMarkets(String vendorId) async {
    try {
      final querySnapshot = await _vendorMarketsCollection
          .where('vendorId', isEqualTo: vendorId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => VendorMarket.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vendor markets: $e');
    }
  }

  static Future<List<VendorMarket>> getMarketVendors(String marketId) async {
    try {
      final querySnapshot = await _vendorMarketsCollection
          .where('marketId', isEqualTo: marketId)
          .where('isActive', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => VendorMarket.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get market vendors: $e');
    }
  }

  static Future<List<VendorMarket>> getActiveVendorsForMarketToday(String marketId) async {
    try {
      final today = DateTime.now().weekday;
      final dayName = _getDayName(today);
      
      final querySnapshot = await _vendorMarketsCollection
          .where('marketId', isEqualTo: marketId)
          .where('isActive', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .where('schedule', arrayContains: dayName)
          .get();
      
      return querySnapshot.docs
          .map((doc) => VendorMarket.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active vendors for today: $e');
    }
  }

  static Future<void> updateVendorMarketRelationship(String relationshipId, Map<String, dynamic> updates) async {
    try {
      await _vendorMarketsCollection.doc(relationshipId).update(updates);
    } catch (e) {
      throw Exception('Failed to update vendor-market relationship: $e');
    }
  }

  static Future<void> approveVendorForMarket(String relationshipId) async {
    try {
      await _vendorMarketsCollection.doc(relationshipId).update({'isApproved': true});
    } catch (e) {
      throw Exception('Failed to approve vendor for market: $e');
    }
  }

  static Future<void> removeVendorFromMarket(String relationshipId) async {
    try {
      await _vendorMarketsCollection.doc(relationshipId).update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to remove vendor from market: $e');
    }
  }

  // Helper methods
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return '';
    }
  }

  // Batch operations for seeding data
  static Future<void> seedMarkets(List<Market> markets) async {
    try {
      final batch = _firestore.batch();
      
      for (final market in markets) {
        final docRef = _marketsCollection.doc();
        batch.set(docRef, market.copyWith(id: docRef.id).toFirestore());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed markets: $e');
    }
  }
}