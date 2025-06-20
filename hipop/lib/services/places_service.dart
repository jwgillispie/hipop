import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  static String get _baseUrl {
    // For web, we need to use the full localhost URL
    // For mobile, localhost works fine
    if (kIsWeb) {
      // Try different common Flutter web dev server ports
      return 'http://127.0.0.1:3000/api/places';
    }
    return 'http://localhost:3000/api/places';
  }

  static Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.length < 3) {
      return [];
    }

    // For web, try multiple URLs if one fails
    final urlsToTry = kIsWeb ? [
      'http://127.0.0.1:3000/api/places',
      'http://localhost:3000/api/places',
    ] : ['http://localhost:3000/api/places'];

    for (final baseUrl in urlsToTry) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/autocomplete?input=${Uri.encodeComponent(input)}'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final predictions = data['predictions'] as List? ?? [];
          
          return predictions
              .map((prediction) => PlacePrediction.fromServerJson(prediction))
              .toList();
        }
      } catch (e) {
        debugPrint('Error with $baseUrl: $e');
        if (baseUrl == urlsToTry.last) {
          debugPrint('All URLs failed. Server might not be running or CORS issue.');
        }
        continue;
      }
    }
    
    return [];
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/details?place_id=$placeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        
        if (result != null) {
          return PlaceDetails.fromServerJson(result);
        }
      } else {
        throw Exception('Failed to load place details');
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
    }
    
    return null;
  }
}

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromServerJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromServerJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return PlaceDetails(
      placeId: json['place_id'],
      name: json['name'] ?? json['formatted_address'],
      formattedAddress: json['formatted_address'],
      latitude: geometry['lat'].toDouble(),
      longitude: geometry['lng'].toDouble(),
    );
  }
}