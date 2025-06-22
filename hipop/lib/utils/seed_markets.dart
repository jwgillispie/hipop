import 'package:firebase_core/firebase_core.dart';
import '../services/market_service.dart';
import '../data/atlanta_markets_seed.dart';

// Simple utility to seed markets data to Firestore
// Run this once to populate your database with sample Atlanta markets

class SeedMarkets {
  static Future<void> seedAtlantaMarkets() async {
    try {
      print('🚀 Starting to seed Atlanta markets to Firestore...');
      
      // Get the seed data
      final markets = AtlantaMarketsSeed.getAtlantaMarkets();
      print('📋 Found ${markets.length} markets to seed');
      
      // Seed them to Firestore
      await MarketService.seedMarkets(markets);
      
      print('✅ Successfully seeded ${markets.length} markets!');
      
      // Verify by fetching them back
      print('🔍 Verifying seeded data...');
      
      final atlantaMarkets = await MarketService.getMarketsByCity('Atlanta');
      final tuckerMarkets = await MarketService.getMarketsByCity('Tucker');  
      final dunwoodyMarkets = await MarketService.getMarketsByCity('Dunwoody');
      
      print('📊 Verification Results:');
      print('  - Atlanta: ${atlantaMarkets.length} markets');
      print('  - Tucker: ${tuckerMarkets.length} markets');
      print('  - Dunwoody: ${dunwoodyMarkets.length} markets');
      print('  - Total: ${atlantaMarkets.length + tuckerMarkets.length + dunwoodyMarkets.length} markets');
      
      print('\n📍 Markets by city:');
      print('Atlanta:');
      for (final market in atlantaMarkets) {
        print('  - ${market.name} (${market.operatingDaysList.join(', ')})');
      }
      
      if (tuckerMarkets.isNotEmpty) {
        print('Tucker:');
        for (final market in tuckerMarkets) {
          print('  - ${market.name} (${market.operatingDaysList.join(', ')})');
        }
      }
      
      if (dunwoodyMarkets.isNotEmpty) {
        print('Dunwoody:');
        for (final market in dunwoodyMarkets) {
          print('  - ${market.name} (${market.operatingDaysList.join(', ')})');
        }
      }
      
      print('\n🎉 Market seeding completed successfully!');
      
    } catch (e) {
      print('❌ Error seeding markets: $e');
      rethrow;
    }
  }
  
  static Future<void> checkExistingMarkets() async {
    try {
      print('🔍 Checking existing markets in database...');
      
      final allMarkets = await MarketService.getAllActiveMarkets();
      
      if (allMarkets.isEmpty) {
        print('📭 No markets found in database. Ready to seed!');
      } else {
        print('📊 Found ${allMarkets.length} existing markets:');
        for (final market in allMarkets) {
          print('  - ${market.name} (${market.city})');
        }
        print('\n⚠️  Markets already exist. Do you want to seed anyway?');
      }
      
    } catch (e) {
      print('❌ Error checking existing markets: $e');
    }
  }
}