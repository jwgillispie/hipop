import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/models/market.dart';
import '../lib/services/market_service.dart';

// Test to add Druid Hills Farmers Market to database
void main() {
  group('Add Druid Hills Market', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp();
    });

    test('Add Druid Hills Farmers Market to database', () async {
      final now = DateTime.now();
      
      final druidHillsMarket = Market(
        id: '', // Will be set by Firestore
        name: 'Druid Hills Farmers Market',
        address: '2166 Briarcliff Rd NE',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7981,
        longitude: -84.3212,
        operatingDays: {
          'saturday': '9AM-1PM',
        },
        description: 'Community farmers market in the historic Druid Hills neighborhood featuring local vendors, fresh produce, and artisanal goods.',
        isActive: true,
        createdAt: now,
      );

      // Check if market already exists
      final existingMarkets = await FirebaseFirestore.instance
          .collection('markets')
          .where('name', isEqualTo: 'Druid Hills Farmers Market')
          .get();

      if (existingMarkets.docs.isNotEmpty) {
        print('✅ Druid Hills Farmers Market already exists');
        return;
      }

      // Add the market
      final docRef = await FirebaseFirestore.instance
          .collection('markets')
          .add(druidHillsMarket.toFirestore());

      print('✅ Successfully added Druid Hills Farmers Market with ID: ${docRef.id}');

      // Verify it was added
      final doc = await docRef.get();
      expect(doc.exists, true);
      
      final data = doc.data()!;
      expect(data['name'], 'Druid Hills Farmers Market');
      expect(data['city'], 'Atlanta');
      expect(data['operatingDays']['saturday'], '9AM-1PM');
      
      print('✅ Verified: Market successfully added to database');
    });
  });
}