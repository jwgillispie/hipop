import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to clean up demo vendor IDs from vendor posts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const CleanupDemoVendorsApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class CleanupDemoVendorsApp extends StatelessWidget {
  const CleanupDemoVendorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleanup Demo Vendor IDs',
      home: const CleanupDemoVendorsScreen(),
    );
  }
}

class CleanupDemoVendorsScreen extends StatefulWidget {
  const CleanupDemoVendorsScreen({super.key});

  @override
  State<CleanupDemoVendorsScreen> createState() => _CleanupDemoVendorsScreenState();
}

class _CleanupDemoVendorsScreenState extends State<CleanupDemoVendorsScreen> {
  bool _isLoading = false;
  String _status = 'Ready to cleanup demo vendor IDs';
  final List<String> _logs = [];
  final List<DocumentSnapshot> _demoPosts = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _scanDemoVendors() async {
    setState(() {
      _isLoading = true;
      _status = 'Scanning for demo vendor IDs...';
      _logs.clear();
      _demoPosts.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Get all vendor posts
      _addLog('📊 Scanning all vendor posts...');
      final allVendorPostsQuery = await firestore
          .collection('vendor_posts')
          .get();

      _addLog('📝 Found ${allVendorPostsQuery.docs.length} total vendor posts');

      // Find posts with demo vendor IDs
      int realVendorCount = 0;
      int demoVendorCount = 0;

      for (final doc in allVendorPostsQuery.docs) {
        final data = doc.data();
        final vendorId = data['vendorId'] as String? ?? '';
        final vendorName = data['vendorName'] ?? 'Unknown Vendor';

        if (vendorId.startsWith('demo_vendor_')) {
          demoVendorCount++;
          _demoPosts.add(doc);
          _addLog('🎭 Demo vendor: $vendorName (ID: $vendorId)');
        } else {
          realVendorCount++;
          _addLog('✅ Real vendor: $vendorName (ID: $vendorId)');
        }
      }

      _addLog('📋 Summary:');
      _addLog('  • Real vendor posts: $realVendorCount (keep)');
      _addLog('  • Demo vendor posts: $demoVendorCount (delete)');

      setState(() {
        _status = 'Scan complete - ready to delete ${_demoPosts.length} demo vendor posts';
      });

    } catch (e) {
      _addLog('❌ Error scanning posts: $e');
      setState(() {
        _status = 'Error occurred during scan';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDemoVendors() async {
    if (_demoPosts.isEmpty) {
      _addLog('⚠️  No demo vendor posts to delete');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Deleting demo vendor posts...';
    });

    try {
      int deletedCount = 0;

      _addLog('🗑️  Starting deletion of ${_demoPosts.length} demo vendor posts...');

      for (final doc in _demoPosts) {
        final data = doc.data() as Map<String, dynamic>;
        final vendorName = data['vendorName'] ?? 'Unknown Vendor';
        final vendorId = data['vendorId'] ?? 'Unknown ID';
        
        await doc.reference.delete();
        deletedCount++;
        _addLog('✅ Deleted: $vendorName (ID: $vendorId) (#$deletedCount)');
      }

      _addLog('🎉 Successfully deleted $deletedCount demo vendor posts!');
      _addLog('📋 Only real vendor posts remain in the database');
      
      setState(() {
        _status = 'Cleanup complete - deleted $deletedCount demo vendor posts';
        _demoPosts.clear();
      });

    } catch (e) {
      _addLog('❌ Error deleting posts: $e');
      setState(() {
        _status = 'Error occurred during deletion';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-scan on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanDemoVendors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleanup Demo Vendor IDs'),
        backgroundColor: Colors.purple,
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
                      'Cleanup Demo Vendor IDs',
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _scanDemoVendors,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isLoading ? 'Scanning...' : 'Scan for Demo Vendors',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isLoading || _demoPosts.isEmpty) ? null : _deleteDemoVendors,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isLoading ? 'Deleting...' : 'Delete ${_demoPosts.length} Demo Vendors',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
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
                    const Text('• Scan all vendor_posts for demo vendor IDs'),
                    const Text('• Find posts with vendorId starting with "demo_vendor_"'),
                    const Text('• Delete all demo vendor posts'),
                    const Text('• Keep only posts with real vendor IDs'),
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