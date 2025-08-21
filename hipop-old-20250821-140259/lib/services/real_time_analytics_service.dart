import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/analytics_event.dart';

/// Real-time analytics service for tracking user interactions and events
/// Replaces mock data with genuine user behavior tracking
class RealTimeAnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _eventsCollection =
      _firestore.collection('user_events');
  static final CollectionReference _sessionsCollection =
      _firestore.collection('user_sessions');
  
  // Session management
  static String? _currentSessionId;
  static DateTime? _sessionStartTime;
  static String? _currentUserId;
  static String _currentUserType = 'anonymous';
  static final List<AnalyticsEvent> _offlineEventQueue = [];
  static bool _isOnline = true;
  static Map<String, dynamic>? _deviceInfo;
  
  // Privacy settings
  static bool _trackingConsented = false;
  static bool _anonymousMode = false;

  /// Initialize the analytics service
  static Future<void> initialize({
    String? userId,
    String userType = 'anonymous',
    bool requestConsent = true,
  }) async {
    try {
      _currentUserId = userId;
      _currentUserType = userType;
      
      // Get device info for analytics
      await _initializeDeviceInfo();
      
      // Request tracking consent if required
      if (requestConsent) {
        await requestTrackingConsent();
      } else {
        _trackingConsented = true;
      }
      
      // Start session
      if (_trackingConsented) {
        await startSession(userId);
      }
      
      debugPrint('RealTimeAnalyticsService initialized for user: $userId, type: $userType');
    } catch (e) {
      debugPrint('Error initializing analytics service: $e');
    }
  }

  /// Start a new user session
  static Future<String> startSession(String? userId) async {
    try {
      if (!_trackingConsented) {
        debugPrint('Analytics tracking not consented - skipping session start');
        return '';
      }

      _currentSessionId = generateSessionId();
      _sessionStartTime = DateTime.now();
      _currentUserId = userId;
      
      final session = UserSession(
        sessionId: _currentSessionId!,
        userId: _anonymousMode ? null : userId,
        startTime: _sessionStartTime!,
        userType: _currentUserType,
        deviceInfo: _deviceInfo ?? {},
        isActive: true,
      );
      
      // Store session in Firestore
      await _sessionsCollection.doc(_currentSessionId).set(session.toFirestore());
      
      // Track session start event
      await trackEvent(AnalyticsEventType.sessionStart, {
        'sessionId': _currentSessionId,
        'userType': _currentUserType,
        'startTime': _sessionStartTime!.toIso8601String(),
      });
      
      debugPrint('Analytics session started: $_currentSessionId');
      return _currentSessionId!;
    } catch (e) {
      debugPrint('Error starting analytics session: $e');
      return '';
    }
  }

  /// End the current user session
  static Future<void> endSession() async {
    try {
      if (_currentSessionId == null || !_trackingConsented) {
        return;
      }

      final endTime = DateTime.now();
      final duration = _sessionStartTime != null 
          ? endTime.difference(_sessionStartTime!)
          : Duration.zero;

      // Update session in Firestore
      await _sessionsCollection.doc(_currentSessionId).update({
        'endTime': Timestamp.fromDate(endTime),
        'duration': duration.inSeconds,
        'isActive': false,
      });

      // Track session end event
      await trackEvent(AnalyticsEventType.sessionEnd, {
        'sessionId': _currentSessionId,
        'duration': duration.inSeconds,
        'endTime': endTime.toIso8601String(),
      });

      debugPrint('Analytics session ended: $_currentSessionId (duration: ${duration.inMinutes} minutes)');
      
      _currentSessionId = null;
      _sessionStartTime = null;
    } catch (e) {
      debugPrint('Error ending analytics session: $e');
    }
  }

  /// Track a generic event
  static Future<void> trackEvent(
    AnalyticsEventType eventType,
    Map<String, dynamic> data, {
    String? screenName,
    String? marketId,
    String? vendorId,
  }) async {
    try {
      if (!_trackingConsented) {
        return;
      }

      final event = AnalyticsEvent(
        id: _generateEventId(),
        userId: _anonymousMode ? null : _currentUserId,
        sessionId: _currentSessionId ?? '',
        eventType: eventType,
        data: data,
        timestamp: DateTime.now(),
        screenName: screenName,
        marketId: marketId,
        vendorId: vendorId,
        userType: _currentUserType,
        deviceInfo: _deviceInfo,
      );

      if (_isOnline) {
        await _eventsCollection.doc(event.id).set(event.toFirestore());
        debugPrint('Event tracked: ${eventType.name} - $screenName');
      } else {
        // Queue for offline sync
        _offlineEventQueue.add(event);
        debugPrint('Event queued for offline sync: ${eventType.name}');
      }
    } catch (e) {
      debugPrint('Error tracking event: $e');
      // Add to offline queue as fallback
      if (!_offlineEventQueue.any((queuedEvent) => 
          queuedEvent.eventType == eventType && 
          queuedEvent.timestamp.difference(DateTime.now()).abs().inSeconds < 5)) {
        _offlineEventQueue.add(AnalyticsEvent(
          id: _generateEventId(),
          userId: _anonymousMode ? null : _currentUserId,
          sessionId: _currentSessionId ?? '',
          eventType: eventType,
          data: data,
          timestamp: DateTime.now(),
          screenName: screenName,
          marketId: marketId,
          vendorId: vendorId,
          userType: _currentUserType,
          deviceInfo: _deviceInfo,
        ));
      }
    }
  }

  /// Track page/screen views
  static Future<void> trackPageView(String screenName, {String? userId}) async {
    await trackEvent(
      AnalyticsEventType.pageView,
      {
        'screenName': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: screenName,
    );
  }

  /// Track vendor interactions
  static Future<void> trackVendorInteraction(
    String action,
    String vendorId, {
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    final eventType = _getVendorEventType(action);
    final data = {
      'action': action,
      'vendorId': vendorId,
      'timestamp': DateTime.now().toIso8601String(),
      ...(additionalData ?? {}),
    };

    await trackEvent(
      eventType,
      data,
      vendorId: vendorId,
    );
  }

  /// Track market engagement
  static Future<void> trackMarketEngagement(
    String action,
    String marketId, {
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    final eventType = _getMarketEventType(action);
    final data = {
      'action': action,
      'marketId': marketId,
      'timestamp': DateTime.now().toIso8601String(),
      ...(additionalData ?? {}),
    };

    await trackEvent(
      eventType,
      data,
      marketId: marketId,
    );
  }

  /// Track search events
  static Future<void> trackSearch(
    String query, {
    String? category,
    String? marketId,
    int? resultCount,
  }) async {
    await trackEvent(
      AnalyticsEventType.searchPerformed,
      {
        'query': query,
        'category': category,
        'marketId': marketId,
        'resultCount': resultCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
      marketId: marketId,
    );
  }

  /// Track search result clicks
  static Future<void> trackSearchResultClick(
    String query,
    String resultId,
    String resultType, {
    int? position,
    String? marketId,
  }) async {
    await trackEvent(
      AnalyticsEventType.searchResultClick,
      {
        'query': query,
        'resultId': resultId,
        'resultType': resultType,
        'position': position,
        'marketId': marketId,
        'timestamp': DateTime.now().toIso8601String(),
      },
      marketId: marketId,
    );
  }

  /// Track errors for debugging and improvement
  static Future<void> trackError(
    String errorType,
    String errorMessage, {
    String? screenName,
    Map<String, dynamic>? context,
  }) async {
    await trackEvent(
      AnalyticsEventType.errorOccurred,
      {
        'errorType': errorType,
        'errorMessage': errorMessage,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: screenName,
    );
  }

  /// Request user consent for analytics tracking
  static Future<bool> requestTrackingConsent() async {
    try {
      // In a real implementation, this would show a consent dialog
      // For now, we'll default to true but provide opt-out mechanism
      _trackingConsented = true;
      _anonymousMode = false;
      
      debugPrint('Analytics tracking consent granted');
      return true;
    } catch (e) {
      debugPrint('Error requesting tracking consent: $e');
      _trackingConsented = false;
      return false;
    }
  }

  /// Enable anonymous tracking mode
  static void enableAnonymousMode() {
    _anonymousMode = true;
    _currentUserId = null;
    debugPrint('Anonymous analytics mode enabled');
  }

  /// Disable analytics tracking entirely
  static void disableTracking() {
    _trackingConsented = false;
    debugPrint('Analytics tracking disabled');
  }

  /// Sync offline events when connection is restored
  static Future<void> syncOfflineEvents() async {
    if (_offlineEventQueue.isEmpty || !_trackingConsented) {
      return;
    }

    try {
      debugPrint('Syncing ${_offlineEventQueue.length} offline analytics events...');
      
      final batch = _firestore.batch();
      for (final event in _offlineEventQueue) {
        final docRef = _eventsCollection.doc(event.id);
        batch.set(docRef, event.toFirestore());
      }
      
      await batch.commit();
      
      debugPrint('Successfully synced ${_offlineEventQueue.length} offline events');
      _offlineEventQueue.clear();
      _isOnline = true;
    } catch (e) {
      debugPrint('Error syncing offline events: $e');
    }
  }

  /// Set network status
  static void setNetworkStatus(bool isOnline) {
    final wasOffline = !_isOnline;
    _isOnline = isOnline;
    
    if (wasOffline && isOnline) {
      // Connection restored, sync offline events
      syncOfflineEvents();
    }
  }

  /// Get analytics summary for a specific time period
  static Future<Map<String, dynamic>> getEventsSummary({
    String? marketId,
    String? vendorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _eventsCollection;
      
      if (marketId != null) {
        query = query.where('marketId', isEqualTo: marketId);
      }
      
      if (vendorId != null) {
        query = query.where('vendorId', isEqualTo: vendorId);
      }
      
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      final snapshot = await query.get();
      
      final events = snapshot.docs
          .map((doc) => AnalyticsEvent.fromFirestore(doc))
          .toList();
      
      // Calculate metrics
      final totalEvents = events.length;
      final uniqueUsers = events
          .where((e) => e.userId != null)
          .map((e) => e.userId)
          .toSet()
          .length;
      
      final pageViews = events
          .where((e) => e.eventType == AnalyticsEventType.pageView)
          .length;
      
      final marketViews = events
          .where((e) => e.eventType == AnalyticsEventType.marketView)
          .length;
      
      final vendorViews = events
          .where((e) => e.eventType == AnalyticsEventType.vendorView)
          .length;
      
      final searches = events
          .where((e) => e.eventType == AnalyticsEventType.searchPerformed)
          .length;
      
      return {
        'totalEvents': totalEvents,
        'uniqueUsers': uniqueUsers,
        'pageViews': pageViews,
        'marketViews': marketViews,
        'vendorViews': vendorViews,
        'searches': searches,
        'dateRange': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
      };
    } catch (e) {
      debugPrint('Error getting events summary: $e');
      return {};
    }
  }

  /// Get popular content based on real engagement data
  static Future<Map<String, dynamic>> getPopularContent({
    String? marketId,
    int limit = 10,
  }) async {
    try {
      Query query = _eventsCollection;
      
      if (marketId != null) {
        query = query.where('marketId', isEqualTo: marketId);
      }
      
      final snapshot = await query
          .where('eventType', whereIn: [
            AnalyticsEventType.marketView.name,
            AnalyticsEventType.vendorView.name,
          ])
          .get();
      
      final events = snapshot.docs
          .map((doc) => AnalyticsEvent.fromFirestore(doc))
          .toList();
      
      // Count views by market and vendor
      final marketViews = <String, int>{};
      final vendorViews = <String, int>{};
      
      for (final event in events) {
        if (event.marketId != null && event.eventType == AnalyticsEventType.marketView) {
          marketViews[event.marketId!] = (marketViews[event.marketId!] ?? 0) + 1;
        }
        if (event.vendorId != null && event.eventType == AnalyticsEventType.vendorView) {
          vendorViews[event.vendorId!] = (vendorViews[event.vendorId!] ?? 0) + 1;
        }
      }
      
      // Sort and limit results
      final topMarkets = marketViews.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      final topVendors = vendorViews.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      return {
        'topMarkets': topMarkets.take(limit).map((e) => {
          'id': e.key,
          'views': e.value,
        }).toList(),
        'topVendors': topVendors.take(limit).map((e) => {
          'id': e.key,
          'views': e.value,
        }).toList(),
      };
    } catch (e) {
      debugPrint('Error getting popular content: $e');
      return {};
    }
  }

  /// Delete user data for GDPR compliance
  static Future<void> deleteUserData(String userId) async {
    try {
      // Delete user events
      final eventsSnapshot = await _eventsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete user sessions
      final sessionsSnapshot = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in sessionsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      debugPrint('User data deleted for GDPR compliance: $userId');
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }

  /// Helper methods
  static String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'session_${timestamp}_$random';
  }

  static String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'event_${timestamp}_$random';
  }

  static Future<void> _initializeDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        _deviceInfo = {
          'platform': 'web',
          'browser': webInfo.browserName.toString(),
          'browserVersion': webInfo.appVersion,
          'userAgent': webInfo.userAgent,
          'appVersion': packageInfo.version,
          'appBuild': packageInfo.buildNumber,
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceInfo = {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'appVersion': packageInfo.version,
          'appBuild': packageInfo.buildNumber,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceInfo = {
          'platform': 'ios',
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'name': iosInfo.name,
          'appVersion': packageInfo.version,
          'appBuild': packageInfo.buildNumber,
        };
      }
    } catch (e) {
      debugPrint('Error initializing device info: $e');
      _deviceInfo = {'platform': 'unknown'};
    }
  }

  static AnalyticsEventType _getVendorEventType(String action) {
    switch (action.toLowerCase()) {
      case 'view':
      case 'profile_view':
        return AnalyticsEventType.vendorProfileView;
      case 'contact':
        return AnalyticsEventType.vendorContactClick;
      case 'phone':
        return AnalyticsEventType.vendorPhoneClick;
      case 'email':
        return AnalyticsEventType.vendorEmailClick;
      case 'instagram':
        return AnalyticsEventType.vendorInstagramClick;
      case 'favorite':
        return AnalyticsEventType.vendorFavorite;
      case 'unfavorite':
        return AnalyticsEventType.vendorUnfavorite;
      case 'share':
        return AnalyticsEventType.vendorShare;
      default:
        return AnalyticsEventType.vendorView;
    }
  }

  static AnalyticsEventType _getMarketEventType(String action) {
    switch (action.toLowerCase()) {
      case 'view':
        return AnalyticsEventType.marketView;
      case 'favorite':
        return AnalyticsEventType.marketFavorite;
      case 'unfavorite':
        return AnalyticsEventType.marketUnfavorite;
      case 'share':
        return AnalyticsEventType.marketShare;
      case 'search':
        return AnalyticsEventType.marketSearch;
      case 'directions':
        return AnalyticsEventType.marketDirectionsClick;
      default:
        return AnalyticsEventType.marketView;
    }
  }
}