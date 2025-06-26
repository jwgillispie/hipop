import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';

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
}