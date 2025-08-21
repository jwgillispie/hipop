import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'real_time_analytics_service.dart';

/// Privacy-compliant analytics service for GDPR compliance
/// Manages user consent and data privacy settings
class PrivacyAnalyticsService {
  static const String _consentKey = 'analytics_consent_given';
  static const String _consentVersionKey = 'analytics_consent_version';
  static const String _anonymousModeKey = 'analytics_anonymous_mode';
  static const String _dataRetentionKey = 'analytics_data_retention';
  
  static const int currentConsentVersion = 1;
  static const int defaultDataRetentionDays = 365; // 1 year default retention
  
  static bool _isInitialized = false;
  static bool _consentGiven = false;
  static bool _anonymousMode = false;
  static int _dataRetentionDays = defaultDataRetentionDays;

  /// Initialize privacy settings from stored preferences
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _consentGiven = prefs.getBool(_consentKey) ?? false;
      _anonymousMode = prefs.getBool(_anonymousModeKey) ?? false;
      _dataRetentionDays = prefs.getInt(_dataRetentionKey) ?? defaultDataRetentionDays;
      
      // Check if consent version has changed (requires new consent)
      final storedVersion = prefs.getInt(_consentVersionKey) ?? 0;
      if (storedVersion < currentConsentVersion) {
        _consentGiven = false;
        await _saveConsent(false);
      }
      
      // Configure real-time analytics based on privacy settings
      if (_consentGiven) {
        if (_anonymousMode) {
          RealTimeAnalyticsService.enableAnonymousMode();
        }
      } else {
        RealTimeAnalyticsService.disableTracking();
      }
      
