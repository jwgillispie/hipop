import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

abstract class IUserProfileService {
  Future<UserProfile?> getUserProfile(String userId);
  Future<UserProfile> createUserProfile({
    required String userId,
    required String userType,
    required String email,
    String? displayName,
  });
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
  Stream<UserProfile?> watchUserProfile(String userId);
}

class UserProfileService implements IUserProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _collection = 'user_profiles';

  UserProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  @override
  Future<UserProfile> createUserProfile({
    required String userId,
    required String userType,
    required String email,
    String? displayName,
  }) async {
    try {
      final now = DateTime.now();
      final profile = UserProfile(
        userId: userId,
        userType: userType,
        email: email,
        displayName: displayName,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection(_collection).doc(userId).set(profile.toFirestore());
      
      return profile;
    } catch (e) {
      throw UserProfileException('Failed to create user profile: $e');
    }
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      
      await _firestore
          .collection(_collection)
          .doc(profile.userId)
          .update(updatedProfile.toFirestore());

      // Also update Firebase Auth display name if it changed
      final user = _auth.currentUser;
      if (user != null && 
          user.uid == profile.userId && 
          user.displayName != updatedProfile.displayName) {
        await user.updateDisplayName(updatedProfile.displayName);
        await user.reload();
      }

      return updatedProfile;
    } catch (e) {
      throw UserProfileException('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw UserProfileException('Failed to delete user profile: $e');
    }
  }

  @override
  Stream<UserProfile?> watchUserProfile(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserProfile.fromFirestore(doc);
          }
          return null;
        });
  }

  // Helper method to create or get profile for current user
  Future<UserProfile> ensureUserProfile({
    required String userType,
    String? displayName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw UserProfileException('No authenticated user');
    }

    // Try to get existing profile
    UserProfile? profile = await getUserProfile(user.uid);
    
    if (profile == null) {
      // Create new profile
      profile = await createUserProfile(
        userId: user.uid,
        userType: userType,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName,
      );
    }

    return profile;
  }

  // Helper method to update only specific fields
  Future<UserProfile> updateUserProfileFields(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final profile = await getUserProfile(userId);
      if (profile == null) {
        throw UserProfileException('User profile not found');
      }

      // Add updatedAt timestamp
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore
          .collection(_collection)
          .doc(userId)
          .update(updates);

      // Return updated profile
      final updatedProfile = await getUserProfile(userId);
      if (updatedProfile == null) {
        throw UserProfileException('Failed to retrieve updated profile');
      }

      return updatedProfile;
    } catch (e) {
      throw UserProfileException('Failed to update profile fields: $e');
    }
  }

  // Helper method to check if profile exists
  Future<bool> profileExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking profile existence: $e');
      return false;
    }
  }

  // Helper method to get profiles by user type
  Future<List<UserProfile>> getProfilesByUserType(String userType) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userType', isEqualTo: userType)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting profiles by user type: $e');
      return [];
    }
  }

  // Helper method to search profiles by display name or business name
  Future<List<UserProfile>> searchProfiles(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) return [];

      final searchLower = searchTerm.toLowerCase();
      
      // Get all profiles and filter client-side since Firestore doesn't support
      // case-insensitive or contains queries natively
      final querySnapshot = await _firestore.collection(_collection).get();
      
      final profiles = querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .where((profile) {
            final displayName = profile.displayName?.toLowerCase() ?? '';
            final businessName = profile.businessName?.toLowerCase() ?? '';
            final email = profile.email.toLowerCase();
            
            return displayName.contains(searchLower) ||
                   businessName.contains(searchLower) ||
                   email.contains(searchLower);
          })
          .toList();

      return profiles;
    } catch (e) {
      debugPrint('Error searching profiles: $e');
      return [];
    }
  }

  // Helper method to get vendor profiles with categories
  Future<List<UserProfile>> getVendorsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userType', isEqualTo: 'vendor')
          .where('categories', arrayContains: category)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting vendors by category: $e');
      return [];
    }
  }

  // Helper method to migrate existing user to profile system
  Future<UserProfile?> migrateUserToProfile(User user, String userType) async {
    try {
      // Check if profile already exists
      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile != null) {
        return existingProfile;
      }

      // Create new profile from Firebase Auth user
      return await createUserProfile(
        userId: user.uid,
        userType: userType,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    } catch (e) {
      debugPrint('Error migrating user to profile: $e');
      return null;
    }
  }
}

class UserProfileException implements Exception {
  final String message;
  
  UserProfileException(this.message);
  
  @override
  String toString() => 'UserProfileException: $message';
}