import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to create vendor-market relationships for Community Farmers Market
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const CreateVendorMarketRelationshipsApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class CreateVendorMarketRelationshipsApp extends StatelessWidget {
  const CreateVendorMarketRelationshipsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Vendor-Market Relationships',
      home: const CreateVendorMarketRelationshipsScreen(),
    );
  }
}

class CreateVendorMarketRelationshipsScreen extends StatefulWidget {
  const CreateVendorMarketRelationshipsScreen({super.key});

  @override
  State<CreateVendorMarketRelationshipsScreen> createState() => _CreateVendorMarketRelationshipsScreenState();
}

class _CreateVendorMarketRelationshipsScreenState extends State<CreateVendorMarketRelationshipsScreen> {
  bool _isLoading = false;
  String _status = 'Ready to create vendor-market relationships';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _createRelationships() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating vendor-market relationships...';
      _logs.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Find Community Farmers Market
      _addLog('🔍 Finding Community Farmers Market...');
      final marketQuery = await firestore
          .collection('markets')
          .where('name', isEqualTo: 'Community Farmers Market')
          .get();

      if (marketQuery.docs.isEmpty) {
        _addLog('❌ Community Farmers Market not found');
        return;
      }

      final marketId = marketQuery.docs.first.id;
      _addLog('✅ Found market ID: $marketId');

      // Get all vendor posts for this market
      _addLog('📊 Getting vendor posts for this market...');
      final vendorPostsQuery = await firestore
          .collection('vendor_posts')
          .where('marketId', isEqualTo: marketId)
          .get();

      _addLog('📝 Found ${vendorPostsQuery.docs.length} vendor posts');

      // Check what day today is
      final today = DateTime.now();
      final weekday = today.weekday;
      final dayName = _getDayName(weekday);
      _addLog('📅 Today is $dayName (weekday $weekday)');

      // Create vendor-market relationships for each vendor
      int createdCount = 0;
      for (final vendorPostDoc in vendorPostsQuery.docs) {
        final vendorPostData = vendorPostDoc.data();
        final vendorId = vendorPostData['vendorId'];
        final vendorName = vendorPostData['vendorName'];

        // Check if relationship already exists
        final existingQuery = await firestore
            .collection('vendor_markets')
            .where('marketId', isEqualTo: marketId)
            .where('vendorId', isEqualTo: vendorId)
            .get();

        if (existingQuery.docs.isNotEmpty) {
          _addLog('⚠️  Relationship already exists for $vendorName');
          continue;
        }

        // Create vendor-market relationship
        final relationshipData = {
          'marketId': marketId,
          'vendorId': vendorId,
          'vendorName': vendorName,
          'schedule': [dayName], // Schedule for today's day
          'isActive': true,
          'isApproved': true, // Auto-approve for demo
          'boothNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await firestore.collection('vendor_markets').add(relationshipData);
        createdCount++;
        _addLog('✅ Created relationship for $vendorName (scheduled for $dayName)');
      }

      _addLog('🎉 Successfully created $createdCount vendor-market relationships!');
      _addLog('📋 MarketService.getActiveVendorsForMarketToday() should now find these vendors');
      _addLog('🔢 "Active today" should now show $createdCount instead of 0');
      
      setState(() {
        _status = 'All relationships created successfully!';
      });

    } catch (e) {
      _addLog('❌ Error creating relationships: $e');
      setState(() {
        _status = 'Error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getDayName(int weekday) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Vendor-Market Relationships'),
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
                      'Create Vendor-Market Relationships',
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
              onPressed: _isLoading ? null : _createRelationships,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLoading ? 'Creating Relationships...' : 'Create Vendor-Market Relationships',
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
                      'What this will do:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• Create vendor_markets entries for all 10 Community Farmers Market vendors'),
                    Text('• Set schedule to today (${_getDayName(DateTime.now().weekday)})'),
                    const Text('• Mark all as active and approved'),
                    const Text('• Fix "active today" count to show 10 instead of 0'),
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