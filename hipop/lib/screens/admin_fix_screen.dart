import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../services/market_service.dart';
import '../models/market.dart';

class AdminFixScreen extends StatefulWidget {
  const AdminFixScreen({super.key});

  @override
  State<AdminFixScreen> createState() => _AdminFixScreenState();
}

class _AdminFixScreenState extends State<AdminFixScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  bool _isLoading = false;
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Fix'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Organizer Association Fix',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will fix market organizer users who are missing market associations. It will:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text('• Check if any markets exist in the database'),
            const Text('• Create a default Atlanta market if none exist'),
            const Text('• Find market organizer users with no managed markets'),
            const Text('• Associate them with the market'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _runFix,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Running Fix...'),
                      ],
                    )
                  : const Text('Run Market Association Fix'),
            ),
            const SizedBox(height: 32),
            
            // Tucker's Market Creation Section
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Demo Market Creation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create Tucker\'s Farmers Market for demo purposes:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text('• Creates a realistic market for Tucker, GA'),
            const Text('• Includes proper address and operating hours'),
            const Text('• Generates shareable vendor application link'),
            const Text('• Perfect for sales demos and testing'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTuckersMarket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Create Tucker\'s Farmers Market'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty) ...[
              const Text(
                'Result:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runFix() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // First, let's diagnose the current state
      await _diagnoseProblem();
      
      // Then run the fixes
      await _userProfileService.fixMarketOrganizerAssociations();
      setState(() {
        _result += '\n\n🔧 FIXING EXISTING VENDORS:\n';
      });
      
      await _userProfileService.fixExistingManagedVendors();
      setState(() {
        _result += '\n\n✅ All fixes completed successfully!\n\nYour market organizer account should now have access to vendor and event management, and your existing JOZO vendor should now be properly associated with Tucker Farmers Market.';
      });
    } catch (e) {
      setState(() {
        _result += '\n\n❌ Error running fix:\n\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _diagnoseProblem() async {
    try {
      final currentUser = await _userProfileService.getCurrentUserProfile();
      final currentUserId = await _userProfileService.getCurrentUserId();
      
      String diagnosisResult = '🔍 DIAGNOSIS:\n\n';
      diagnosisResult += 'Current User ID: $currentUserId\n';
      
      if (currentUser != null) {
        diagnosisResult += 'User Profile Found: ✅\n';
        diagnosisResult += 'User Type: ${currentUser.userType}\n';
        diagnosisResult += 'Managed Markets: ${currentUser.managedMarketIds}\n';
        diagnosisResult += 'Is Market Organizer: ${currentUser.isMarketOrganizer}\n';
      } else {
        diagnosisResult += 'User Profile Found: ❌ MISSING!\n';
        diagnosisResult += 'This is the problem - creating profile now...\n';
        
        // Create the missing profile
        if (currentUserId != null) {
          try {
            await _userProfileService.createMissingOrganizerProfile(currentUserId);
            diagnosisResult += 'Created market organizer profile ✅\n';
          } catch (e) {
            diagnosisResult += 'Failed to create profile: $e\n';
          }
        }
      }
      
      setState(() {
        _result = diagnosisResult;
      });
      
    } catch (e) {
      setState(() {
        _result += 'Diagnosis error: $e\n';
      });
    }
  }

  Future<void> _createTuckersMarket() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Create Tucker's Farmers Market
      final tuckersMarket = Market(
        id: '', // Will be auto-generated
        name: 'Tucker\'s Farmers Market',
        address: '4796 LaVista Rd, Tucker, GA 30084',
        city: 'Tucker',
        state: 'GA',
        latitude: 33.8567,  // Approximate coordinates for Tucker, GA
        longitude: -84.2154,
        description: 'Tucker\'s premier farmers market featuring local vendors, fresh produce, artisanal goods, and community spirit. Operating since 2010, we support local farmers and makers while bringing the community together every weekend.',
        operatingDays: const {
          'saturday': '8:00 AM - 1:00 PM',
          'sunday': '10:00 AM - 2:00 PM',
        },
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Add to database
      final marketId = await MarketService.createMarket(tuckersMarket);
      
      String resultText = '🌟 TUCKER\'S FARMERS MARKET CREATED!\n\n';
      resultText += '📍 Market ID: $marketId\n';
      resultText += '📋 Name: ${tuckersMarket.name}\n';
      resultText += '🏠 Address: ${tuckersMarket.address}\n';
      resultText += '⏰ Hours: Saturday 8AM-1PM, Sunday 10AM-2PM\n\n';
      
      resultText += '🔗 SHAREABLE LINKS:\n';
      resultText += '• Production: https://hipop.app/apply/$marketId\n';
      resultText += '• Test: hipop://apply/$marketId\n\n';
      
      resultText += '🎯 DEMO READY!\n';
      resultText += 'Use this market for your Tucker\'s Farmers Market demo.\n';
      resultText += 'Show them the vendor application form and management system.\n';
      resultText += 'Market organizers can claim this market by signing up.\n\n';
      
      resultText += '📱 NEXT STEPS:\n';
      resultText += '1. Go to Vendor Applications screen\n';
      resultText += '2. Click "Share Application Link"\n';
      resultText += '3. Copy and test the application form\n';
      resultText += '4. Show Tucker\'s how vendors can apply easily!';
      
      setState(() {
        _result = resultText;
      });

    } catch (e) {
      setState(() {
        _result = '❌ Error creating Tucker\'s Farmers Market:\n\n$e\n\n';
        _result += '🔧 Alternative: Add this data manually:\n';
        _result += '1. Sign in as a market organizer\n';
        _result += '2. Go to Market Management\n';
        _result += '3. Create new market with Tucker\'s details\n';
        _result += '4. Use the vendor application system to demo';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}