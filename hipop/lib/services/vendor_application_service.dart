import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/vendor_application.dart';

class VendorApplicationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _applicationsCollection = 
      _firestore.collection('vendor_applications');

  /// Submit a new vendor application
  static Future<String> submitApplication(VendorApplication application) async {
    try {
      final docRef = await _applicationsCollection.add(application.toFirestore());
      debugPrint('Vendor application submitted with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error submitting vendor application: $e');
      throw Exception('Failed to submit application: $e');
    }
  }

  /// Get all applications for a specific market
  static Stream<List<VendorApplication>> getApplicationsForMarket(String marketId) {
    return _applicationsCollection
        .where('marketId', isEqualTo: marketId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorApplication.fromFirestore(doc))
            .toList());
  }

  /// Get applications by status for a specific market
  static Stream<List<VendorApplication>> getApplicationsByStatus(
    String marketId, 
    ApplicationStatus status,
  ) {
    return _applicationsCollection
        .where('marketId', isEqualTo: marketId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorApplication.fromFirestore(doc))
            .toList());
  }

  /// Get applications for a specific vendor
  static Stream<List<VendorApplication>> getApplicationsForVendor(String vendorId) {
    return _applicationsCollection
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorApplication.fromFirestore(doc))
            .toList());
  }

  /// Update application status (approve, reject, waitlist)
  static Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus newStatus,
    String reviewerId, {
    String? reviewNotes,
  }) async {
    try {
      await _applicationsCollection.doc(applicationId).update({
        'status': newStatus.name,
        'reviewedBy': reviewerId,
        'reviewedAt': Timestamp.now(),
        'reviewNotes': reviewNotes,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('Application $applicationId updated to status: ${newStatus.name}');
    } catch (e) {
      debugPrint('Error updating application status: $e');
      throw Exception('Failed to update application: $e');
    }
  }

  /// Approve an application
  static Future<void> approveApplication(
    String applicationId,
    String reviewerId, {
    String? notes,
  }) async {
    await updateApplicationStatus(
      applicationId,
      ApplicationStatus.approved,
      reviewerId,
      reviewNotes: notes,
    );
  }

  /// Reject an application
  static Future<void> rejectApplication(
    String applicationId,
    String reviewerId, {
    String? notes,
  }) async {
    await updateApplicationStatus(
      applicationId,
      ApplicationStatus.rejected,
      reviewerId,
      reviewNotes: notes,
    );
  }

  /// Waitlist an application
  static Future<void> waitlistApplication(
    String applicationId,
    String reviewerId, {
    String? notes,
  }) async {
    await updateApplicationStatus(
      applicationId,
      ApplicationStatus.waitlisted,
      reviewerId,
      reviewNotes: notes,
    );
  }

  /// Get application statistics for a market
  static Future<Map<String, int>> getApplicationStats(String marketId) async {
    try {
      final snapshot = await _applicationsCollection
          .where('marketId', isEqualTo: marketId)
          .get();
      
      final applications = snapshot.docs
          .map((doc) => VendorApplication.fromFirestore(doc))
          .toList();
      
      final stats = <String, int>{
        'total': applications.length,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'waitlisted': 0,
      };
      
      for (final app in applications) {
        switch (app.status) {
          case ApplicationStatus.pending:
            stats['pending'] = stats['pending']! + 1;
            break;
          case ApplicationStatus.approved:
            stats['approved'] = stats['approved']! + 1;
            break;
          case ApplicationStatus.rejected:
            stats['rejected'] = stats['rejected']! + 1;
            break;
          case ApplicationStatus.waitlisted:
            stats['waitlisted'] = stats['waitlisted']! + 1;
            break;
        }
      }
      
      return stats;
    } catch (e) {
      debugPrint('Error getting application stats: $e');
      throw Exception('Failed to get application statistics: $e');
    }
  }

  /// Get a single application by ID
  static Future<VendorApplication?> getApplication(String applicationId) async {
    try {
      final doc = await _applicationsCollection.doc(applicationId).get();
      if (doc.exists) {
        return VendorApplication.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting application: $e');
      throw Exception('Failed to get application: $e');
    }
  }

  /// Update application details (before review)
  static Future<void> updateApplication(
    String applicationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _applicationsCollection.doc(applicationId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('Application $applicationId updated');
    } catch (e) {
      debugPrint('Error updating application: $e');
      throw Exception('Failed to update application: $e');
    }
  }

  /// Delete an application (usually only for pending applications)
  static Future<void> deleteApplication(String applicationId) async {
    try {
      await _applicationsCollection.doc(applicationId).delete();
      debugPrint('Application $applicationId deleted');
    } catch (e) {
      debugPrint('Error deleting application: $e');
      throw Exception('Failed to delete application: $e');
    }
  }

  /// Check if a vendor has already applied to a specific market
  static Future<bool> hasVendorApplied(String vendorId, String marketId) async {
    try {
      final snapshot = await _applicationsCollection
          .where('vendorId', isEqualTo: vendorId)
          .where('marketId', isEqualTo: marketId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking vendor application: $e');
      return false;
    }
  }

  /// Get pending applications count for a market (for dashboard)
  static Future<int> getPendingApplicationsCount(String marketId) async {
    try {
      final snapshot = await _applicationsCollection
          .where('marketId', isEqualTo: marketId)
          .where('status', isEqualTo: ApplicationStatus.pending.name)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting pending applications count: $e');
      return 0;
    }
  }
}