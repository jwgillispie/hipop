import 'package:flutter/material.dart';
import '../../services/places_service.dart';

class GooglePlacesWidget extends StatefulWidget {
  final Function(PlaceDetails) onPlaceSelected;
  final Function(String)? onTextSearch;
  final String? initialLocation;

  const GooglePlacesWidget({
    super.key,
    required this.onPlaceSelected,
    this.onTextSearch,
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
  bool _isTyping = false;
  String _lastQuery = '';
  bool _hasSearched = false;
  String? _selectedPlaceId;

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
    setState(() {
      _isTyping = true;
      _lastQuery = query;
    });

    // Add a small delay to avoid too many API calls while typing
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if query changed while we were waiting
    if (_lastQuery != query) {
      return;
    }

    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
        _isLoading = false;
        _isTyping = false;
        _hasSearched = query.isNotEmpty;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isTyping = false;
    });

    try {
      final predictions = await PlacesService.getPlacePredictions(query);
      
      // Only update if this is still the current query
      if (_lastQuery == query) {
        setState(() {
          _predictions = predictions;
          _showPredictions = _focusNode.hasFocus && predictions.isNotEmpty;
          _hasSearched = true;
        });
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      if (_lastQuery == query) {
        setState(() {
          _predictions = [];
          _showPredictions = false;
          _hasSearched = true;
        });
      }
    } finally {
      if (_lastQuery == query) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    setState(() {
      _isLoading = true;
      _selectedPlaceId = placeId;
    });

    try {
      final placeDetails = await PlacesService.getPlaceDetails(placeId);
      
      if (placeDetails != null) {
        setState(() {
          _controller.text = placeDetails.formattedAddress;
          _predictions = [];
          _showPredictions = false;
          _selectedPlaceId = null;
        });
        
        _focusNode.unfocus();
        widget.onPlaceSelected(placeDetails);
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
      setState(() => _selectedPlaceId = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _finalizeSearch() {
    if (_controller.text.trim().isNotEmpty && widget.onTextSearch != null) {
      _focusNode.unfocus();
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      widget.onTextSearch!(_controller.text.trim());
    }
  }

  Widget _buildSuffixIcon() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }
    
    if (_isTyping) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      );
    }
    
    if (_controller.text.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.onTextSearch != null)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.orange),
              onPressed: _finalizeSearch,
              tooltip: 'Search for "${_controller.text}"',
            ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _controller.clear();
              setState(() {
                _predictions = [];
                _showPredictions = false;
                _hasSearched = false;
                _isTyping = false;
                _isLoading = false;
                _selectedPlaceId = null;
                _lastQuery = '';
              });
            },
          ),
        ],
      );
    }
    
    return const Icon(Icons.search, color: Colors.grey);
  }

  Widget _buildSearchFeedback() {
    if (_isLoading && _controller.text.length >= 3) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Searching for locations...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_hasSearched && _predictions.isEmpty && _controller.text.length >= 3 && !_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(Icons.search_off, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No locations found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    if (_controller.text.isNotEmpty && _controller.text.length < 3) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Type at least 3 characters to search',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Show helpful hint when field is focused but empty
    if (_focusNode.hasFocus && _controller.text.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Text(
                  'Search Tips',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Search by city, neighborhood, or address\n• Try "Atlanta", "Buckhead", or "Ponce City Market"',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
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
              hintText: _isLoading ? 'Searching...' : 'Search for a location...',
              prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
              suffixIcon: _buildSuffixIcon(),
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
            onSubmitted: (value) => _finalizeSearch(),
            onTap: () {
              if (_predictions.isNotEmpty) {
                setState(() => _showPredictions = true);
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildSearchFeedback(),
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
                final isSelected = _selectedPlaceId == prediction.placeId;
                
                return InkWell(
                  onTap: isSelected ? null : () => _getPlaceDetails(prediction.placeId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.withValues(alpha: 0.1) : null,
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
                        Icon(
                          Icons.location_on, 
                          color: isSelected ? Colors.orange : Colors.grey, 
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prediction.mainText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.orange[700] : null,
                                ),
                              ),
                              if (prediction.secondaryText.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  prediction.secondaryText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.orange[600] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                          )
                        else
                          Icon(
                            Icons.north_west, 
                            color: Colors.grey[400], 
                            size: 16,
                          ),
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