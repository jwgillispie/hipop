import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to add vendor posts for Community Farmers Market (June 25th event)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const AddMarketVendorsApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class AddMarketVendorsApp extends StatelessWidget {
  const AddMarketVendorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Market Vendors',
      home: const AddMarketVendorsScreen(),
    );
  }
}

class AddMarketVendorsScreen extends StatefulWidget {
  const AddMarketVendorsScreen({super.key});

  @override
  State<AddMarketVendorsScreen> createState() => _AddMarketVendorsScreenState();
}

class _AddMarketVendorsScreenState extends State<AddMarketVendorsScreen> {
  bool _isLoading = false;
  String _status = 'Ready to add Community Farmers Market vendors';
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

  Future<void> _addMarketVendors() async {
    setState(() {
      _isLoading = true;
      _status = 'Adding Community Farmers Market vendors...';
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
      
      // June 25th, 2025 - 4pm to 7pm (today's date from the post)
      final eventDate = DateTime(2025, 6, 25);
      final startTime = DateTime(2025, 6, 25, 16, 0); // 4 PM
      final endTime = DateTime(2025, 6, 25, 19, 0);   // 7 PM

      // Create vendor posts based on the actual market post
      final vendors = [
        {
          'vendorName': 'Mealor Family Gardens',
          'description': 'Fresh tomatoes and summer favorites! Family-owned farm bringing you the best seasonal produce.',
          'instagramHandle': null,
          'category': 'Farm Fresh Produce',
        },
        {
          'vendorName': 'Hartnett Farm ATL',
          'description': 'Local Atlanta farm specializing in seasonal vegetables and fresh herbs.',
          'instagramHandle': 'hartnettfarmatl',
          'category': 'Farm Fresh Produce',
        },
        {
          'vendorName': 'Georgia Peach Truck',
          'description': 'Georgia\'s finest peaches and seasonal fruits, bringing farm-fresh flavor to your table.',
          'instagramHandle': 'georgiapeachtruck',
          'category': 'Farm Fresh Produce',
        },
        {
          'vendorName': 'Georgia Proud Provisions',
          'description': 'Locally sourced provisions and specialty items from Georgia farmers and artisans.',
          'instagramHandle': 'georgiaproudprovisions',
          'category': 'Local Provisions',
        },
        {
          'vendorName': 'Scratch\'d',
          'description': 'Handcrafted baked goods made from scratch with love and quality ingredients.',
          'instagramHandle': '_scratchd',
          'category': 'Baked Goods',
        },
        {
          'vendorName': 'Le Pain Sourdough',
          'description': 'Artisanal sourdough breads and pastries, naturally fermented for exceptional flavor.',
          'instagramHandle': 'le_pain_sourdough',
          'category': 'Baked Goods',
        },
        {
          'vendorName': 'Layon Granola',
          'description': 'Small-batch granola made with premium ingredients and unique flavor combinations.',
          'instagramHandle': 'layon_granola',
          'category': 'Specialty Foods',
        },
        {
          'vendorName': 'Black River Juice Bar',
          'description': 'Fresh cold-pressed juices, smoothies, and healthy beverages made to order.',
          'instagramHandle': 'blackriverjuicebar',
          'category': 'Beverages',
        },
        {
          'vendorName': 'Molino Tortillas ATL',
          'description': 'Authentic handmade tortillas and Mexican specialties, made fresh daily.',
          'instagramHandle': 'molinotortillasatl',
          'category': 'Specialty Foods',
        },
        {
          'vendorName': 'La Montagne des Saveurs',
          'description': 'French-inspired artisanal foods and delicacies, bringing European flavors to Atlanta.',
          'instagramHandle': 'lamontagnedessaveurs',
          'category': 'Specialty Foods',
        },
      ];

      _addLog('📝 Adding ${vendors.length} vendor posts...');

      for (int i = 0; i < vendors.length; i++) {
        final vendor = vendors[i];
        
        final vendorPostData = {
          'vendorName': vendor['vendorName'],
          'description': vendor['description'],
          'location': '308 Clairemont Ave, Decatur, GA',
          'latitude': 33.7748,
          'longitude': -84.2963,
          'popUpStartDateTime': Timestamp.fromDate(startTime),
          'popUpEndDateTime': Timestamp.fromDate(endTime),
          'instagramHandle': vendor['instagramHandle'],
          'marketId': _marketId, // Associated with Community Farmers Market
          'vendorId': 'demo_vendor_${i + 1}', // Demo vendor IDs
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'category': vendor['category'],
        };

        final docRef = await firestore.collection('vendor_posts').add(vendorPostData);
        _addLog('✅ Added ${vendor['vendorName']} (${docRef.id})');
      }

      _addLog('🎉 Successfully added all ${vendors.length} vendors!');
      _addLog('📅 Event: Wednesday, June 25th, 4-7 PM');
      _addLog('📍 Location: Community Farmers Market @ First Baptist Church of Decatur');
      
      setState(() {
        _status = 'All vendors added successfully!';
      });

    } catch (e) {
      _addLog('❌ Error adding vendors: $e');
      setState(() {
        _status = 'Error adding vendors';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Market Vendors'),
        backgroundColor: Colors.orange,
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
                      'Community Farmers Market Vendors',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
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
              onPressed: _isLoading ? null : _addMarketVendors,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLoading ? 'Adding Vendors...' : 'Add Market Vendors (June 25th)',
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
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'June 25th Market Vendors:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('🌱 Farms: Mealor Family, Hartnett Farm, Georgia Peach Truck'),
                    Text('🍞 Baked Goods: Scratch\'d, Le Pain Sourdough'),
                    Text('🥤 Beverages: Black River Juice Bar'),
                    Text('🌮 Specialty: Molino Tortillas, La Montagne des Saveurs'),
                    Text('📍 Location: 308 Clairemont Ave, Decatur'),
                    Text('⏰ Time: Wednesday 4-7 PM'),
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