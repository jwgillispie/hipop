import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/market_event.dart';

class MarketEventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _eventsCollection = 
      _firestore.collection('market_events');

  /// Create a new market event
  static Future<String> createEvent(MarketEvent event) async {
    try {
      final docRef = await _eventsCollection.add(event.toFirestore());
      debugPrint('Market event created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating market event: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  /// Get all events for a specific market
  static Stream<List<MarketEvent>> getEventsForMarket(String marketId) {
    return _eventsCollection
        .where('marketId', isEqualTo: marketId)
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketEvent.fromFirestore(doc))
            .toList());
  }

  /// Get events by organizer
  static Stream<List<MarketEvent>> getEventsByOrganizer(String organizerId) {
    return _eventsCollection
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketEvent.fromFirestore(doc))
            .toList());
  }

  /// Get events by status
  static Stream<List<MarketEvent>> getEventsByStatus(
    String marketId,
    EventStatus status,
  ) {
    return _eventsCollection
        .where('marketId', isEqualTo: marketId)
        .where('status', isEqualTo: status.name)
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketEvent.fromFirestore(doc))
            .toList());
  }

  /// Get upcoming events for a market
  static Stream<List<MarketEvent>> getUpcomingEvents(String marketId) {
    final now = Timestamp.now();
    return _eventsCollection
        .where('marketId', isEqualTo: marketId)
        .where('startDateTime', isGreaterThan: now)
        .where('status', whereIn: [EventStatus.published.name, EventStatus.active.name])
        .orderBy('startDateTime', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketEvent.fromFirestore(doc))
            .toList());
  }

  /// Get events happening today
  static Stream<List<MarketEvent>> getTodaysEvents(String marketId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _eventsCollection
        .where('marketId', isEqualTo: marketId)
        .where('startDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startDateTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketEvent.fromFirestore(doc))
            .toList());
  }

  /// Get public events (for shoppers)
  static Stream<List<MarketEvent>> getPublicEvents() {
    final now = Timestamp.now();
    return _eventsCollection
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: EventStatus.published.name)
        .where('startDateTime', isGreaterThan: now)
        .orderBy('startDateTime', descending: false)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketEvent.fromFirestore(doc))
            .toList());
  }

  /// Get events by date range
  static Stream<List<MarketEvent>> getEventsByDateRange(
    String marketId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _eventsCollection
        .where('marketId', isEqualTo: marketId)
        .where('startDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketEvent.fromFirestore(doc))
            .toList());
  }

  /// Get a single event by ID
  static Future<MarketEvent?> getEvent(String eventId) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return MarketEvent.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting event: $e');
      throw Exception('Failed to get event: $e');
    }
  }

  /// Update an existing event
  static Future<void> updateEvent(String eventId, MarketEvent event) async {
    try {
      await _eventsCollection.doc(eventId).update(event.toFirestore());
      debugPrint('Event $eventId updated');
    } catch (e) {
      debugPrint('Error updating event: $e');
      throw Exception('Failed to update event: $e');
    }
  }

  /// Update specific fields of an event
  static Future<void> updateEventFields(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _eventsCollection.doc(eventId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('Event $eventId fields updated');
    } catch (e) {
      debugPrint('Error updating event fields: $e');
      throw Exception('Failed to update event fields: $e');
    }
  }

  /// Delete an event
  static Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
      debugPrint('Event $eventId deleted');
    } catch (e) {
      debugPrint('Error deleting event: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Publish an event (change status from draft to published)
  static Future<void> publishEvent(String eventId) async {
    await updateEventFields(eventId, {
      'status': EventStatus.published.name,
    });
  }

  /// Cancel an event
  static Future<void> cancelEvent(String eventId, String reason) async {
    await updateEventFields(eventId, {
      'status': EventStatus.cancelled.name,
      'cancellationReason': reason,
    });
  }

  /// Postpone an event
  static Future<void> postponeEvent(
    String eventId, 
    DateTime newStartDateTime, 
    DateTime newEndDateTime,
    String reason,
  ) async {
    await updateEventFields(eventId, {
      'status': EventStatus.postponed.name,
      'startDateTime': Timestamp.fromDate(newStartDateTime),
      'endDateTime': Timestamp.fromDate(newEndDateTime),
      'cancellationReason': reason,
    });
  }

  /// Complete an event
  static Future<void> completeEvent(String eventId) async {
    await updateEventFields(eventId, {
      'status': EventStatus.completed.name,
    });
  }

  /// Add vendor to event
  static Future<void> addVendorToEvent(
    String eventId, 
    String vendorId, 
    {String? boothNumber}
  ) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    
    if (event.isFull) throw Exception('Event is full');
    
    final updates = <String, dynamic>{
      'bookedVendorSlots': event.bookedVendorSlots + 1,
    };
    
    if (boothNumber != null) {
      final newBoothAssignments = Map<String, String>.from(event.boothAssignments);
      newBoothAssignments[vendorId] = boothNumber;
      updates['boothAssignments'] = newBoothAssignments;
    }
    
    await updateEventFields(eventId, updates);
  }

  /// Remove vendor from event
  static Future<void> removeVendorFromEvent(String eventId, String vendorId) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    
    final newBoothAssignments = Map<String, String>.from(event.boothAssignments);
    newBoothAssignments.remove(vendorId);
    
    await updateEventFields(eventId, {
      'bookedVendorSlots': (event.bookedVendorSlots - 1).clamp(0, event.maxVendorSlots),
      'boothAssignments': newBoothAssignments,
    });
  }

  /// Update booth assignment
  static Future<void> updateBoothAssignment(
    String eventId, 
    String vendorId, 
    String boothNumber,
  ) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    
    final newBoothAssignments = Map<String, String>.from(event.boothAssignments);
    newBoothAssignments[vendorId] = boothNumber;
    
    await updateEventFields(eventId, {
      'boothAssignments': newBoothAssignments,
    });
  }

  /// Add featured vendor
  static Future<void> addFeaturedVendor(String eventId, String vendorId) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    
    if (!event.featuredVendorIds.contains(vendorId)) {
      final newFeaturedVendors = List<String>.from(event.featuredVendorIds)..add(vendorId);
      await updateEventFields(eventId, {
        'featuredVendorIds': newFeaturedVendors,
      });
    }
  }

  /// Remove featured vendor
  static Future<void> removeFeaturedVendor(String eventId, String vendorId) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    
    final newFeaturedVendors = List<String>.from(event.featuredVendorIds)..remove(vendorId);
    await updateEventFields(eventId, {
      'featuredVendorIds': newFeaturedVendors,
    });
  }

  /// Get event statistics for dashboard
  static Future<Map<String, int>> getEventStats(String marketId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final snapshot = await _eventsCollection
          .where('marketId', isEqualTo: marketId)
          .get();
      
      final events = snapshot.docs
          .map((doc) => MarketEvent.fromFirestore(doc))
          .toList();
      
      final stats = <String, int>{
        'total': events.length,
        'upcoming': 0,
        'thisMonth': 0,
        'published': 0,
        'draft': 0,
        'completed': 0,
        'cancelled': 0,
      };
      
      for (final event in events) {
        // Count upcoming events
        if (event.isUpcoming) {
          stats['upcoming'] = stats['upcoming']! + 1;
        }
        
        // Count events this month
        if (event.startDateTime.isAfter(startOfMonth) && 
            event.startDateTime.isBefore(endOfMonth)) {
          stats['thisMonth'] = stats['thisMonth']! + 1;
        }
        
        // Count by status
        switch (event.status) {
          case EventStatus.published:
            stats['published'] = stats['published']! + 1;
            break;
          case EventStatus.draft:
            stats['draft'] = stats['draft']! + 1;
            break;
          case EventStatus.completed:
            stats['completed'] = stats['completed']! + 1;
            break;
          case EventStatus.cancelled:
            stats['cancelled'] = stats['cancelled']! + 1;
            break;
          default:
            break;
        }
      }
      
      return stats;
    } catch (e) {
      debugPrint('Error getting event stats: $e');
      throw Exception('Failed to get event statistics: $e');
    }
  }

  /// Search events by title or description
  static Future<List<MarketEvent>> searchEvents(
    String marketId, 
    String query,
  ) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic search that gets all events and filters locally
      final snapshot = await _eventsCollection
          .where('marketId', isEqualTo: marketId)
          .get();
      
      final events = snapshot.docs
          .map((doc) => MarketEvent.fromFirestore(doc))
          .where((event) => 
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              event.description.toLowerCase().contains(query.toLowerCase()) ||
              event.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
      
      return events;
    } catch (e) {
      debugPrint('Error searching events: $e');
      throw Exception('Failed to search events: $e');
    }
  }

  /// Generate recurring event instances
  static Future<List<String>> createRecurringEvents(MarketEvent baseEvent) async {
    if (baseEvent.recurrenceType == RecurrenceType.none) {
      throw Exception('Event is not set to recurring');
    }
    
    final eventIds = <String>[];
    DateTime currentDate = baseEvent.startDateTime;
    final endDate = baseEvent.recurrenceEndDate ?? 
                   baseEvent.startDateTime.add(const Duration(days: 365)); // Max 1 year
    
    while (currentDate.isBefore(endDate)) {
      final duration = baseEvent.endDateTime.difference(baseEvent.startDateTime);
      final eventCopy = baseEvent.copyWith(
        id: '', // New ID will be generated
        startDateTime: currentDate,
        endDateTime: currentDate.add(duration),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      try {
        final eventId = await createEvent(eventCopy);
        eventIds.add(eventId);
      } catch (e) {
        debugPrint('Error creating recurring event instance: $e');
      }
      
      // Move to next occurrence
      switch (baseEvent.recurrenceType) {
        case RecurrenceType.daily:
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case RecurrenceType.weekly:
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case RecurrenceType.biweekly:
          currentDate = currentDate.add(const Duration(days: 14));
          break;
        case RecurrenceType.monthly:
          currentDate = DateTime(currentDate.year, currentDate.month + 1, 
                                 currentDate.day, currentDate.hour, currentDate.minute);
          break;
        case RecurrenceType.custom:
          currentDate = _findNextCustomRecurrence(currentDate, baseEvent.customRecurrenceDays);
          break;
        case RecurrenceType.none:
          break;
      }
    }
    
    return eventIds;
  }

  /// Helper method for custom recurrence
  static DateTime _findNextCustomRecurrence(DateTime current, List<String>? customDays) {
    if (customDays == null || customDays.isEmpty) {
      return current.add(const Duration(days: 7));
    }
    
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final currentDayIndex = current.weekday - 1;
    
    for (int i = 1; i <= 7; i++) {
      final checkDayIndex = (currentDayIndex + i) % 7;
      final checkDayName = dayNames[checkDayIndex];
      
      if (customDays.contains(checkDayName)) {
        return current.add(Duration(days: i));
      }
    }
    
    return current.add(const Duration(days: 7));
  }

  /// Bulk operations
  static Future<void> bulkUpdateEventStatus(
    List<String> eventIds, 
    EventStatus newStatus,
  ) async {
    final batch = _firestore.batch();
    
    for (final eventId in eventIds) {
      final docRef = _eventsCollection.doc(eventId);
      batch.update(docRef, {
        'status': newStatus.name,
        'updatedAt': Timestamp.now(),
      });
    }
    
    try {
      await batch.commit();
      debugPrint('Bulk updated ${eventIds.length} events to status: ${newStatus.name}');
    } catch (e) {
      debugPrint('Error in bulk update: $e');
      throw Exception('Failed to bulk update events: $e');
    }
  }

  /// Delete all events for a market (use with caution)
  static Future<void> deleteAllEventsForMarket(String marketId) async {
    try {
      final snapshot = await _eventsCollection
          .where('marketId', isEqualTo: marketId)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      debugPrint('Deleted all events for market: $marketId');
    } catch (e) {
      debugPrint('Error deleting all events: $e');
      throw Exception('Failed to delete all events: $e');
    }
  }
}