import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to update vendor post dates to today's date for demo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const UpdateVendorDatesApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class UpdateVendorDatesApp extends StatelessWidget {
  const UpdateVendorDatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Vendor Dates',
      home: const UpdateVendorDatesScreen(),
    );
  }
}

class UpdateVendorDatesScreen extends StatefulWidget {
  const UpdateVendorDatesScreen({super.key});

  @override
  State<UpdateVendorDatesScreen> createState() => _UpdateVendorDatesScreenState();
}

class _UpdateVendorDatesScreenState extends State<UpdateVendorDatesScreen> {
  bool _isLoading = false;
  String _status = 'Ready to update vendor dates to today';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _updateVendorDates() async {
    setState(() {
      _isLoading = true;
      _status = 'Updating vendor dates to today...';
      _logs.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Get today's date and set up market hours (4 PM - 7 PM)
      final today = DateTime.now();
      final startTime = DateTime(today.year, today.month, today.day, 16, 0); // 4 PM today
      final endTime = DateTime(today.year, today.month, today.day, 19, 0);   // 7 PM today
      
      _addLog('📅 Setting dates to: ${today.toString().substring(0, 10)}');
      _addLog('⏰ Market hours: 4:00 PM - 7:00 PM');
      
      // Find all vendor posts for Community Farmers Market
      _addLog('🔍 Finding Community Farmers Market vendor posts...');
      
      // First find the market ID
      final marketQuery = await firestore
          .collection('markets')
          .where('name', isEqualTo: 'Community Farmers Market')
          .get();

      if (marketQuery.docs.isEmpty) {
        _addLog('❌ Community Farmers Market not found');
        setState(() {
          _status = 'Error: Market not found';
          _isLoading = false;
        });
        return;
      }

      final marketId = marketQuery.docs.first.id;
      _addLog('✅ Found market ID: $marketId');

      // Get all vendor posts for this market
      final vendorPostsQuery = await firestore
          .collection('vendor_posts')
          .where('marketId', isEqualTo: marketId)
          .get();

      _addLog('📊 Found ${vendorPostsQuery.docs.length} vendor posts to update');

      // Update each vendor post
      int updatedCount = 0;
      for (final doc in vendorPostsQuery.docs) {
        final data = doc.data();
        final vendorName = data['vendorName'] ?? 'Unknown Vendor';
        
        await doc.reference.update({
          'popUpStartDateTime': Timestamp.fromDate(startTime),
          'popUpEndDateTime': Timestamp.fromDate(endTime),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        updatedCount++;
        _addLog('✅ Updated $vendorName (#$updatedCount)');
      }

      _addLog('🎉 Successfully updated $updatedCount vendor posts!');
      _addLog('📍 All vendors now show as "HAPPENING NOW" from 4-7 PM today');
      
      setState(() {
        _status = 'All vendor dates updated successfully!';
      });

    } catch (e) {
      _addLog('❌ Error updating vendor dates: $e');
      setState(() {
        _status = 'Error updating dates';
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
        title: const Text('Update Vendor Dates'),
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
                      'Update Vendor Dates to Today',
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
              onPressed: _isLoading ? null : _updateVendorDates,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLoading ? 'Updating Dates...' : 'Update Vendor Dates to Today',
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
                    Text('• Update all Community Farmers Market vendors to today ($todayStr)'),
                    const Text('• Set market hours to 4:00 PM - 7:00 PM'),
                    const Text('• Vendors will show as "HAPPENING NOW" during market hours'),
                    const Text('• Perfect for demonstrating the app at the actual market!'),
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