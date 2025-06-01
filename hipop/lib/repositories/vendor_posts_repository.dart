import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_post.dart';

abstract class IVendorPostsRepository {
  Stream<List<VendorPost>> getVendorPosts(String vendorId);
  Stream<List<VendorPost>> getAllActivePosts();
  Stream<List<VendorPost>> searchPostsByLocation(String location);
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
    print('=== getAllActivePosts DEBUG ===');
    print('Current time: ${DateTime.now()}');
    
    // For now, show ALL posts regardless of date to debug
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('popUpDateTime', descending: true) // Latest first
        .snapshots()
        .map((snapshot) {
          print('Found ${snapshot.docs.length} active posts');
          
          final posts = snapshot.docs
              .map((doc) => VendorPost.fromFirestore(doc))
              .toList();
          
          for (final post in posts) {
            print('Post: ${post.vendorName} at ${post.location} on ${post.popUpDateTime}');
            print('  Active: ${post.isActive}');
            print('  Keywords: ${post.locationKeywords}');
          }
          
          return posts;
        });
  }

  @override
  Stream<List<VendorPost>> searchPostsByLocation(String location) {
    if (location.isEmpty) {
      return getAllActivePosts();
    }

    final searchKeyword = location.toLowerCase().trim();
    print('=== SEARCH DEBUG ===');
    print('Searching for: "$searchKeyword"');
    
    // Use a simpler approach - get all posts and filter client-side
    // This ensures we catch everything during debugging
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('popUpDateTime', descending: true) // Show latest first
        .snapshots()
        .map((snapshot) {
          print('Total posts in query: ${snapshot.docs.length}');
          
          final allPosts = snapshot.docs
              .map((doc) => VendorPost.fromFirestore(doc))
              .toList();
          
          print('Converted posts: ${allPosts.length}');
          
          // Filter by location
          final filteredPosts = allPosts.where((post) {
            final locationMatch = post.location.toLowerCase().contains(searchKeyword);
            final keywordMatch = post.locationKeywords.any((keyword) => 
                keyword.toLowerCase().contains(searchKeyword));
            
            final matches = locationMatch || keywordMatch;
            
            if (matches) {
              print('MATCH: ${post.vendorName} at ${post.location}');
              print('  Location keywords: ${post.locationKeywords}');
              print('  Date: ${post.popUpDateTime}');
            }
            
            return matches;
          }).toList();
          
          print('Filtered results: ${filteredPosts.length}');
          print('=== END SEARCH DEBUG ===');
          
          return filteredPosts;
        });
  }

  @override
  Future<String> createPost(VendorPost post) async {
    try {
      final postWithKeywords = post.copyWith(
        locationKeywords: VendorPost.generateLocationKeywords(post.location),
      );
      final docRef = await _firestore.collection(_collection).add(postWithKeywords.toFirestore());
      return docRef.id;
    } catch (e) {
      throw VendorPostException('Failed to create post: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePost(VendorPost post) async {
    try {
      final postWithKeywords = post.copyWith(
        locationKeywords: VendorPost.generateLocationKeywords(post.location),
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(_collection)
          .doc(post.id)
          .update(postWithKeywords.toFirestore());
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

  // Migration function to update existing posts with location keywords
  Future<void> migratePostsWithLocationKeywords() async {
    try {
      print('Starting migration of posts with location keywords...');
      
      // Get all posts and check them individually since Firestore isNull queries can be tricky
      final snapshot = await _firestore
          .collection(_collection)
          .get();

      final batch = _firestore.batch();
      int updateCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // Check if locationKeywords field is missing or empty
        if (!data.containsKey('locationKeywords') || 
            data['locationKeywords'] == null || 
            (data['locationKeywords'] is List && (data['locationKeywords'] as List).isEmpty)) {
          
          final location = data['location'] ?? '';
          if (location.isNotEmpty) {
            final keywords = VendorPost.generateLocationKeywords(location);
            
            batch.update(doc.reference, {'locationKeywords': keywords});
            updateCount++;
            
            print('Updating post: ${data['vendorName'] ?? 'Unknown'} at $location');
            print('Generated keywords: $keywords');
          }
        }
      }

      if (updateCount > 0) {
        await batch.commit();
        print('Migration completed: Updated $updateCount posts with location keywords');
      } else {
        print('Migration completed: No posts needed updating');
      }
    } catch (e) {
      print('Migration failed: ${e.toString()}');
      throw VendorPostException('Failed to migrate posts: ${e.toString()}');
    }
  }

  // Helper method to check if migration is needed
  Future<bool> needsMigration() async {
    try {
      // Get a few posts and check if they need migration
      final snapshot = await _firestore
          .collection(_collection)
          .limit(5)
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('locationKeywords') || 
            data['locationKeywords'] == null ||
            (data['locationKeywords'] is List && (data['locationKeywords'] as List).isEmpty)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return true; // If we can't check, assume migration is needed
    }
  }

  // Debug method to see all posts in Firestore
  Future<void> debugAllPosts() async {
    try {
      print('=== DEBUG: All posts in Firestore ===');
      final snapshot = await _firestore
          .collection(_collection)
          .get();
      
      print('Total posts found: ${snapshot.docs.length}');
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('---');
        print('ID: ${doc.id}');
        print('Vendor: ${data['vendorName'] ?? 'Unknown'}');
        print('Location: ${data['location'] ?? 'No location'}');
        print('Keywords: ${data['locationKeywords'] ?? 'No keywords'}');
        print('Date: ${data['popUpDateTime']?.toDate() ?? 'No date'}');
        print('Active: ${data['isActive'] ?? 'No active field'}');
      }
      print('=== END DEBUG ===');
    } catch (e) {
      print('Debug failed: $e');
    }
  }

  // Get ALL posts (including past ones) for debugging
  Stream<List<VendorPost>> getAllPostsForDebug() {
    return _firestore
        .collection(_collection)
        .orderBy('popUpDateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorPost.fromFirestore(doc))
            .toList());
  }
}

class VendorPostException implements Exception {
  final String message;
  
  VendorPostException(this.message);
  
  @override
  String toString() => message;
}