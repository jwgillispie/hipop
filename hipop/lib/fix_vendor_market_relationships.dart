import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to fix vendor-market relationships to match current vendor posts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const FixVendorMarketRelationshipsApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class FixVendorMarketRelationshipsApp extends StatelessWidget {
  const FixVendorMarketRelationshipsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fix Vendor-Market Relationships',
      home: const FixVendorMarketRelationshipsScreen(),
    );
  }
}

class FixVendorMarketRelationshipsScreen extends StatefulWidget {
  const FixVendorMarketRelationshipsScreen({super.key});

  @override
  State<FixVendorMarketRelationshipsScreen> createState() => _FixVendorMarketRelationshipsScreenState();
}

class _FixVendorMarketRelationshipsScreenState extends State<FixVendorMarketRelationshipsScreen> {
  bool _isLoading = false;
  String _status = 'Ready to fix vendor-market relationships';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _fixRelationships() async {
    setState(() {
      _isLoading = true;
      _status = 'Fixing vendor-market relationships...';
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

      // Delete old vendor-market relationships for this market
      _addLog('🗑️  Deleting old vendor-market relationships...');
      final oldRelationshipsQuery = await firestore
          .collection('vendor_markets')
          .where('marketId', isEqualTo: marketId)
          .get();

      _addLog('📊 Found ${oldRelationshipsQuery.docs.length} old relationships to delete');
      
      for (final doc in oldRelationshipsQuery.docs) {
        await doc.reference.delete();
      }
      
      _addLog('✅ Deleted all old relationships');

      // Get current vendor posts for this market
      _addLog('📝 Getting current vendor posts...');
      final vendorPostsQuery = await firestore
          .collection('vendor_posts')
          .where('marketId', isEqualTo: marketId)
          .get();

      _addLog('📊 Found ${vendorPostsQuery.docs.length} vendor posts');

      // Get today's day name
      final today = DateTime.now();
      final weekday = today.weekday;
      final dayName = _getDayName(weekday);
      _addLog('📅 Today is $dayName (weekday $weekday)');

      // Create new vendor-market relationships based on current vendor posts
      int createdCount = 0;
      for (final vendorPostDoc in vendorPostsQuery.docs) {
        final vendorPostData = vendorPostDoc.data();
        final vendorId = vendorPostData['vendorId'];
        final vendorName = vendorPostData['vendorName'];

        // Create new vendor-market relationship
        final relationshipData = {
          'marketId': marketId,
          'vendorId': vendorId,
          'vendorName': vendorName,
          'schedule': [dayName], // Schedule for today's day
          'isActive': true,
          'isApproved': true,
          'boothNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'joinedDate': FieldValue.serverTimestamp(),
        };

        await firestore.collection('vendor_markets').add(relationshipData);
        createdCount++;
        _addLog('✅ Created relationship for $vendorName (ID: $vendorId)');
      }

      _addLog('🎉 Successfully created $createdCount new vendor-market relationships!');
      _addLog('📋 Market detail screen should now show proper vendor names');
      _addLog('🔢 "Active today" should still show $createdCount vendors');
      
      setState(() {
        _status = 'All relationships fixed successfully!';
      });

    } catch (e) {
      _addLog('❌ Error fixing relationships: $e');
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
        title: const Text('Fix Vendor-Market Relationships'),
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
                      'Fix Vendor-Market Relationships',
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
              onPressed: _isLoading ? null : _fixRelationships,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLoading ? 'Fixing Relationships...' : 'Fix Vendor-Market Relationships',
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
                    const Text('• Delete all old vendor-market relationships'),
                    const Text('• Create new relationships matching current vendor posts'),
                    const Text('• Use real vendor names and IDs instead of demo data'),
                    const Text('• Fix "Vendor demo_vendor_X" display issue'),
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