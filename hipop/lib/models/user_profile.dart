import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String userType; // 'vendor' or 'shopper'
  final String email;
  final String? displayName;
  final String? businessName; // For vendors
  final String? bio;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? website;
  final List<String> categories; // For vendors - what they sell
  final Map<String, dynamic> preferences; // General user preferences
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.userType,
    required this.email,
    this.displayName,
    this.businessName,
    this.bio,
    this.instagramHandle,
    this.phoneNumber,
    this.website,
    this.categories = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a copy with updated fields
  UserProfile copyWith({
    String? userId,
    String? userType,
    String? email,
    String? displayName,
    String? businessName,
    String? bio,
    String? instagramHandle,
    String? phoneNumber,
    String? website,
    List<String>? categories,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      bio: bio ?? this.bio,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      categories: categories ?? this.categories,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userType': userType,
      'email': email,
      'displayName': displayName,
      'businessName': businessName,
      'bio': bio,
      'instagramHandle': instagramHandle,
      'phoneNumber': phoneNumber,
      'website': website,
      'categories': categories,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserProfile(
      userId: data['userId'] ?? doc.id,
      userType: data['userType'] ?? 'shopper',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      businessName: data['businessName'],
      bio: data['bio'],
      instagramHandle: data['instagramHandle'],
      phoneNumber: data['phoneNumber'],
      website: data['website'],
      categories: List<String>.from(data['categories'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Firestore document with explicit ID
  factory UserProfile.fromFirestoreWithId(String id, Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] ?? id,
      userType: data['userType'] ?? 'shopper',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      businessName: data['businessName'],
      bio: data['bio'],
      instagramHandle: data['instagramHandle'],
      phoneNumber: data['phoneNumber'],
      website: data['website'],
      categories: List<String>.from(data['categories'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Helper method to get full name or business name for display
  String get displayTitle {
    if (userType == 'vendor' && businessName != null && businessName!.isNotEmpty) {
      return businessName!;
    }
    return displayName ?? email.split('@').first;
  }

  // Helper method to check if profile is complete
  bool get isProfileComplete {
    final hasBasicInfo = displayName != null && displayName!.isNotEmpty;
    
    if (userType == 'vendor') {
      // Vendors need business name or display name
      return hasBasicInfo || (businessName != null && businessName!.isNotEmpty);
    } else {
      // Shoppers just need display name
      return hasBasicInfo;
    }
  }

  // Helper method to get profile completion percentage
  double get profileCompletionPercentage {
    int totalFields = userType == 'vendor' ? 7 : 4; // Different expectations for vendors vs shoppers
    int completedFields = 0;

    // Always required
    if (email.isNotEmpty) completedFields++;
    if (displayName != null && displayName!.isNotEmpty) completedFields++;

    if (userType == 'vendor') {
      // Vendor-specific fields
      if (businessName != null && businessName!.isNotEmpty) completedFields++;
      if (bio != null && bio!.isNotEmpty) completedFields++;
      if (instagramHandle != null && instagramHandle!.isNotEmpty) completedFields++;
      if (categories.isNotEmpty) completedFields++;
      if (website != null && website!.isNotEmpty) completedFields++;
    } else {
      // Shopper-specific fields
      if (bio != null && bio!.isNotEmpty) completedFields++;
      if (instagramHandle != null && instagramHandle!.isNotEmpty) completedFields++;
    }

    return completedFields / totalFields;
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, userType: $userType, email: $email, displayName: $displayName, businessName: $businessName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserProfile &&
        other.userId == userId &&
        other.userType == userType &&
        other.email == email &&
        other.displayName == displayName &&
        other.businessName == businessName &&
        other.bio == bio &&
        other.instagramHandle == instagramHandle &&
        other.phoneNumber == phoneNumber &&
        other.website == website;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        userType.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        businessName.hashCode ^
        bio.hashCode ^
        instagramHandle.hashCode ^
        phoneNumber.hashCode ^
        website.hashCode;
  }
}