import 'package:flutter/material.dart';
import '../../services/places_service.dart';

class SimplePlacesWidget extends StatefulWidget {
  final Function(PlaceDetails?) onLocationSelected;
  final String? initialLocation;

  const SimplePlacesWidget({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<SimplePlacesWidget> createState() => _SimplePlacesWidgetState();
}

class _SimplePlacesWidgetState extends State<SimplePlacesWidget> {
  final TextEditingController _controller = TextEditingController();
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  bool _showPredictions = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _controller.text = widget.initialLocation!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final predictions = await PlacesService.getPlacePredictions(query);
      setState(() {
        _predictions = predictions;
        _showPredictions = predictions.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    setState(() {
      _controller.text = prediction.description;
      _predictions = [];
      _showPredictions = false;
      _isLoading = true;
    });
    
    try {
      // Get place details including coordinates
      final placeDetails = await PlacesService.getPlaceDetails(prediction.placeId);
      
      setState(() => _isLoading = false);
      
      if (placeDetails != null) {
        // Notify parent with full place details
        widget.onLocationSelected(placeDetails);
      } else {
        // Fallback: create basic PlaceDetails from prediction
        final fallbackDetails = PlaceDetails(
          placeId: prediction.placeId,
          name: prediction.mainText,
          formattedAddress: prediction.description,
          latitude: 0, // Will trigger text-only search
          longitude: 0,
        );
        widget.onLocationSelected(fallbackDetails);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      // Fallback: create basic PlaceDetails from prediction
      final fallbackDetails = PlaceDetails(
        placeId: prediction.placeId,
        name: prediction.mainText,
        formattedAddress: prediction.description,
        latitude: 0, // Will trigger text-only search
        longitude: 0,
      );
      widget.onLocationSelected(fallbackDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
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
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _predictions = [];
                            _showPredictions = false;
                          });
                          widget.onLocationSelected(null);
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: _searchPlaces,
        ),
        if (_showPredictions) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.orange),
                  title: Text(
                    prediction.mainText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: prediction.secondaryText.isNotEmpty
                      ? Text(prediction.secondaryText)
                      : null,
                  onTap: () => _selectPlace(prediction),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}