import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum EventStatus {
  draft,
  published,
  active,
  completed,
  cancelled,
  postponed,
}

enum RecurrenceType {
  none,      // One-time event
  daily,     // Every day
  weekly,    // Every week
  biweekly,  // Every 2 weeks
  monthly,   // Same date every month
  custom,    // Custom recurrence pattern
}

enum EventType {
  farmersMarket,
  artisanMarket,
  foodFestival,
  holidayMarket,
  communityEvent,
  specialEvent,
  popupMarket,
  other,
}

class MarketEvent extends Equatable {
  final String id;
  final String marketId; // Primary market location (for backward compatibility)
  final List<String> participatingMarketIds; // All markets participating in this event
  final String organizerId; // Market organizer who created the event
  final String title;
  final String description;
  final EventType eventType;
  final String? theme; // Holiday theme, special focus, etc.
  
  // Timing
  final DateTime startDateTime;
  final DateTime endDateTime;
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate; // When recurring events stop
  final List<String>? customRecurrenceDays; // For custom patterns ["monday", "wednesday"]
  
  // Vendor Management
  final int maxVendorSlots;
  final int bookedVendorSlots;
  final double? vendorFee; // Cost for vendors to participate
  final List<String> selectedVendorIds; // Managed vendors selected for this event
  final List<String> featuredVendorIds; // Highlighted vendors
  final Map<String, String> boothAssignments; // vendorId -> booth number
  
  // Event Details
  final List<String> specialFeatures; // Live music, kids activities, etc.
  final String? weatherBackupPlan;
  final bool isPublic; // Visible to shoppers
  final bool requiresVendorApproval; // Organizer approval needed
  
  // Promotional
  final String? imageUrl;
  final List<String> tags; // Searchable tags
  final String? promotionalText;
  final String? websiteUrl;
  final Map<String, String> socialMediaLinks; // platform -> url
  
  // Status and Meta
  final EventStatus status;
  final String? cancellationReason;
  final DateTime? lastWeatherCheck;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata; // Flexible field for additional data

