import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Real-time analytics event model for tracking user interactions
class AnalyticsEvent extends Equatable {
  final String id;
  final String? userId; // Null for anonymous users
  final String sessionId;
  final AnalyticsEventType eventType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? screenName;
  final String? marketId;
  final String? vendorId;
  final String? userType; // 'shopper', 'vendor', 'organizer'
  final Map<String, dynamic>? deviceInfo;

  const AnalyticsEvent({
    required this.id,
    this.userId,
    required this.sessionId,
    required this.eventType,
    required this.data,
    required this.timestamp,
    this.screenName,
    this.marketId,
    this.vendorId,
    this.userType,
    this.deviceInfo,
  });

  factory AnalyticsEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AnalyticsEvent(
      id: doc.id,
      userId: data['userId'] as String?,
      sessionId: data['sessionId'] ?? '',
      eventType: AnalyticsEventType.values.firstWhere(
        (e) => e.name == data['eventType'],
        orElse: () => AnalyticsEventType.other,
      ),
      data: data['data'] ?? {},
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      screenName: data['screenName'] as String?,
      marketId: data['marketId'] as String?,
      vendorId: data['vendorId'] as String?,
      userType: data['userType'] as String?,
      deviceInfo: data['deviceInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'eventType': eventType.name,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'screenName': screenName,
      'marketId': marketId,
      'vendorId': vendorId,
      'userType': userType,
      'deviceInfo': deviceInfo,
    };
  }

  AnalyticsEvent copyWith({
    String? id,
    String? userId,
    String? sessionId,
    AnalyticsEventType? eventType,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? screenName,
    String? marketId,
    String? vendorId,
    String? userType,
    Map<String, dynamic>? deviceInfo,
  }) {
    return AnalyticsEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      eventType: eventType ?? this.eventType,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      screenName: screenName ?? this.screenName,
      marketId: marketId ?? this.marketId,
      vendorId: vendorId ?? this.vendorId,
      userType: userType ?? this.userType,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sessionId,
        eventType,
        data,
        timestamp,
        screenName,
        marketId,
        vendorId,
        userType,
        deviceInfo,
      ];
}

/// User session model for tracking user activity sessions
class UserSession extends Equatable {
  final String sessionId;
  final String? userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String userType;
  final Map<String, dynamic> deviceInfo;
  final List<String> screenViews;
  final int totalEvents;
  final Duration? duration;
  final bool isActive;

  const UserSession({
    required this.sessionId,
    this.userId,
    required this.startTime,
    this.endTime,
    required this.userType,
    required this.deviceInfo,
    this.screenViews = const [],
    this.totalEvents = 0,
    this.duration,
    this.isActive = true,
  });

  factory UserSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final startTime = (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endTime = (data['endTime'] as Timestamp?)?.toDate();
    
    return UserSession(
      sessionId: doc.id,
      userId: data['userId'] as String?,
      startTime: startTime,
      endTime: endTime,
      userType: data['userType'] ?? 'anonymous',
      deviceInfo: data['deviceInfo'] ?? {},
      screenViews: List<String>.from(data['screenViews'] ?? []),
      totalEvents: data['totalEvents'] ?? 0,
      duration: endTime != null 
          ? endTime.difference(startTime)
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'userType': userType,
      'deviceInfo': deviceInfo,
      'screenViews': screenViews,
      'totalEvents': totalEvents,
      'duration': duration?.inSeconds,
      'isActive': isActive,
    };
  }

  UserSession copyWith({
    String? sessionId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? userType,
    Map<String, dynamic>? deviceInfo,
    List<String>? screenViews,
    int? totalEvents,
    Duration? duration,
    bool? isActive,
  }) {
    return UserSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userType: userType ?? this.userType,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      screenViews: screenViews ?? this.screenViews,
      totalEvents: totalEvents ?? this.totalEvents,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        userId,
        startTime,
        endTime,
        userType,
        deviceInfo,
        screenViews,
        totalEvents,
        duration,
        isActive,
      ];
}

/// Enumeration of all trackable analytics events
enum AnalyticsEventType {
  // Page/Screen Views
  pageView,
  screenEnter,
  screenExit,
  
  // User Interactions
  buttonClick,
  linkClick,
  menuNavigation,
  tabSwitch,
  
  // Market-specific Events
  marketView,
  marketFavorite,
  marketUnfavorite,
  marketShare,
  marketSearch,
  marketDirectionsClick,
  
  // Vendor-specific Events
  vendorView,
  vendorProfileView,
  vendorContactClick,
  vendorPhoneClick,
  vendorEmailClick,
  vendorInstagramClick,
  vendorFavorite,
  vendorUnfavorite,
  vendorShare,
  
  // Search Events
  searchPerformed,
  searchResultClick,
  searchFilterApplied,
  
  // Error Events
  errorOccurred,
  networkError,
  permissionDenied,
  
  // App lifecycle events
  sessionStart,
  sessionEnd,
  appBackground,
  appForeground,
  
