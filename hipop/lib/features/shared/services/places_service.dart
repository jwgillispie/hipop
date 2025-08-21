import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  // Google Places API direct URL (temporary until proxy server is fixed)
  static const String _googlePlacesApiUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _apiKey = 'AIzaSyCN_xQaOJShwabeuTLOPe1OYxXi4GVLbH4';
  
  // Production server URL (currently down - needs to be redeployed)
  // static const String _productionApiUrl = 'https://hipop-places-server-977869241732.us-central1.run.app/api/places';

  static String get _baseUrl {
    // Temporarily use Google Places API directly until proxy server is fixed
    return _googlePlacesApiUrl;
  }

  static Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.length < 3) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$_apiKey&components=country:us'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List? ?? [];
          
          return predictions
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();
        } else {
          debugPrint('Places API error: ${data['status']}');
        }
      } else {
        debugPrint('Places API returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting place predictions: $e');
    }
    
    return [];
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/details/json?place_id=$placeId&key=$_apiKey&fields=geometry,formatted_address,name'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          return PlaceDetails.fromJson(data['result']);
        } else {
          debugPrint('Place details API error: ${data['status']}');
        }
      } else {
        debugPrint('Place details API returned status: ${response.statusCode}');
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

  factory PlacePrediction.fromWebJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
    );
  }
  
  // Direct Google Places API format
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']?['main_text'] ?? json['description'],
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
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

  factory PlaceDetails.fromWebJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return PlaceDetails(
      placeId: json['place_id'],
      name: json['name'] ?? json['formatted_address'],
      formattedAddress: json['formatted_address'],
      latitude: geometry['lat'].toDouble(),
      longitude: geometry['lng'].toDouble(),
    );
  }
  
  // Direct Google Places API format
  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']?['location'] ?? {};
    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? json['formatted_address'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      latitude: (geometry['lat'] ?? 0.0).toDouble(),
      longitude: (geometry['lng'] ?? 0.0).toDouble(),
    );
  }
}