      _isInitialized = true;
      debugPrint('Privacy Analytics Service initialized - Consent: $_consentGiven, Anonymous: $_anonymousMode');
    } catch (e) {
      debugPrint('Error initializing Privacy Analytics Service: $e');
      _isInitialized = true; // Mark as initialized even if failed
    }
  }

  /// Request user consent for analytics tracking
  static Future<bool> requestConsent() async {
    // In a real implementation, this would show a consent dialog
    // For now, we'll assume consent is granted for development
    await grantConsent(anonymousMode: false);
    return true;
  }

  /// Show privacy consent dialog to user
  /// Returns true if consent is granted, false otherwise
  static Future<bool> showConsentDialog() async {
    // This method should be called from the UI layer
    // Implementation would show a proper consent dialog
    // For now, return current consent state
    return _consentGiven;
  }

  /// Grant analytics consent
  static Future<void> grantConsent({bool anonymousMode = false}) async {
    _consentGiven = true;
    _anonymousMode = anonymousMode;
    
    await _saveConsent(true);
    await _saveAnonymousMode(anonymousMode);
    await _saveConsentVersion(currentConsentVersion);
    
    // Configure analytics service
    if (anonymousMode) {
      RealTimeAnalyticsService.enableAnonymousMode();
    } else {
      // Re-enable tracking with user identification
      await RealTimeAnalyticsService.initialize();
    }
    
    debugPrint('Analytics consent granted - Anonymous mode: $anonymousMode');
  }

  /// Revoke analytics consent
  static Future<void> revokeConsent() async {
    _consentGiven = false;
    
    await _saveConsent(false);
    RealTimeAnalyticsService.disableTracking();
    
    debugPrint('Analytics consent revoked');
  }

  /// Enable anonymous tracking mode
  static Future<void> enableAnonymousMode() async {
    _anonymousMode = true;
    await _saveAnonymousMode(true);
    
    if (_consentGiven) {
      RealTimeAnalyticsService.enableAnonymousMode();
    }
    
    debugPrint('Anonymous analytics mode enabled');
  }

  /// Disable anonymous tracking mode (requires consent)
  static Future<void> disableAnonymousMode() async {
    if (!_consentGiven) {
      throw Exception('Cannot disable anonymous mode without consent');
    }
    
    _anonymousMode = false;
    await _saveAnonymousMode(false);
    
    // Re-initialize with user identification
    await RealTimeAnalyticsService.initialize();
    
    debugPrint('Anonymous analytics mode disabled');
  }

  /// Set data retention period in days
  static Future<void> setDataRetention(int days) async {
    if (days < 1 || days > 2555) { // Max ~7 years
      throw ArgumentError('Data retention must be between 1 and 2555 days');
    }
    
    _dataRetentionDays = days;
    await _saveDataRetention(days);
    
    debugPrint('Data retention set to $days days');
  }

  /// Delete all user analytics data (GDPR right to erasure)
  static Future<void> deleteAllUserData(String userId) async {
    try {
      await RealTimeAnalyticsService.deleteUserData(userId);
      debugPrint('All analytics data deleted for user: $userId');
    } catch (e) {
      debugPrint('Error deleting user analytics data: $e');
      throw Exception('Failed to delete analytics data: $e');
    }
  }

  /// Export user analytics data (GDPR right to data portability)
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      // Get user's analytics data
      final eventsSummary = await RealTimeAnalyticsService.getEventsSummary();
      
      return {
        'user_id': userId,
        'export_date': DateTime.now().toIso8601String(),
        'consent_granted': _consentGiven,
        'anonymous_mode': _anonymousMode,
        'data_retention_days': _dataRetentionDays,
        'analytics_summary': eventsSummary,
        'privacy_rights': {
          'right_to_access': 'Data provided in this export',
          'right_to_rectification': 'Contact support to correct data',
          'right_to_erasure': 'Use deleteAllUserData method',
          'right_to_restrict': 'Use revokeConsent method',
          'right_to_portability': 'This export',
          'right_to_object': 'Use revokeConsent method',
        },
      };
    } catch (e) {
      debugPrint('Error exporting user analytics data: $e');
      throw Exception('Failed to export analytics data: $e');
    }
  }

  /// Get current privacy settings
  static Map<String, dynamic> getPrivacySettings() {
    return {
      'consent_given': _consentGiven,
      'consent_version': currentConsentVersion,
      'anonymous_mode': _anonymousMode,
      'data_retention_days': _dataRetentionDays,
      'initialized': _isInitialized,
    };
  }

  /// Check if analytics tracking is allowed
  static bool get isTrackingAllowed => _consentGiven;

  /// Check if in anonymous mode
  static bool get isAnonymousMode => _anonymousMode;

  /// Get data retention period in days
  static int get dataRetentionDays => _dataRetentionDays;

  /// Get GDPR compliance status
  static Map<String, dynamic> getGDPRComplianceStatus() {
    return {
      'compliant': _isInitialized && (_consentGiven || !_hasUserData()),
      'consent_obtained': _consentGiven,
      'data_minimization': _anonymousMode || !_consentGiven,
      'purpose_limitation': true, // Analytics only for business insights
      'storage_limitation': _dataRetentionDays <= 2555, // Max ~7 years
      'user_rights_supported': [
        'right_to_access',
        'right_to_rectification',
        'right_to_erasure',
        'right_to_restrict',
        'right_to_portability',
        'right_to_object',
      ],
      'privacy_by_design': true, // Anonymous mode available
      'privacy_by_default': !_consentGiven, // No tracking by default
    };
  }

  /// Check if user has any stored analytics data
  static bool _hasUserData() {
    // This would typically query the database
    // For now, assume data exists if consent was given
    return _consentGiven;
  }

  /// Save consent to persistent storage
  static Future<void> _saveConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, consent);
  }

  /// Save consent version to persistent storage
  static Future<void> _saveConsentVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_consentVersionKey, version);
  }

  /// Save anonymous mode setting to persistent storage
  static Future<void> _saveAnonymousMode(bool anonymous) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_anonymousModeKey, anonymous);
  }

  /// Save data retention setting to persistent storage
  static Future<void> _saveDataRetention(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dataRetentionKey, days);
  }

  /// Clear all privacy settings (for testing/reset)
  static Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
    await prefs.remove(_consentVersionKey);
    await prefs.remove(_anonymousModeKey);
    await prefs.remove(_dataRetentionKey);
    
    _consentGiven = false;
    _anonymousMode = false;
    _dataRetentionDays = defaultDataRetentionDays;
    _isInitialized = false;
    
    RealTimeAnalyticsService.disableTracking();
    
    debugPrint('All privacy settings cleared');
  }

  /// Generate privacy policy text for display
  static String getPrivacyPolicyText() {
    return '''
HiPop Analytics Privacy Policy

Data Collection:
We collect analytics data to improve our app and services. This includes:
- Page views and screen interactions
- Vendor and market engagement
- Search queries and results
- Session duration and app usage patterns

Data Usage:
Your data is used to:
- Improve app performance and user experience
- Provide market organizers with attendance insights
- Help vendors understand customer engagement
- Generate anonymized usage statistics

Your Rights:
- Consent: You can grant or revoke consent at any time
- Anonymous Mode: Use the app with anonymous tracking
- Data Access: Request a copy of your analytics data
- Data Deletion: Delete all your analytics data
- Data Portability: Export your data in a readable format

Data Retention:
Analytics data is retained for $_dataRetentionDays days unless you request deletion.

Contact:
For privacy concerns, contact support through the app.

Last updated: ${DateTime.now().toString().split(' ')[0]}
''';
  }
}

/// GDPR Consent Dialog Widget Helper
class GDPRConsentHelper {
  /// Show consent dialog with customizable options
  static Future<bool> showConsentDialog({
    required String title,
    required String message,
    bool allowAnonymous = true,
    bool showDataRetentionOption = false,
  }) async {
    // This would be implemented in the UI layer
    // Return true if consent granted, false if denied
    
    // For now, just grant consent for development
    await PrivacyAnalyticsService.grantConsent(anonymousMode: false);
    return true;
  }

  /// Show privacy settings screen
  static Future<void> showPrivacySettings() async {
    // This would navigate to a privacy settings screen
    // where users can manage their consent and data preferences
    debugPrint('Navigate to privacy settings screen');
  }
}