  // Other events
  other,
}

/// Extension for Analytics Event Type display and categorization
extension AnalyticsEventTypeExtension on AnalyticsEventType {
  String get displayName {
    switch (this) {
      case AnalyticsEventType.pageView:
        return 'Page View';
      case AnalyticsEventType.screenEnter:
        return 'Screen Enter';
      case AnalyticsEventType.screenExit:
        return 'Screen Exit';
      case AnalyticsEventType.buttonClick:
        return 'Button Click';
      case AnalyticsEventType.linkClick:
        return 'Link Click';
      case AnalyticsEventType.menuNavigation:
        return 'Menu Navigation';
      case AnalyticsEventType.tabSwitch:
        return 'Tab Switch';
      case AnalyticsEventType.marketView:
        return 'Market View';
      case AnalyticsEventType.marketFavorite:
        return 'Market Favorite';
      case AnalyticsEventType.marketUnfavorite:
        return 'Market Unfavorite';
      case AnalyticsEventType.marketShare:
        return 'Market Share';
      case AnalyticsEventType.marketSearch:
        return 'Market Search';
      case AnalyticsEventType.marketDirectionsClick:
        return 'Market Directions';
      case AnalyticsEventType.vendorView:
        return 'Vendor View';
      case AnalyticsEventType.vendorProfileView:
        return 'Vendor Profile View';
      case AnalyticsEventType.vendorContactClick:
        return 'Vendor Contact';
      case AnalyticsEventType.vendorPhoneClick:
        return 'Vendor Phone';
      case AnalyticsEventType.vendorEmailClick:
        return 'Vendor Email';
      case AnalyticsEventType.vendorInstagramClick:
        return 'Vendor Instagram';
      case AnalyticsEventType.vendorFavorite:
        return 'Vendor Favorite';
      case AnalyticsEventType.vendorUnfavorite:
        return 'Vendor Unfavorite';
      case AnalyticsEventType.vendorShare:
        return 'Vendor Share';
      case AnalyticsEventType.searchPerformed:
        return 'Search Performed';
      case AnalyticsEventType.searchResultClick:
        return 'Search Result Click';
      case AnalyticsEventType.searchFilterApplied:
        return 'Search Filter Applied';
      case AnalyticsEventType.errorOccurred:
        return 'Error Occurred';
      case AnalyticsEventType.networkError:
        return 'Network Error';
      case AnalyticsEventType.permissionDenied:
        return 'Permission Denied';
      case AnalyticsEventType.sessionStart:
        return 'Session Start';
      case AnalyticsEventType.sessionEnd:
        return 'Session End';
      case AnalyticsEventType.appBackground:
        return 'App Background';
      case AnalyticsEventType.appForeground:
        return 'App Foreground';
      case AnalyticsEventType.other:
        return 'Other';
    }
  }

  String get category {
    switch (this) {
      case AnalyticsEventType.pageView:
      case AnalyticsEventType.screenEnter:
      case AnalyticsEventType.screenExit:
        return 'Navigation';
      
      case AnalyticsEventType.buttonClick:
      case AnalyticsEventType.linkClick:
      case AnalyticsEventType.menuNavigation:
      case AnalyticsEventType.tabSwitch:
        return 'User Interaction';
      
      case AnalyticsEventType.marketView:
      case AnalyticsEventType.marketFavorite:
      case AnalyticsEventType.marketUnfavorite:
      case AnalyticsEventType.marketShare:
      case AnalyticsEventType.marketSearch:
      case AnalyticsEventType.marketDirectionsClick:
        return 'Market Engagement';
      
      case AnalyticsEventType.vendorView:
      case AnalyticsEventType.vendorProfileView:
      case AnalyticsEventType.vendorContactClick:
      case AnalyticsEventType.vendorPhoneClick:
      case AnalyticsEventType.vendorEmailClick:
      case AnalyticsEventType.vendorInstagramClick:
      case AnalyticsEventType.vendorFavorite:
      case AnalyticsEventType.vendorUnfavorite:
      case AnalyticsEventType.vendorShare:
        return 'Vendor Engagement';
      
      case AnalyticsEventType.searchPerformed:
      case AnalyticsEventType.searchResultClick:
      case AnalyticsEventType.searchFilterApplied:
        return 'Search';
      
      case AnalyticsEventType.errorOccurred:
      case AnalyticsEventType.networkError:
      case AnalyticsEventType.permissionDenied:
        return 'Error';
      
      case AnalyticsEventType.sessionStart:
      case AnalyticsEventType.sessionEnd:
      case AnalyticsEventType.appBackground:
      case AnalyticsEventType.appForeground:
        return 'Session';
      
      case AnalyticsEventType.other:
        return 'Other';
    }
  }

  bool get isPII {
    // Identify events that might contain personally identifiable information
    switch (this) {
      case AnalyticsEventType.vendorPhoneClick:
      case AnalyticsEventType.vendorEmailClick:
        return true;
      default:
        return false;
    }
  }
}