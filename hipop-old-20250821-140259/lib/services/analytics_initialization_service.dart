import 'package:flutter/foundation.dart';
import '../blocs/auth/auth_state.dart';
import '../models/analytics_event.dart';
import 'real_time_analytics_service.dart';
import 'privacy_analytics_service.dart';

/// Service to initialize and manage the complete analytics system
/// Integrates real-time analytics with privacy compliance
class AnalyticsInitializationService {
  static bool _isInitialized = false;
  static String? _currentUserId;
  static String _currentUserType = 'anonymous';

  /// Initialize the complete analytics system
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('Initializing HiPop Analytics System...');
      
      // Step 1: Initialize privacy service first
      await PrivacyAnalyticsService.initialize();
      
      // Step 2: Check if tracking is allowed
      if (!PrivacyAnalyticsService.isTrackingAllowed) {
        debugPrint('Analytics tracking not allowed - privacy consent required');
        _isInitialized = true;
        return;
      }
      
      // Step 3: Initialize real-time analytics
      await RealTimeAnalyticsService.initialize(
        userId: _currentUserId,
        userType: _currentUserType,
        requestConsent: false, // Already handled by privacy service
      );
      
      _isInitialized = true;
      debugPrint('HiPop Analytics System initialized successfully');
      
      // Step 4: Log initialization event
      await RealTimeAnalyticsService.trackEvent(
        AnalyticsEventType.sessionStart,
        {
          'analytics_version': '1.0.0',
          'privacy_mode': PrivacyAnalyticsService.isAnonymousMode ? 'anonymous' : 'identified',
          'consent_given': PrivacyAnalyticsService.isTrackingAllowed,
          'initialization_time': DateTime.now().toIso8601String(),
        },
        screenName: 'app_initialization',
      );
      
    } catch (e) {
      debugPrint('Error initializing analytics system: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Update user context when authentication state changes
  static Future<void> updateUserContext(AuthState authState) async {
    try {
      String? newUserId;
      String newUserType = 'anonymous';
      
      if (authState is Authenticated) {
        newUserId = authState.user.uid;
        newUserType = authState.userType;
      }
      
      // Only update if context has changed
      if (newUserId != _currentUserId || newUserType != _currentUserType) {
        final previousUserId = _currentUserId;
        final previousUserType = _currentUserType;
        
        _currentUserId = newUserId;
        _currentUserType = newUserType;
        
        // End previous session if exists
        if (_isInitialized && PrivacyAnalyticsService.isTrackingAllowed) {
          await RealTimeAnalyticsService.endSession();
        }
        
        // Re-initialize with new user context
        if (PrivacyAnalyticsService.isTrackingAllowed) {
          await RealTimeAnalyticsService.initialize(
            userId: newUserId,
            userType: newUserType,
            requestConsent: false,
          );
          
          // Track user context change
          await RealTimeAnalyticsService.trackEvent(
            AnalyticsEventType.sessionStart,
            {
              'user_context_change': true,
              'previous_user_id': previousUserId,
              'previous_user_type': previousUserType,
              'new_user_id': newUserId,
              'new_user_type': newUserType,
              'context_change_time': DateTime.now().toIso8601String(),
            },
            screenName: 'user_context_update',
          );
        }
        
        debugPrint('Analytics user context updated: $previousUserType -> $newUserType');
      }
    } catch (e) {
      debugPrint('Error updating analytics user context: $e');
    }
  }

  /// Request analytics consent from user
  static Future<bool> requestUserConsent() async {
    try {
      final consentGranted = await PrivacyAnalyticsService.requestConsent();
      
      if (consentGranted && !_isInitialized) {
        await initialize();
      }
      
      return consentGranted;
    } catch (e) {
      debugPrint('Error requesting analytics consent: $e');
      return false;
    }
  }

  /// Handle app lifecycle events for analytics
  static Future<void> handleAppLifecycle(String lifecycle) async {
    if (!_isInitialized || !PrivacyAnalyticsService.isTrackingAllowed) {
      return;
    }
    
    try {
      switch (lifecycle.toLowerCase()) {
        case 'resumed':
          await RealTimeAnalyticsService.trackEvent(
            AnalyticsEventType.appForeground,
            {
              'lifecycle_event': 'resumed',
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
          // Sync offline events if any
          await RealTimeAnalyticsService.syncOfflineEvents();
          break;
          
        case 'paused':
          await RealTimeAnalyticsService.trackEvent(
            AnalyticsEventType.appBackground,
            {
              'lifecycle_event': 'paused',
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
          break;
          
        case 'detached':
          await RealTimeAnalyticsService.endSession();
          break;
      }
    } catch (e) {
      debugPrint('Error handling app lifecycle event ($lifecycle): $e');
    }
  }

  /// Handle network connectivity changes
  static void handleNetworkChange(bool isOnline) {
    if (!_isInitialized || !PrivacyAnalyticsService.isTrackingAllowed) {
      return;
    }
    
    try {
      RealTimeAnalyticsService.setNetworkStatus(isOnline);
      
      if (isOnline) {
        // Track connectivity restored
        RealTimeAnalyticsService.trackEvent(
          AnalyticsEventType.networkError, // Using this for connectivity events
          {
            'network_event': 'connectivity_restored',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      debugPrint('Error handling network change: $e');
    }
  }

  /// Get analytics system status for debugging
  static Map<String, dynamic> getSystemStatus() {
    return {
      'initialized': _isInitialized,
      'current_user_id': _currentUserId,
      'current_user_type': _currentUserType,
      'privacy_settings': PrivacyAnalyticsService.getPrivacySettings(),
      'gdpr_compliance': PrivacyAnalyticsService.getGDPRComplianceStatus(),
    };
  }

  /// Shutdown analytics system gracefully
  static Future<void> shutdown() async {
    try {
      if (_isInitialized && PrivacyAnalyticsService.isTrackingAllowed) {
        // Track shutdown event
        await RealTimeAnalyticsService.trackEvent(
          AnalyticsEventType.sessionEnd,
          {
            'shutdown_reason': 'app_terminated',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        
        // End current session
        await RealTimeAnalyticsService.endSession();
        
        // Sync any pending offline events
        await RealTimeAnalyticsService.syncOfflineEvents();
      }
      
      _isInitialized = false;
      debugPrint('Analytics system shutdown completed');
    } catch (e) {
      debugPrint('Error during analytics shutdown: $e');
    }
  }

  /// Debug helper to force re-initialization
  static Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }

  /// Get current user context
  static Map<String, String?> getUserContext() {
    return {
      'user_id': _currentUserId,
      'user_type': _currentUserType,
    };
  }

  /// Check if analytics system is ready
  static bool get isReady => _isInitialized && PrivacyAnalyticsService.isTrackingAllowed;
  
  /// Get current user ID
  static String? get currentUserId => _currentUserId;
  
  /// Get current user type
  static String get currentUserType => _currentUserType;
}