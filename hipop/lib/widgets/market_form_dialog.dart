import 'package:flutter/material.dart';
import '../models/market.dart';
import '../services/market_service.dart';

class MarketFormDialog extends StatefulWidget {
  final Market? market;

  const MarketFormDialog({super.key, this.market});

  @override
  State<MarketFormDialog> createState() => _MarketFormDialogState();
}

class _MarketFormDialogState extends State<MarketFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Operating days
  final Map<String, String> _operatingDays = {};
  final Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  final Map<String, TextEditingController> _dayControllers = {};

  bool _isLoading = false;
  bool get _isEditing => widget.market != null;

  @override
  void initState() {
    super.initState();
    
    // Initialize day controllers
    for (final day in _selectedDays.keys) {
      _dayControllers[day] = TextEditingController();
    }

    // If editing, populate fields
    if (_isEditing) {
      final market = widget.market!;
      _nameController.text = market.name;
      _addressController.text = market.address;
      _cityController.text = market.city;
      _stateController.text = market.state;
      _descriptionController.text = market.description ?? '';

      // Populate operating days
      for (final entry in market.operatingDays.entries) {
        final dayName = _getDayName(entry.key);
        if (_selectedDays.containsKey(dayName)) {
          _selectedDays[dayName] = true;
          _dayControllers[dayName]!.text = entry.value;
        }
      }
      _updateOperatingDays();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _descriptionController.dispose();
    
    for (final controller in _dayControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  String _getDayName(String key) {
    switch (key.toLowerCase()) {
      case 'monday': return 'Monday';
      case 'tuesday': return 'Tuesday';
      case 'wednesday': return 'Wednesday';
      case 'thursday': return 'Thursday';
      case 'friday': return 'Friday';
      case 'saturday': return 'Saturday';
      case 'sunday': return 'Sunday';
      default: return key;
    }
  }

  void _updateOperatingDays() {
    _operatingDays.clear();
    for (final entry in _selectedDays.entries) {
      if (entry.value && _dayControllers[entry.key]!.text.isNotEmpty) {
        _operatingDays[entry.key.toLowerCase()] = _dayControllers[entry.key]!.text.trim();
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_operatingDays.isEmpty) {
      _showErrorSnackBar('Please select at least one operating day');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Update existing market
        final updatedMarket = widget.market!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty 
              ? _descriptionController.text.trim() 
              : null,
          operatingDays: _operatingDays,
        );
        
        await MarketService.updateMarket(updatedMarket.id, updatedMarket.toFirestore());
        
        if (mounted) {
          Navigator.pop(context, updatedMarket);
        }
      } else {
        // Create new market
        final market = Market(
          id: '',
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          latitude: 0.0, // TODO: Add geocoding
          longitude: 0.0, // TODO: Add geocoding
          operatingDays: _operatingDays,
          description: _descriptionController.text.trim().isNotEmpty 
              ? _descriptionController.text.trim() 
              : null,
          createdAt: DateTime.now(),
        );

        final createdMarketId = await MarketService.createMarket(market);
        final createdMarket = market.copyWith(id: createdMarketId);
        
        if (mounted) {
          Navigator.pop(context, createdMarket);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error ${_isEditing ? 'updating' : 'creating'} market: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.storefront,
                  color: Colors.teal,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Edit Market' : 'Create New Market',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Market Name *',
                          prefixIcon: Icon(Icons.storefront),
                          border: OutlineInputBorder(),
                          helperText: 'e.g., "Downtown Farmers Market"',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the market name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                          helperText: 'Street address where the market is held',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the market address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _stateController,
                              decoration: const InputDecoration(
                                labelText: 'State *',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 2,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                          helperText: 'Brief description of your market',
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Operating Days & Hours',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the days your market operates and specify hours',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      _buildOperatingDaysSection(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Update Market' : 'Create Market'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatingDaysSection() {
    return Column(
      children: _selectedDays.keys.map((day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: CheckboxListTile(
                  title: Text(day, style: const TextStyle(fontSize: 12)),
                  value: _selectedDays[day],
                  onChanged: (value) {
                    setState(() {
                      _selectedDays[day] = value ?? false;
                      if (!_selectedDays[day]!) {
                        _dayControllers[day]!.clear();
                      }
                    });
                    _updateOperatingDays();
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _dayControllers[day],
                  enabled: _selectedDays[day],
                  decoration: InputDecoration(
                    hintText: '9AM-2PM',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    filled: !_selectedDays[day]!,
                    fillColor: !_selectedDays[day]! ? Colors.grey[100] : null,
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (_) => _updateOperatingDays(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}