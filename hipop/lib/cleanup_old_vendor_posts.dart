import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// App to clean up old vendor posts not related to Community Farmers Market
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const CleanupOldVendorPostsApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class CleanupOldVendorPostsApp extends StatelessWidget {
  const CleanupOldVendorPostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleanup Old Vendor Posts',
      home: const CleanupOldVendorPostsScreen(),
    );
  }
}

class CleanupOldVendorPostsScreen extends StatefulWidget {
  const CleanupOldVendorPostsScreen({super.key});

  @override
  State<CleanupOldVendorPostsScreen> createState() => _CleanupOldVendorPostsScreenState();
}

class _CleanupOldVendorPostsScreenState extends State<CleanupOldVendorPostsScreen> {
  bool _isLoading = false;
  String _status = 'Ready to cleanup old vendor posts';
  final List<String> _logs = [];
  final List<DocumentSnapshot> _oldPosts = [];
  String? _communityFarmersMarketId;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _scanOldPosts() async {
    setState(() {
      _isLoading = true;
      _status = 'Scanning for old vendor posts...';
      _logs.clear();
      _oldPosts.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Find Community Farmers Market ID
      _addLog('🔍 Finding Community Farmers Market...');
      final marketQuery = await firestore
          .collection('markets')
          .where('name', isEqualTo: 'Community Farmers Market')
          .get();

      if (marketQuery.docs.isEmpty) {
        _addLog('❌ Community Farmers Market not found');
        return;
      }

      _communityFarmersMarketId = marketQuery.docs.first.id;
      _addLog('✅ Found Community Farmers Market ID: $_communityFarmersMarketId');

      // Get all vendor posts
      _addLog('📊 Scanning all vendor posts...');
      final allVendorPostsQuery = await firestore
          .collection('vendor_posts')
          .get();

      _addLog('📝 Found ${allVendorPostsQuery.docs.length} total vendor posts');

      // Separate Community Farmers Market posts from others
      int communityFarmersCount = 0;
      int otherCount = 0;

      for (final doc in allVendorPostsQuery.docs) {
        final data = doc.data();
        final marketId = data['marketId'];
        final vendorName = data['vendorName'] ?? 'Unknown Vendor';

        if (marketId == _communityFarmersMarketId) {
          communityFarmersCount++;
          _addLog('✅ Keep: $vendorName (Community Farmers Market)');
        } else {
          otherCount++;
          _oldPosts.add(doc);
          final location = data['location'] ?? 'Unknown location';
          _addLog('🗑️  Delete: $vendorName at $location (marketId: ${marketId ?? 'null'})');
        }
      }

      _addLog('📋 Summary:');
      _addLog('  • Community Farmers Market posts: $communityFarmersCount (keep)');
      _addLog('  • Other/old posts: $otherCount (delete)');

      setState(() {
        _status = 'Scan complete - ready to delete ${_oldPosts.length} old posts';
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

  Future<void> _deleteOldPosts() async {
    if (_oldPosts.isEmpty) {
      _addLog('⚠️  No old posts to delete');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Deleting old vendor posts...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      int deletedCount = 0;

      _addLog('🗑️  Starting deletion of ${_oldPosts.length} old posts...');

      for (final doc in _oldPosts) {
        final data = doc.data() as Map<String, dynamic>;
        final vendorName = data['vendorName'] ?? 'Unknown Vendor';
        
        await doc.reference.delete();
        deletedCount++;
        _addLog('✅ Deleted: $vendorName (#$deletedCount)');
      }

      _addLog('🎉 Successfully deleted $deletedCount old vendor posts!');
      _addLog('📋 Only Community Farmers Market posts remain in the database');
      
      setState(() {
        _status = 'Cleanup complete - deleted $deletedCount old posts';
        _oldPosts.clear();
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
      _scanOldPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleanup Old Vendor Posts'),
        backgroundColor: Colors.red,
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
                      'Cleanup Old Vendor Posts',
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
                    onPressed: _isLoading ? null : _scanOldPosts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isLoading ? 'Scanning...' : 'Scan for Old Posts',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isLoading || _oldPosts.isEmpty) ? null : _deleteOldPosts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isLoading ? 'Deleting...' : 'Delete ${_oldPosts.length} Old Posts',
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
                    const Text('• Scan all vendor_posts in the database'),
                    const Text('• Keep only Community Farmers Market vendor posts'),
                    const Text('• Delete all other old/unrelated vendor posts'),
                    const Text('• Clean up the database for demo purposes'),
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