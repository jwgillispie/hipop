import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:js_util' as js_util if (dart.library.html) 'dart:js_util';

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

    // For web, use direct Google Places API
    if (kIsWeb) {
      return _getWebPlacePredictions(input);
    }

    // For mobile, use server proxy
    final urlsToTry = ['http://localhost:3000/api/places'];

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
    // For web, use direct Google Places API
    if (kIsWeb) {
      return _getWebPlaceDetails(placeId);
    }

    // For mobile, use server proxy
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

  // Web-specific implementations using Google Places JavaScript API
  static Future<List<PlacePrediction>> _getWebPlacePredictions(String input) async {
    if (!kIsWeb) return [];
    
    try {
      // Wait for Google Places API to be ready
      if (!_isGooglePlacesReady()) {
        await _waitForGooglePlaces();
      }
      
      // Use Google Places AutocompleteService
      final predictions = await _callAutocompleteService(input);
      return predictions.map((p) => PlacePrediction.fromWebJson(p)).toList();
    } catch (e) {
      debugPrint('Error getting web place predictions: $e');
      return [];
    }
  }
  
  static Future<PlaceDetails?> _getWebPlaceDetails(String placeId) async {
    if (!kIsWeb) return null;
    
    try {
      // Wait for Google Places API to be ready
      if (!_isGooglePlacesReady()) {
        await _waitForGooglePlaces();
      }
      
      // Use Google Places PlacesService
      final details = await _callPlacesService(placeId);
      return details != null ? PlaceDetails.fromWebJson(details) : null;
    } catch (e) {
      debugPrint('Error getting web place details: $e');
      return null;
    }
  }
  
  static bool _isGooglePlacesReady() {
    if (!kIsWeb) return false;
    try {
      return js_util.hasProperty(js_util.globalThis, 'google') &&
             js_util.hasProperty(js_util.getProperty(js_util.globalThis, 'google'), 'maps') &&
             js_util.hasProperty(js_util.getProperty(js_util.getProperty(js_util.globalThis, 'google'), 'maps'), 'places');
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> _waitForGooglePlaces() async {
    if (!kIsWeb) return;
    
    int attempts = 0;
    while (!_isGooglePlacesReady() && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    if (!_isGooglePlacesReady()) {
      throw Exception('Google Places API not available');
    }
  }
  
  static Future<List<Map<String, dynamic>>> _callAutocompleteService(String input) async {
    if (!kIsWeb) return [];
    
    try {
      // Use new AutocompleteSuggestion API (replaces deprecated AutocompleteService)
      final google = js_util.getProperty(js_util.globalThis, 'google');
      final maps = js_util.getProperty(google, 'maps');
      final places = js_util.getProperty(maps, 'places');
      
      // Create request object for AutocompleteSuggestion
      final request = js_util.jsify({
        'input': input,
        'locationBias': {
          'center': {'lat': 33.749, 'lng': -84.388},
          'radius': 50000
        },
        'region': 'us',
        'includedPrimaryTypes': ['establishment']
      });
      
      // Call AutocompleteSuggestion.fetchAutocompleteSuggestions
      final autocompleteSuggestion = js_util.getProperty(places, 'AutocompleteSuggestion');
      final promise = js_util.callMethod(autocompleteSuggestion, 'fetchAutocompleteSuggestions', [request]);
      final result = await js_util.promiseToFuture(promise);
      
      // Simple approach - convert to JSON string and parse
      final jsonString = js_util.callMethod(js_util.getProperty(js_util.globalThis, 'JSON'), 'stringify', [result]);
      final data = json.decode(jsonString as String) as Map<String, dynamic>;
      
      final suggestions = data['suggestions'] as List<dynamic>? ?? [];
      final results = <Map<String, dynamic>>[];
      
      for (final suggestion in suggestions) {
        final suggestionMap = suggestion as Map<String, dynamic>;
        final placePrediction = suggestionMap['placePrediction'] as Map<String, dynamic>?;
        
        if (placePrediction != null) {
          final placeId = placePrediction['placeId'] as String? ?? '';
          final textObj = placePrediction['text'] as Map<String, dynamic>?;
          final description = textObj?['text'] as String? ?? '';
          
          final structuredFormat = placePrediction['structuredFormat'] as Map<String, dynamic>?;
          final mainTextObj = structuredFormat?['mainText'] as Map<String, dynamic>?;
          final secondaryTextObj = structuredFormat?['secondaryText'] as Map<String, dynamic>?;
          
          final mainText = mainTextObj?['text'] as String? ?? '';
          final secondaryText = secondaryTextObj?['text'] as String? ?? '';
          
          if (placeId.isNotEmpty) {
            results.add({
              'place_id': placeId,
              'description': description,
              'structured_formatting': {
                'main_text': mainText,
                'secondary_text': secondaryText
              }
            });
          }
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('AutocompleteSuggestion API error: $e');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>?> _callPlacesService(String placeId) async {
    if (!kIsWeb) return null;
    
    try {
      // Use new Place.fetchFields API (replaces deprecated PlacesService.getDetails)
      final google = js_util.getProperty(js_util.globalThis, 'google');
      final maps = js_util.getProperty(google, 'maps');
      final places = js_util.getProperty(maps, 'places');
      
      // Create Place instance
      final placeConstructor = js_util.getProperty(places, 'Place');
      final placeOptions = js_util.jsify({'id': placeId});
      final place = js_util.callConstructor(placeConstructor, [placeOptions]);
      
      // Define fields to fetch
      final fieldsToFetch = js_util.jsify(['id', 'displayName', 'formattedAddress', 'location']);
      
      try {
        // Call fetchFields method
        final promise = js_util.callMethod(place, 'fetchFields', [js_util.jsify({'fields': fieldsToFetch})]);
        
        // Convert Promise to Future
        final result = await js_util.promiseToFuture(promise);
        final placeData = js_util.dartify(result) as Map<String, dynamic>;
        
        if (placeData.containsKey('place')) {
          final placeInfo = placeData['place'] as Map<String, dynamic>;
          final location = placeInfo['location'] as Map<String, dynamic>;
          
          return {
            'place_id': placeInfo['id'],
            'name': placeInfo['displayName'],
            'formatted_address': placeInfo['formattedAddress'],
            'geometry': {
              'location': {
                'lat': location['lat'],
                'lng': location['lng']
              }
            }
          };
        } else {
          return null;
        }
      } catch (e) {
        debugPrint('Place.fetchFields API error: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error calling place fetch fields: $e');
      return null;
    }
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
}