import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_post.dart';

abstract class IVendorPostsRepository {
  Stream<List<VendorPost>> getVendorPosts(String vendorId);
  Stream<List<VendorPost>> getAllActivePosts();
  Future<String> createPost(VendorPost post);
  Future<void> updatePost(VendorPost post);
  Future<void> deletePost(String postId);
  Future<VendorPost?> getPost(String postId);
}

class VendorPostsRepository implements IVendorPostsRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'vendor_posts';

  VendorPostsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<VendorPost>> getVendorPosts(String vendorId) {
    return _firestore
        .collection(_collection)
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('popUpDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorPost.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<VendorPost>> getAllActivePosts() {
    final now = Timestamp.fromDate(DateTime.now());
    
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('popUpDateTime', isGreaterThanOrEqualTo: now)
        .orderBy('popUpDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorPost.fromFirestore(doc))
            .toList());
  }

  @override
  Future<String> createPost(VendorPost post) async {
    try {
      final docRef = await _firestore.collection(_collection).add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      throw VendorPostException('Failed to create post: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePost(VendorPost post) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(post.id)
          .update(post.copyWith(updatedAt: DateTime.now()).toFirestore());
    } catch (e) {
      throw VendorPostException('Failed to update post: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).delete();
    } catch (e) {
      throw VendorPostException('Failed to delete post: ${e.toString()}');
    }
  }

  @override
  Future<VendorPost?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(postId).get();
      
      if (doc.exists) {
        return VendorPost.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw VendorPostException('Failed to get post: ${e.toString()}');
    }
  }

  Future<List<VendorPost>> searchPosts({
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true);

      if (startDate != null) {
        query = query.where('popUpDateTime', 
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('popUpDateTime', 
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('popUpDateTime').limit(limit);

      final snapshot = await query.get();
      List<VendorPost> posts = snapshot.docs
          .map((doc) => VendorPost.fromFirestore(doc))
          .toList();

      // Filter by location on client side since Firestore doesn't support
      // complex text search
      if (location != null && location.isNotEmpty) {
        posts = posts.where((post) => 
            post.location.toLowerCase().contains(location.toLowerCase())
        ).toList();
      }

      return posts;
    } catch (e) {
      throw VendorPostException('Failed to search posts: ${e.toString()}');
    }
  }

  Future<List<VendorPost>> getPostsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 50,
  }) async {
    try {
      // Note: This is a simplified proximity search
      // For production, consider using GeoFlutterFire or similar
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('latitude', isNotEqualTo: null)
          .where('longitude', isNotEqualTo: null)
          .limit(limit * 2) // Get more to filter
          .get();

      final posts = snapshot.docs
          .map((doc) => VendorPost.fromFirestore(doc))
          .where((post) {
            if (post.latitude == null || post.longitude == null) return false;
            
            final distance = _calculateDistance(
              latitude, longitude, 
              post.latitude!, post.longitude!
            );
            
            return distance <= radiusInKm;
          })
          .take(limit)
          .toList();

      return posts;
    } catch (e) {
      throw VendorPostException('Failed to get nearby posts: ${e.toString()}');
    }
  }

  // Haversine formula for distance calculation
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

class VendorPostException implements Exception {
  final String message;
  
  VendorPostException(this.message);
  
  @override
  String toString() => message;
}