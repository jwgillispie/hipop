import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class VendorPost extends Equatable {
  final String id;
  final String vendorId;
  final String vendorName;
  final String description;
  final String location;
  final List<String> locationKeywords;
  final double? latitude;
  final double? longitude;
  final DateTime popUpDateTime;
  final String? instagramHandle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const VendorPost({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.description,
    required this.location,
    this.locationKeywords = const [],
    this.latitude,
    this.longitude,
    required this.popUpDateTime,
    this.instagramHandle,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory VendorPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    try {
      return VendorPost(
        id: doc.id,
        vendorId: data['vendorId'] ?? '',
        vendorName: data['vendorName'] ?? '',
        description: data['description'] ?? '',
        location: data['location'] ?? '',
        locationKeywords: List<String>.from(data['locationKeywords'] ?? []),
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        popUpDateTime: (data['popUpDateTime'] as Timestamp).toDate(),
        instagramHandle: data['instagramHandle'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isActive: data['isActive'] ?? true,
      );
    } catch (e) {
      print('Error parsing VendorPost from Firestore: $e');
      print('Document data: $data');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'description': description,
      'location': location,
      'locationKeywords': locationKeywords,
      'latitude': latitude,
      'longitude': longitude,
      'popUpDateTime': Timestamp.fromDate(popUpDateTime),
      'instagramHandle': instagramHandle,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  VendorPost copyWith({
    String? id,
    String? vendorId,
    String? vendorName,
    String? description,
    String? location,
    List<String>? locationKeywords,
    double? latitude,
    double? longitude,
    DateTime? popUpDateTime,
    String? instagramHandle,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return VendorPost(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      description: description ?? this.description,
      location: location ?? this.location,
      locationKeywords: locationKeywords ?? this.locationKeywords,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      popUpDateTime: popUpDateTime ?? this.popUpDateTime,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isUpcoming => popUpDateTime.isAfter(DateTime.now());
  bool get isHappening {
    final now = DateTime.now();
    final endTime = popUpDateTime.add(const Duration(hours: 4)); // Assume 4-hour pop-ups
    return now.isAfter(popUpDateTime) && now.isBefore(endTime);
  }
  bool get isPast {
    final endTime = popUpDateTime.add(const Duration(hours: 4));
    return DateTime.now().isAfter(endTime);
  }

  String get formattedDateTime {
    final now = DateTime.now();
    final difference = popUpDateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} from now';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} from now';
    } else if (difference.inMinutes > -60) {
      return 'Happening now!';
    } else {
      return 'Past event';
    }
  }

  static List<String> generateLocationKeywords(String location) {
    final keywords = <String>{};
    final normalizedLocation = location.toLowerCase().trim();
    
    keywords.add(normalizedLocation);
    
    final words = normalizedLocation.split(RegExp(r'[,\s]+'));
    for (final word in words) {
      if (word.isNotEmpty) {
        keywords.add(word);
        for (int i = 1; i <= word.length; i++) {
          keywords.add(word.substring(0, i));
        }
      }
    }
    
    final commonSynonyms = {
      'atlanta': ['atl', 'hotlanta'],
      'midtown': ['mid', 'midtown atlanta'],
      'buckhead': ['bhead'],
      'decatur': ['decatur ga'],
      'alpharetta': ['alpharetta ga', 'alph'],
      'virginia-highland': ['vahi', 'virginia highland'],
      'little five points': ['l5p', 'little 5 points'],
      'old fourth ward': ['o4w', 'old 4th ward'],
    };
    
    for (final entry in commonSynonyms.entries) {
      if (normalizedLocation.contains(entry.key)) {
        keywords.addAll(entry.value);
      }
    }
    
    return keywords.toList();
  }

  @override
  List<Object?> get props => [
        id,
        vendorId,
        vendorName,
        description,
        location,
        locationKeywords,
        latitude,
        longitude,
        popUpDateTime,
        instagramHandle,
        createdAt,
        updatedAt,
        isActive,
      ];
}