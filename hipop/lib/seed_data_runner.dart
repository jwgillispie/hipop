import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'utils/seed_markets.dart';

// Temporary app to seed market data
// Run with: flutter run lib/seed_data_runner.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const SeedDataApp());
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

class SeedDataApp extends StatelessWidget {
  const SeedDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HiPop Data Seeder',
      home: const SeedDataScreen(),
    );
  }
}

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  bool _isLoading = false;
  String _status = 'Ready to seed Atlanta markets data';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    print(message); // Also print to console
  }

  Future<void> _checkExistingData() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking existing markets...';
      _logs.clear();
    });

    try {
      await SeedMarkets.checkExistingMarkets();
      setState(() {
        _status = 'Check complete - see logs';
      });
    } catch (e) {
      _addLog('❌ Error checking existing data: $e');
      setState(() {
        _status = 'Error checking data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seedMarkets() async {
    setState(() {
      _isLoading = true;
      _status = 'Seeding Atlanta markets...';
      _logs.clear();
    });

    try {
      await SeedMarkets.seedAtlantaMarkets();
      _addLog('✅ Successfully seeded all markets!');
      setState(() {
        _status = 'Seeding complete!';
      });
    } catch (e) {
      _addLog('❌ Error seeding markets: $e');
      setState(() {
        _status = 'Seeding failed';
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
        title: const Text('HiPop Data Seeder'),
        backgroundColor: Colors.orange,
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
                      'Market Data Seeding',
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
                    onPressed: _isLoading ? null : _checkExistingData,
                    child: const Text('Check Existing Data'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _seedMarkets,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Seed Markets'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logs',
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
                      'What this will seed:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• 5 Atlanta markets'),
                    Text('• 1 Tucker market'),
                    Text('• 1 Dunwoody market'),
                    Text('• Operating schedules for each market'),
                    Text('• Location coordinates and addresses'),
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