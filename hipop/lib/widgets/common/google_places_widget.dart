import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
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

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
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

class GooglePlacesWidget extends StatefulWidget {
  final Function(PlaceDetails) onPlaceSelected;
  final String? initialLocation;
  final String apiKey;

  const GooglePlacesWidget({
    super.key,
    required this.onPlaceSelected,
    required this.apiKey,
    this.initialLocation,
  });

  @override
  State<GooglePlacesWidget> createState() => _GooglePlacesWidgetState();
}

class _GooglePlacesWidgetState extends State<GooglePlacesWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  bool _showPredictions = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _controller.text = widget.initialLocation!;
    }
    
    _focusNode.addListener(() {
      setState(() {
        _showPredictions = _focusNode.hasFocus && _predictions.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      const String baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      final String url = '$baseUrl?input=${Uri.encodeComponent(query)}&key=${widget.apiKey}&types=establishment|geocode&components=country:us&location=33.749,-84.388&radius=50000';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();
          
          setState(() {
            _predictions = predictions;
            _showPredictions = _focusNode.hasFocus && predictions.isNotEmpty;
          });
        }
      }
    } catch (e) {
      // Log error - in production, use a proper logging framework
      debugPrint('Error searching places: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    setState(() => _isLoading = true);

    try {
      const String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
      final String url = '$baseUrl?place_id=$placeId&key=${widget.apiKey}&fields=place_id,name,formatted_address,geometry';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final placeDetails = PlaceDetails.fromJson(data['result']);
          
          setState(() {
            _controller.text = placeDetails.formattedAddress;
            _predictions = [];
            _showPredictions = false;
          });
          
          _focusNode.unfocus();
          widget.onPlaceSelected(placeDetails);
        }
      }
    } catch (e) {
      // Log error - in production, use a proper logging framework
      debugPrint('Error getting place details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search for a location...',
              prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              _predictions = [];
                              _showPredictions = false;
                            });
                          },
                        )
                      : const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: _searchPlaces,
            onTap: () {
              if (_predictions.isNotEmpty) {
                setState(() => _showPredictions = true);
              }
            },
          ),
        ),
        if (_showPredictions && _predictions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return InkWell(
                  onTap: () => _getPlaceDetails(prediction.placeId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: index < _predictions.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, 
                             color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prediction.mainText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (prediction.secondaryText.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  prediction.secondaryText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.north_west, 
                             color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}