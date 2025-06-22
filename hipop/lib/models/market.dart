import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Market extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String? placeId;
  final Map<String, String> operatingDays; // {"saturday": "9AM-2PM", "sunday": "11AM-4PM"}
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const Market({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.operatingDays = const {},
    this.description,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory Market.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    try {
      return Market(
        id: doc.id,
        name: data['name'] ?? '',
        address: data['address'] ?? '',
        city: data['city'] ?? '',
        state: data['state'] ?? '',
        latitude: data['latitude']?.toDouble() ?? 0.0,
        longitude: data['longitude']?.toDouble() ?? 0.0,
        placeId: data['placeId'],
        operatingDays: data['operatingDays'] != null 
            ? Map<String, String>.from(data['operatingDays']) 
            : {},
        description: data['description'],
        imageUrl: data['imageUrl'],
        isActive: data['isActive'] ?? true,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Market from Firestore: $e');
      print('Document data: $data');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
      'operatingDays': operatingDays,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Market copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    String? placeId,
    Map<String, String>? operatingDays,
    String? description,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Market(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      operatingDays: operatingDays ?? this.operatingDays,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get fullAddress => '$address, $city, $state';
  
  bool get isOpenToday {
    final today = DateTime.now().weekday;
    final dayName = _getDayName(today);
    return operatingDays.containsKey(dayName);
  }
  
  String? get todaysHours {
    final today = DateTime.now().weekday;
    final dayName = _getDayName(today);
    return operatingDays[dayName];
  }
  
  List<String> get operatingDaysList {
    return operatingDays.keys.toList();
  }
  
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return '';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        state,
        latitude,
        longitude,
        placeId,
        operatingDays,
        description,
        imageUrl,
        isActive,
        createdAt,
      ];
}