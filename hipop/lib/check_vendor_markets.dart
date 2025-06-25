import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to check vendor-market relationships
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const CheckVendorMarketsApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class CheckVendorMarketsApp extends StatelessWidget {
  const CheckVendorMarketsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check Vendor Markets',
      home: const CheckVendorMarketsScreen(),
    );
  }
}

class CheckVendorMarketsScreen extends StatefulWidget {
  const CheckVendorMarketsScreen({super.key});

  @override
  State<CheckVendorMarketsScreen> createState() => _CheckVendorMarketsScreenState();
}

class _CheckVendorMarketsScreenState extends State<CheckVendorMarketsScreen> {
  bool _isLoading = false;
  String _status = 'Ready to check vendor-market relationships';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _checkVendorMarkets() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking vendor-market relationships...';
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

      // Check vendor_posts for this market
      _addLog('📊 Checking vendor_posts collection...');
      final vendorPostsQuery = await firestore
          .collection('vendor_posts')
          .where('marketId', isEqualTo: marketId)
          .get();

      _addLog('📝 Found ${vendorPostsQuery.docs.length} vendor posts');
      for (final doc in vendorPostsQuery.docs) {
        final data = doc.data();
        final vendorName = data['vendorName'] ?? 'Unknown';
        final startTime = (data['popUpStartDateTime'] as Timestamp).toDate();
        final endTime = (data['popUpEndDateTime'] as Timestamp).toDate();
        _addLog('  - $vendorName: ${startTime.toString().substring(0, 16)} to ${endTime.toString().substring(11, 16)}');
      }

      // Check vendor_markets relationships
      _addLog('🔗 Checking vendor_markets collection...');
      final vendorMarketsQuery = await firestore
          .collection('vendor_markets')
          .where('marketId', isEqualTo: marketId)
          .get();

      _addLog('📝 Found ${vendorMarketsQuery.docs.length} vendor-market relationships');
      
      if (vendorMarketsQuery.docs.isEmpty) {
        _addLog('⚠️  NO VENDOR-MARKET RELATIONSHIPS FOUND!');
        _addLog('💡 This is why "active today" shows 0');
        _addLog('📋 MarketService.getActiveVendorsForMarketToday() queries vendor_markets collection');
        _addLog('🔧 Need to create vendor_markets entries for each vendor');
      } else {
        for (final doc in vendorMarketsQuery.docs) {
          final data = doc.data();
          final vendorId = data['vendorId'] ?? 'Unknown';
          final schedule = List<String>.from(data['schedule'] ?? []);
          final isActive = data['isActive'] ?? false;
          final isApproved = data['isApproved'] ?? false;
          _addLog('  - Vendor $vendorId: schedule=$schedule, active=$isActive, approved=$isApproved');
        }
      }

      // Check what day today is
      final today = DateTime.now();
      final weekday = today.weekday;
      final dayName = _getDayName(weekday);
      _addLog('📅 Today is $dayName (weekday $weekday)');

      setState(() {
        _status = 'Analysis complete';
      });

    } catch (e) {
      _addLog('❌ Error checking relationships: $e');
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
        title: const Text('Check Vendor Markets'),
        backgroundColor: Colors.blue,
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
                      'Vendor-Market Relationship Analysis',
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
              onPressed: _isLoading ? null : _checkVendorMarkets,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLoading ? 'Checking...' : 'Check Vendor-Market Relationships',
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
                        'Analysis Log',
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
          ],
        ),
      ),
    );
  }
}