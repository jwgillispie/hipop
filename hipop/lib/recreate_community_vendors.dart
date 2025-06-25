import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to recreate Community Farmers Market vendor posts for today
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const RecreateVendorsApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class RecreateVendorsApp extends StatelessWidget {
  const RecreateVendorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recreate Community Vendors',
      home: const RecreateVendorsScreen(),
    );
  }
}

class RecreateVendorsScreen extends StatefulWidget {
  const RecreateVendorsScreen({super.key});

  @override
  State<RecreateVendorsScreen> createState() => _RecreateVendorsScreenState();
}

class _RecreateVendorsScreenState extends State<RecreateVendorsScreen> {
  bool _isLoading = false;
  String _status = 'Ready to recreate Community Farmers Market vendors';
  final List<String> _logs = [];
  String? _marketId;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _findMarketId() async {
    _addLog('🔍 Finding Community Farmers Market ID...');
    
    final firestore = FirebaseFirestore.instance;
    final marketQuery = await firestore
        .collection('markets')
        .where('name', isEqualTo: 'Community Farmers Market')
        .get();

    if (marketQuery.docs.isEmpty) {
      _addLog('❌ Community Farmers Market not found in database');
      return;
    }

    _marketId = marketQuery.docs.first.id;
    _addLog('✅ Found market ID: $_marketId');
  }

  Future<void> _recreateVendors() async {
    setState(() {
      _isLoading = true;
      _status = 'Recreating Community Farmers Market vendors...';
      _logs.clear();
    });

    try {
      await _findMarketId();
      
      if (_marketId == null) {
        setState(() {
          _status = 'Error: Market not found';
          _isLoading = false;
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      
      // Today's date - happening now (4pm to 7pm)
      final today = DateTime.now();
      final startTime = DateTime(today.year, today.month, today.day, 16, 0); // 4 PM today
      final endTime = DateTime(today.year, today.month, today.day, 19, 0);   // 7 PM today

      // Real vendor IDs (using actual vendor names as IDs for authenticity)
      final vendors = [
        {
          'vendorId': 'mealor_family_gardens',
          'vendorName': 'Mealor Family Gardens',
          'description': 'Fresh tomatoes and summer favorites! Family-owned farm bringing you the best seasonal produce.',
          'instagramHandle': null,
          'category': 'Farm Fresh Produce',
        },
        {
          'vendorId': 'hartnett_farm_atl',
          'vendorName': 'Hartnett Farm ATL',
          'description': 'Local Atlanta farm specializing in seasonal vegetables and fresh herbs.',
          'instagramHandle': 'hartnettfarmatl',
          'category': 'Farm Fresh Produce',
        },
        {
          'vendorId': 'georgia_peach_truck',
          'vendorName': 'Georgia Peach Truck',
          'description': 'Georgia\'s finest peaches and seasonal fruits, bringing farm-fresh flavor to your table.',
          'instagramHandle': 'georgiapeachtruck',
          'category': 'Farm Fresh Produce',
        },
        {
          'vendorId': 'georgia_proud_provisions',
          'vendorName': 'Georgia Proud Provisions',
          'description': 'Locally sourced provisions and specialty items from Georgia farmers and artisans.',
          'instagramHandle': 'georgiaproudprovisions',
          'category': 'Local Provisions',
        },
        {
          'vendorId': 'scratchd_bakery',
          'vendorName': 'Scratch\'d',
          'description': 'Handcrafted baked goods made from scratch with love and quality ingredients.',
          'instagramHandle': '_scratchd',
          'category': 'Baked Goods',
        },
        {
          'vendorId': 'le_pain_sourdough',
          'vendorName': 'Le Pain Sourdough',
          'description': 'Artisanal sourdough breads and pastries, naturally fermented for exceptional flavor.',
          'instagramHandle': 'le_pain_sourdough',
          'category': 'Baked Goods',
        },
        {
          'vendorId': 'layon_granola',
          'vendorName': 'Layon Granola',
          'description': 'Small-batch granola made with premium ingredients and unique flavor combinations.',
          'instagramHandle': 'layon_granola',
          'category': 'Specialty Foods',
        },
        {
          'vendorId': 'black_river_juice_bar',
          'vendorName': 'Black River Juice Bar',
          'description': 'Fresh cold-pressed juices, smoothies, and healthy beverages made to order.',
          'instagramHandle': 'blackriverjuicebar',
          'category': 'Beverages',
        },
        {
          'vendorId': 'molino_tortillas_atl',
          'vendorName': 'Molino Tortillas ATL',
          'description': 'Authentic handmade tortillas and Mexican specialties, made fresh daily.',
          'instagramHandle': 'molinotortillasatl',
          'category': 'Specialty Foods',
        },
        {
          'vendorId': 'la_montagne_des_saveurs',
          'vendorName': 'La Montagne des Saveurs',
          'description': 'French-inspired artisanal foods and delicacies, bringing European flavors to Atlanta.',
          'instagramHandle': 'lamontagnedessaveurs',
          'category': 'Specialty Foods',
        },
      ];

      _addLog('📝 Adding ${vendors.length} vendor posts for today...');
      _addLog('📅 Date: ${today.toString().substring(0, 10)} (Today)');
      _addLog('⏰ Hours: 4:00 PM - 7:00 PM');

      for (int i = 0; i < vendors.length; i++) {
        final vendor = vendors[i];
        
        final vendorPostData = {
          'vendorId': vendor['vendorId'],
          'vendorName': vendor['vendorName'],
          'description': vendor['description'],
          'location': '308 Clairemont Ave, Decatur, GA',
          'latitude': 33.7748,
          'longitude': -84.2963,
          'popUpStartDateTime': Timestamp.fromDate(startTime),
          'popUpEndDateTime': Timestamp.fromDate(endTime),
          'instagramHandle': vendor['instagramHandle'],
          'marketId': _marketId,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'category': vendor['category'],
        };

        final docRef = await firestore.collection('vendor_posts').add(vendorPostData);
        _addLog('✅ Added ${vendor['vendorName']} (${docRef.id})');
      }

      _addLog('🎉 Successfully recreated all ${vendors.length} vendors!');
      _addLog('📍 Location: Community Farmers Market @ First Baptist Church of Decatur');
      _addLog('🕐 Time: Today 4-7 PM (currently happening!)');
      
      setState(() {
        _status = 'All vendors recreated successfully!';
      });

    } catch (e) {
      _addLog('❌ Error recreating vendors: $e');
      setState(() {
        _status = 'Error recreating vendors';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = '${now.day}/${now.month}/${now.year}';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recreate Community Vendors'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recreate Community Farmers Market Vendors',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Target Date: $todayStr (Today)'),
                    const SizedBox(height: 4),
                    Text(_status),
                    if (_isLoading) 
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _recreateVendors,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLoading ? 'Creating Vendors...' : 'Recreate 10 Community Farmers Market Vendors',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Log',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                _logs[index],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendors to recreate:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('🌱 Farms: Mealor Family, Hartnett Farm, Georgia Peach Truck'),
                    Text('🍞 Baked Goods: Scratch\'d, Le Pain Sourdough'),
                    Text('🥤 Beverages: Black River Juice Bar'),
                    Text('🌮 Specialty: Molino Tortillas, La Montagne des Saveurs'),
                    Text('📍 Location: 308 Clairemont Ave, Decatur'),
                    Text('⏰ Time: Today 4-7 PM (currently happening!)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}