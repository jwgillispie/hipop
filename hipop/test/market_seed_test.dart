import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/models/market.dart';
import '../lib/models/vendor_market.dart';
import '../lib/services/market_service.dart';
import '../lib/data/atlanta_markets_seed.dart';

// This is a test/utility script to seed the markets data
// Run with: flutter test test/market_seed_test.dart

void main() {
  group('Market Backend Tests', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      // Note: In a real scenario, you'd set up Firebase testing properly
      // For now, this is just model testing
    });

    test('Market model serialization works correctly', () {
      final market = Market(
        id: 'test-id',
        name: 'Test Market',
        address: '123 Test St',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7490,
        longitude: -84.3880,
        operatingDays: {'saturday': '9AM-2PM'},
        description: 'Test market description',
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Test toFirestore
      final firestoreData = market.toFirestore();
      expect(firestoreData['name'], equals('Test Market'));
      expect(firestoreData['city'], equals('Atlanta'));
      expect(firestoreData['operatingDays'], equals({'saturday': '9AM-2PM'}));

      print('✅ Market model serialization test passed');
    });

    test('VendorMarket model serialization works correctly', () {
      final vendorMarket = VendorMarket(
        id: 'test-vm-id',
        vendorId: 'vendor-123',
        marketId: 'market-456',
        schedule: ['saturday', 'sunday'],
        boothNumber: 'A15',
        isActive: true,
        isApproved: true,
        joinedDate: DateTime.now(),
      );

      // Test toFirestore
      final firestoreData = vendorMarket.toFirestore();
      expect(firestoreData['vendorId'], equals('vendor-123'));
      expect(firestoreData['marketId'], equals('market-456'));
      expect(firestoreData['schedule'], equals(['saturday', 'sunday']));
      expect(firestoreData['isApproved'], equals(true));

      // Test helper methods
      expect(vendorMarket.isActiveAndApproved, equals(true));
      expect(vendorMarket.isScheduledForDay('saturday'), equals(true));
      expect(vendorMarket.isScheduledForDay('monday'), equals(false));
      expect(vendorMarket.scheduleDisplay, equals('Saturday, Sunday'));

      print('✅ VendorMarket model serialization test passed');
    });

    test('Atlanta markets seed data is valid', () {
      final markets = AtlantaMarketsSeed.getAtlantaMarkets();
      
      expect(markets.length, greaterThan(5));
      
      for (final market in markets) {
        expect(market.name.isNotEmpty, equals(true));
        expect(market.address.isNotEmpty, equals(true));
        expect(['Atlanta', 'Tucker', 'Dunwoody'], contains(market.city));
        expect(market.state, equals('GA'));
        expect(market.latitude, greaterThan(30.0));
        expect(market.longitude, lessThan(-80.0));
        expect(market.isActive, equals(true));
        expect(market.operatingDays.isNotEmpty, equals(true));
      }

      print('✅ Atlanta markets seed data validation passed');
      print('📊 Found ${markets.length} markets to seed');
      
      for (final market in markets) {
        print('  - ${market.name} (${market.operatingDaysList.join(', ')})');
      }
    });

    test('Market helper methods work correctly', () {
      final market = Market(
        id: 'test-id',
        name: 'Test Market',
        address: '123 Test St',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7490,
        longitude: -84.3880,
        operatingDays: {
          'saturday': '9AM-2PM',
          'sunday': '10AM-3PM'
        },
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(market.fullAddress, equals('123 Test St, Atlanta, GA'));
      expect(market.operatingDaysList, contains('saturday'));
      expect(market.operatingDaysList, contains('sunday'));
      expect(market.operatingDaysList.length, equals(2));

      print('✅ Market helper methods test passed');
    });
  });
}

// Utility function to manually seed markets (run this separately)
Future<void> seedMarketsToFirestore() async {
  try {
    print('🌱 Starting to seed Atlanta markets...');
    
    final markets = AtlantaMarketsSeed.getAtlantaMarkets();
    await MarketService.seedMarkets(markets);
    
    print('✅ Successfully seeded ${markets.length} markets to Firestore');
    
    // Verify by fetching them back
    final atlantaMarkets = await MarketService.getMarketsByCity('Atlanta');
    print('📊 Verified: Found ${atlantaMarkets.length} markets in Atlanta');
    
  } catch (e) {
    print('❌ Error seeding markets: $e');
  }
}

// To run the seeding function:
// 1. Uncomment the line below
// 2. Run: flutter test test/market_seed_test.dart
// 3. Comment it back out

// Note: You'll need to set up Firebase connection properly for this to work
// void main() => seedMarketsToFirestore();