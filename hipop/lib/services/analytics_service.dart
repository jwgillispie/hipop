import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/analytics.dart';
import '../models/vendor_application.dart';
import '../models/market_event.dart';
import '../models/recipe.dart';

class AnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _analyticsCollection =
      _firestore.collection('market_analytics');

  /// Generate and store daily analytics for a market
  static Future<void> generateDailyAnalytics(
    String marketId,
    String organizerId,
  ) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      // Get vendor metrics
      final vendorMetrics = await _getVendorMetrics(marketId);
      
      // Get event metrics
      final eventMetrics = await _getEventMetrics(marketId);
      
      // Get recipe metrics
      final recipeMetrics = await _getRecipeMetrics(marketId);
      
      // Create analytics record
      final analytics = MarketAnalytics(
        marketId: marketId,
        organizerId: organizerId,
        date: startOfDay,
        totalVendors: vendorMetrics['total'] ?? 0,
        activeVendors: vendorMetrics['active'] ?? 0,
        newVendorApplications: vendorMetrics['newApplications'] ?? 0,
        approvedApplications: vendorMetrics['approved'] ?? 0,
        rejectedApplications: vendorMetrics['rejected'] ?? 0,
        totalEvents: eventMetrics['total'] ?? 0,
        publishedEvents: eventMetrics['published'] ?? 0,
        completedEvents: eventMetrics['completed'] ?? 0,
        upcomingEvents: eventMetrics['upcoming'] ?? 0,
        averageEventOccupancy: eventMetrics['averageOccupancy'] ?? 0.0,
        totalRecipes: recipeMetrics['total'] ?? 0,
        publicRecipes: recipeMetrics['public'] ?? 0,
        featuredRecipes: recipeMetrics['featured'] ?? 0,
        totalRecipeLikes: recipeMetrics['likes'] ?? 0,
        totalRecipeSaves: recipeMetrics['saves'] ?? 0,
        totalRecipeShares: recipeMetrics['shares'] ?? 0,
      );
      
      // Store or update analytics
      final docId = '${marketId}_${startOfDay.millisecondsSinceEpoch}';
      await _analyticsCollection.doc(docId).set(analytics.toFirestore());
      
      debugPrint('Daily analytics generated for market: $marketId');
    } catch (e) {
      debugPrint('Error generating daily analytics: $e');
      throw Exception('Failed to generate analytics: $e');
    }
  }

  /// Get analytics summary for a market over a time range
  static Future<AnalyticsSummary> getAnalyticsSummary(
    String marketId,
    AnalyticsTimeRange timeRange,
  ) async {
    try {
      debugPrint('Getting analytics summary for market: $marketId, timeRange: ${timeRange.displayName}');
      
      // Get real-time metrics instead of stored analytics for now
      final realTimeMetrics = await getRealTimeMetrics(marketId);
      
      final vendorMetrics = realTimeMetrics['vendors'] as Map<String, dynamic>? ?? {};
      final eventMetrics = realTimeMetrics['events'] as Map<String, dynamic>? ?? {};
      final recipeMetrics = realTimeMetrics['recipes'] as Map<String, dynamic>? ?? {};
      
      // Get current breakdowns
      final vendorApplicationsByStatus = await _getVendorApplicationBreakdown(marketId);
      final eventsByStatus = await _getEventStatusBreakdown(marketId);
      final recipesByCategory = await _getRecipeCategoryBreakdown(marketId);
      
      return AnalyticsSummary(
        totalVendors: vendorMetrics['total'] ?? 0,
        totalEvents: eventMetrics['total'] ?? 0,
        totalRecipes: recipeMetrics['total'] ?? 0,
        totalViews: 0, // No view tracking yet
        growthRate: 0.0, // Calculate when we have historical data
        vendorApplicationsByStatus: vendorApplicationsByStatus,
        eventsByStatus: eventsByStatus,
        recipesByCategory: recipesByCategory,
        dailyData: [], // No historical data yet
      );
    } catch (e) {
      debugPrint('Error getting analytics summary: $e');
      // Return empty summary instead of throwing
      return const AnalyticsSummary();
    }
  }

  /// Get real-time metrics for dashboard
  static Future<Map<String, dynamic>> getRealTimeMetrics(String marketId) async {
    try {
      debugPrint('Getting real-time metrics for market: $marketId');
      
      final vendorMetrics = await _getVendorMetrics(marketId);
      final eventMetrics = await _getEventMetrics(marketId);
      final recipeMetrics = await _getRecipeMetrics(marketId);
      
      debugPrint('Vendor metrics: $vendorMetrics');
      debugPrint('Event metrics: $eventMetrics');
      debugPrint('Recipe metrics: $recipeMetrics');
      
      return {
        'vendors': vendorMetrics,
        'events': eventMetrics,
        'recipes': recipeMetrics,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Error getting real-time metrics: $e');
      // Return default metrics instead of throwing
      return {
        'vendors': {'total': 0, 'active': 0, 'pending': 0, 'approved': 0, 'rejected': 0},
        'events': {'total': 0, 'published': 0, 'upcoming': 0, 'completed': 0, 'averageOccupancy': 0.0},
        'recipes': {'total': 0, 'public': 0, 'featured': 0, 'likes': 0, 'saves': 0, 'shares': 0},
        'lastUpdated': DateTime.now(),
      };
    }
  }

  /// Private helper methods
  static Future<Map<String, dynamic>> _getVendorMetrics(String marketId) async {
    try {
      debugPrint('Getting vendor metrics for market: $marketId');
      
      // Get vendor applications
      final applicationsSnapshot = await _firestore
          .collection('vendor_applications')
          .where('marketId', isEqualTo: marketId)
          .get();
      
      debugPrint('Found ${applicationsSnapshot.docs.length} vendor applications');
      
      final applications = applicationsSnapshot.docs
          .map((doc) => VendorApplication.fromFirestore(doc))
          .toList();
      
      final today = DateTime.now();
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      
      final metrics = {
        'total': applications.length,
        'active': applications.where((app) => app.status == ApplicationStatus.approved).length,
        'newApplications': applications.where((app) => 
            app.createdAt.isAfter(thirtyDaysAgo)).length,
        'approved': applications.where((app) => app.status == ApplicationStatus.approved).length,
        'rejected': applications.where((app) => app.status == ApplicationStatus.rejected).length,
        'pending': applications.where((app) => app.status == ApplicationStatus.pending).length,
      };
      
      debugPrint('Vendor metrics calculated: $metrics');
      return metrics;
    } catch (e) {
      debugPrint('Error getting vendor metrics: $e');
      return {'total': 0, 'active': 0, 'newApplications': 0, 'approved': 0, 'rejected': 0, 'pending': 0};
    }
  }

  static Future<Map<String, dynamic>> _getEventMetrics(String marketId) async {
    try {
      debugPrint('Getting event metrics for market: $marketId');
      
      final eventsSnapshot = await _firestore
          .collection('market_events')
          .where('marketId', isEqualTo: marketId)
          .get();
      
      debugPrint('Found ${eventsSnapshot.docs.length} market events');
      
      final events = eventsSnapshot.docs
          .map((doc) => MarketEvent.fromFirestore(doc))
          .toList();
      
      final now = DateTime.now();
      final upcoming = events.where((event) => 
          event.startDateTime.isAfter(now) && 
          event.status == EventStatus.published).length;
      
      final completed = events.where((event) => 
          event.endDateTime.isBefore(now) && 
          event.status == EventStatus.published).length;
      
      // Calculate average occupancy
      double totalOccupancy = 0.0;
      int occupancyCount = 0;
      for (final event in events) {
        if (event.maxVendorSlots > 0) {
          totalOccupancy += event.occupancyRate;
          occupancyCount++;
        }
      }
      
      final metrics = {
        'total': events.length,
        'published': events.where((e) => e.status == EventStatus.published).length,
        'draft': events.where((e) => e.status == EventStatus.draft).length,
        'completed': completed,
        'upcoming': upcoming,
        'averageOccupancy': occupancyCount > 0 ? totalOccupancy / occupancyCount : 0.0,
      };
      
      debugPrint('Event metrics calculated: $metrics');
      return metrics;
    } catch (e) {
      debugPrint('Error getting event metrics: $e');
      return {'total': 0, 'published': 0, 'draft': 0, 'completed': 0, 'upcoming': 0, 'averageOccupancy': 0.0};
    }
  }

  static Future<Map<String, dynamic>> _getRecipeMetrics(String marketId) async {
    try {
      debugPrint('Getting recipe metrics for market: $marketId');
      
      final recipesSnapshot = await _firestore
          .collection('recipes')
          .where('marketId', isEqualTo: marketId)
          .get();
      
      debugPrint('Found ${recipesSnapshot.docs.length} recipes');
      
      final recipes = recipesSnapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();
      
      final totalLikes = recipes.fold(0, (total, recipe) => total + recipe.likes);
      final totalSaves = recipes.fold(0, (total, recipe) => total + recipe.saves);
      final totalShares = recipes.fold(0, (total, recipe) => total + recipe.shares);
      
      final metrics = {
        'total': recipes.length,
        'public': recipes.where((r) => r.isPublic).length,
        'featured': recipes.where((r) => r.isFeatured).length,
        'likes': totalLikes,
        'saves': totalSaves,
        'shares': totalShares,
      };
      
      debugPrint('Recipe metrics calculated: $metrics');
      return metrics;
    } catch (e) {
      debugPrint('Error getting recipe metrics: $e');
      return {'total': 0, 'public': 0, 'featured': 0, 'likes': 0, 'saves': 0, 'shares': 0};
    }
  }

  static Future<Map<String, int>> _getVendorApplicationBreakdown(String marketId) async {
    try {
      final snapshot = await _firestore
          .collection('vendor_applications')
          .where('marketId', isEqualTo: marketId)
          .get();
      
      final applications = snapshot.docs
          .map((doc) => VendorApplication.fromFirestore(doc))
          .toList();
      
      return {
        'pending': applications.where((app) => app.status == ApplicationStatus.pending).length,
        'approved': applications.where((app) => app.status == ApplicationStatus.approved).length,
        'rejected': applications.where((app) => app.status == ApplicationStatus.rejected).length,
      };
    } catch (e) {
      debugPrint('Error getting vendor application breakdown: $e');
      return {};
    }
  }

  static Future<Map<String, int>> _getEventStatusBreakdown(String marketId) async {
    try {
      final snapshot = await _firestore
          .collection('market_events')
          .where('marketId', isEqualTo: marketId)
          .get();
      
      final events = snapshot.docs
          .map((doc) => MarketEvent.fromFirestore(doc))
          .toList();
      
      return {
        'draft': events.where((e) => e.status == EventStatus.draft).length,
        'published': events.where((e) => e.status == EventStatus.published).length,
        'cancelled': events.where((e) => e.status == EventStatus.cancelled).length,
      };
    } catch (e) {
      debugPrint('Error getting event status breakdown: $e');
      return {};
    }
  }

  static Future<Map<String, int>> _getRecipeCategoryBreakdown(String marketId) async {
    try {
      final snapshot = await _firestore
          .collection('recipes')
          .where('marketId', isEqualTo: marketId)
          .get();
      
      final recipes = snapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();
      
      final breakdown = <String, int>{};
      for (final category in RecipeCategory.values) {
        breakdown[category.name] = recipes
            .where((r) => r.category == category)
            .length;
      }
      
      return breakdown;
    } catch (e) {
      debugPrint('Error getting recipe category breakdown: $e');
      return {};
    }
  }


  /// Export analytics data
  static Future<List<MarketAnalytics>> exportAnalyticsData(
    String marketId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _analyticsCollection
          .where('marketId', isEqualTo: marketId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => MarketAnalytics.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error exporting analytics data: $e');
      throw Exception('Failed to export analytics data: $e');
    }
  }

  /// Get top performing metrics
  static Future<Map<String, dynamic>> getTopPerformingMetrics(String marketId) async {
    try {
      // Get top recipes by engagement
      final recipesSnapshot = await _firestore
          .collection('recipes')
          .where('marketId', isEqualTo: marketId)
          .orderBy('likes', descending: true)
          .limit(5)
          .get();
      
      final topRecipes = recipesSnapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();
      
      // Get upcoming events by occupancy
      final eventsSnapshot = await _firestore
          .collection('market_events')
          .where('marketId', isEqualTo: marketId)
          .where('status', isEqualTo: EventStatus.published.name)
          .get();
      
      final events = eventsSnapshot.docs
          .map((doc) => MarketEvent.fromFirestore(doc))
          .toList();
      
      events.sort((a, b) => b.occupancyRate.compareTo(a.occupancyRate));
      final topEvents = events.take(5).toList();
      
      return {
        'topRecipes': topRecipes,
        'topEvents': topEvents,
      };
    } catch (e) {
      debugPrint('Error getting top performing metrics: $e');
      return {};
    }
  }
}