  const MarketEvent({
    required this.id,
    required this.marketId,
    this.participatingMarketIds = const [],
    required this.organizerId,
    required this.title,
    required this.description,
    this.eventType = EventType.farmersMarket,
    this.theme,
    required this.startDateTime,
    required this.endDateTime,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceEndDate,
    this.customRecurrenceDays,
    this.maxVendorSlots = 50,
    this.bookedVendorSlots = 0,
    this.vendorFee,
    this.selectedVendorIds = const [],
    this.featuredVendorIds = const [],
    this.boothAssignments = const {},
    this.specialFeatures = const [],
    this.weatherBackupPlan,
    this.isPublic = true,
    this.requiresVendorApproval = true,
    this.imageUrl,
    this.tags = const [],
    this.promotionalText,
    this.websiteUrl,
    this.socialMediaLinks = const {},
    this.status = EventStatus.draft,
    this.cancellationReason,
    this.lastWeatherCheck,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory MarketEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MarketEvent(
      id: doc.id,
      marketId: data['marketId'] ?? '',
      participatingMarketIds: List<String>.from(data['participatingMarketIds'] ?? []),
      organizerId: data['organizerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventType: EventType.values.firstWhere(
        (type) => type.name == data['eventType'],
        orElse: () => EventType.farmersMarket,
      ),
      theme: data['theme'],
      startDateTime: (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDateTime: (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recurrenceType: RecurrenceType.values.firstWhere(
        (type) => type.name == data['recurrenceType'],
        orElse: () => RecurrenceType.none,
      ),
      recurrenceEndDate: (data['recurrenceEndDate'] as Timestamp?)?.toDate(),
      customRecurrenceDays: data['customRecurrenceDays'] != null 
          ? List<String>.from(data['customRecurrenceDays'])
          : null,
      maxVendorSlots: data['maxVendorSlots'] ?? 50,
      bookedVendorSlots: data['bookedVendorSlots'] ?? 0,
      vendorFee: data['vendorFee']?.toDouble(),
      selectedVendorIds: List<String>.from(data['selectedVendorIds'] ?? []),
      featuredVendorIds: List<String>.from(data['featuredVendorIds'] ?? []),
      boothAssignments: Map<String, String>.from(data['boothAssignments'] ?? {}),
      specialFeatures: List<String>.from(data['specialFeatures'] ?? []),
      weatherBackupPlan: data['weatherBackupPlan'],
      isPublic: data['isPublic'] ?? true,
      requiresVendorApproval: data['requiresVendorApproval'] ?? true,
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      promotionalText: data['promotionalText'],
      websiteUrl: data['websiteUrl'],
      socialMediaLinks: Map<String, String>.from(data['socialMediaLinks'] ?? {}),
      status: EventStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => EventStatus.draft,
      ),
      cancellationReason: data['cancellationReason'],
      lastWeatherCheck: (data['lastWeatherCheck'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'marketId': marketId,
      'participatingMarketIds': participatingMarketIds,
      'organizerId': organizerId,
      'title': title,
      'description': description,
      'eventType': eventType.name,
      'theme': theme,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'recurrenceType': recurrenceType.name,
      'recurrenceEndDate': recurrenceEndDate != null 
          ? Timestamp.fromDate(recurrenceEndDate!) 
          : null,
      'customRecurrenceDays': customRecurrenceDays,
      'maxVendorSlots': maxVendorSlots,
      'bookedVendorSlots': bookedVendorSlots,
      'vendorFee': vendorFee,
      'selectedVendorIds': selectedVendorIds,
      'featuredVendorIds': featuredVendorIds,
      'boothAssignments': boothAssignments,
      'specialFeatures': specialFeatures,
      'weatherBackupPlan': weatherBackupPlan,
      'isPublic': isPublic,
      'requiresVendorApproval': requiresVendorApproval,
      'imageUrl': imageUrl,
      'tags': tags,
      'promotionalText': promotionalText,
      'websiteUrl': websiteUrl,
      'socialMediaLinks': socialMediaLinks,
      'status': status.name,
      'cancellationReason': cancellationReason,
      'lastWeatherCheck': lastWeatherCheck != null 
          ? Timestamp.fromDate(lastWeatherCheck!) 
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  MarketEvent copyWith({
    String? id,
    String? marketId,
    List<String>? participatingMarketIds,
    String? organizerId,
    String? title,
    String? description,
    EventType? eventType,
    String? theme,
    DateTime? startDateTime,
    DateTime? endDateTime,
    RecurrenceType? recurrenceType,
    DateTime? recurrenceEndDate,
    List<String>? customRecurrenceDays,
    int? maxVendorSlots,
    int? bookedVendorSlots,
    double? vendorFee,
    List<String>? selectedVendorIds,
    List<String>? featuredVendorIds,
    Map<String, String>? boothAssignments,
    List<String>? specialFeatures,
    String? weatherBackupPlan,
    bool? isPublic,
    bool? requiresVendorApproval,
    String? imageUrl,
    List<String>? tags,
    String? promotionalText,
    String? websiteUrl,
    Map<String, String>? socialMediaLinks,
    EventStatus? status,
    String? cancellationReason,
    DateTime? lastWeatherCheck,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MarketEvent(
      id: id ?? this.id,
      marketId: marketId ?? this.marketId,
      participatingMarketIds: participatingMarketIds ?? this.participatingMarketIds,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      theme: theme ?? this.theme,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      customRecurrenceDays: customRecurrenceDays ?? this.customRecurrenceDays,
      maxVendorSlots: maxVendorSlots ?? this.maxVendorSlots,
      bookedVendorSlots: bookedVendorSlots ?? this.bookedVendorSlots,
      vendorFee: vendorFee ?? this.vendorFee,
      selectedVendorIds: selectedVendorIds ?? this.selectedVendorIds,
      featuredVendorIds: featuredVendorIds ?? this.featuredVendorIds,
      boothAssignments: boothAssignments ?? this.boothAssignments,
      specialFeatures: specialFeatures ?? this.specialFeatures,
      weatherBackupPlan: weatherBackupPlan ?? this.weatherBackupPlan,
      isPublic: isPublic ?? this.isPublic,
      requiresVendorApproval: requiresVendorApproval ?? this.requiresVendorApproval,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      promotionalText: promotionalText ?? this.promotionalText,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      lastWeatherCheck: lastWeatherCheck ?? this.lastWeatherCheck,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for event status
  bool get isDraft => status == EventStatus.draft;
  bool get isPublished => status == EventStatus.published;
  bool get isActive => status == EventStatus.active;
  bool get isCompleted => status == EventStatus.completed;
  bool get isCancelled => status == EventStatus.cancelled;
  bool get isPostponed => status == EventStatus.postponed;

  // Helper methods for timing
  bool get isUpcoming => DateTime.now().isBefore(startDateTime);
  bool get isHappening => DateTime.now().isAfter(startDateTime) && DateTime.now().isBefore(endDateTime);
  bool get isPast => DateTime.now().isAfter(endDateTime);
  bool get isToday => _isSameDay(DateTime.now(), startDateTime);
  bool get isRecurring => recurrenceType != RecurrenceType.none;

  // Helper methods for vendor management
  bool get hasAvailableSlots => bookedVendorSlots < maxVendorSlots;
  int get availableSlots => maxVendorSlots - bookedVendorSlots;
  bool get isFull => bookedVendorSlots >= maxVendorSlots;
  double get occupancyRate => maxVendorSlots > 0 ? bookedVendorSlots / maxVendorSlots : 0.0;

  // Display helpers
  String get statusDisplayName {
    switch (status) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Published';
      case EventStatus.active:
        return 'Active';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.postponed:
        return 'Postponed';
    }
  }

  String get eventTypeDisplayName {
    switch (eventType) {
      case EventType.farmersMarket:
        return 'Farmers Market';
      case EventType.artisanMarket:
        return 'Artisan Market';
      case EventType.foodFestival:
        return 'Food Festival';
      case EventType.holidayMarket:
        return 'Holiday Market';
      case EventType.communityEvent:
        return 'Community Event';
      case EventType.specialEvent:
        return 'Special Event';
      case EventType.popupMarket:
        return 'Pop-up Market';
      case EventType.other:
        return 'Other';
    }
  }

  String get recurrenceDisplayName {
    switch (recurrenceType) {
      case RecurrenceType.none:
        return 'One-time event';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.biweekly:
        return 'Bi-weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.custom:
        return 'Custom schedule';
    }
  }

  String get formattedDateRange {
    final start = startDateTime;
    final end = endDateTime;
    
    if (_isSameDay(start, end)) {
      return '${_formatDate(start)} ${_formatTime(start)} - ${_formatTime(end)}';
    } else {
      return '${_formatDate(start)} ${_formatTime(start)} - ${_formatDate(end)} ${_formatTime(end)}';
    }
  }

  // Generate next occurrence for recurring events
  DateTime? getNextOccurrence() {
    if (!isRecurring) return null;
    
    final now = DateTime.now();
    DateTime nextDate = startDateTime;
    
    // Find the next occurrence after now
    while (nextDate.isBefore(now)) {
      switch (recurrenceType) {
        case RecurrenceType.daily:
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case RecurrenceType.weekly:
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case RecurrenceType.biweekly:
          nextDate = nextDate.add(const Duration(days: 14));
          break;
        case RecurrenceType.monthly:
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day, 
                             nextDate.hour, nextDate.minute);
          break;
        case RecurrenceType.custom:
          // For custom recurrence, find next matching day
          nextDate = _findNextCustomRecurrence(nextDate);
          break;
        case RecurrenceType.none:
          return null;
      }
      
      // Check if we've passed the recurrence end date
      if (recurrenceEndDate != null && nextDate.isAfter(recurrenceEndDate!)) {
        return null;
      }
    }
    
    return nextDate;
  }

  // Utility methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $amPm';
  }

  DateTime _findNextCustomRecurrence(DateTime current) {
    if (customRecurrenceDays == null || customRecurrenceDays!.isEmpty) {
      return current.add(const Duration(days: 7)); // Default to weekly
    }
    
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final currentDayIndex = current.weekday - 1;
    
    // Find next matching day
    for (int i = 1; i <= 7; i++) {
      final checkDayIndex = (currentDayIndex + i) % 7;
      final checkDayName = dayNames[checkDayIndex];
      
      if (customRecurrenceDays!.contains(checkDayName)) {
        return current.add(Duration(days: i));
      }
    }
    
    return current.add(const Duration(days: 7)); // Fallback
  }

  @override
  List<Object?> get props => [
        id,
        marketId,
        participatingMarketIds,
        organizerId,
        title,
        description,
        eventType,
        theme,
        startDateTime,
        endDateTime,
        recurrenceType,
        recurrenceEndDate,
        customRecurrenceDays,
        maxVendorSlots,
        bookedVendorSlots,
        vendorFee,
        selectedVendorIds,
        featuredVendorIds,
        boothAssignments,
        specialFeatures,
        weatherBackupPlan,
        isPublic,
        requiresVendorApproval,
        imageUrl,
        tags,
        promotionalText,
        websiteUrl,
        socialMediaLinks,
        status,
        cancellationReason,
        lastWeatherCheck,
        createdAt,
        updatedAt,
        metadata,
      ];

  @override
  String toString() {
    return 'MarketEvent(id: $id, title: $title, eventType: $eventType, status: $status, startDateTime: $startDateTime)';
  }
}