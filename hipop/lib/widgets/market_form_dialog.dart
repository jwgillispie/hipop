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
  
  // Time picker state for each day
  final Map<String, String> _startTimes = {};
  final Map<String, String> _endTimes = {};
  final Map<String, String> _startPeriods = {}; // AM/PM
  final Map<String, String> _endPeriods = {}; // AM/PM

  bool _isLoading = false;
  bool get _isEditing => widget.market != null;

  @override
  void initState() {
    super.initState();
    
    // Initialize day controllers and time picker state
    for (final day in _selectedDays.keys) {
      _dayControllers[day] = TextEditingController();
      _startTimes[day] = '9:00';
      _endTimes[day] = '2:00';
      _startPeriods[day] = 'AM';
      _endPeriods[day] = 'PM';
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
          _parseTimeString(dayName, entry.value);
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
      if (entry.value) {
        final timeString = _formatTimeString(entry.key);
        if (timeString.isNotEmpty) {
          _operatingDays[entry.key.toLowerCase()] = timeString;
          _dayControllers[entry.key]!.text = timeString;
        }
      }
    }
  }

  String _formatTimeString(String day) {
    final startTime = _startTimes[day] ?? '9:00';
    final endTime = _endTimes[day] ?? '2:00';
    final startPeriod = _startPeriods[day] ?? 'AM';
    final endPeriod = _endPeriods[day] ?? 'PM';
    
    // Convert to simple format like "9AM-2PM"
    final start = startTime.replaceAll(':00', '') + startPeriod;
    final end = endTime.replaceAll(':00', '') + endPeriod;
    
    return '$start-$end';
  }

  void _parseTimeString(String day, String timeString) {
    // Parse strings like "9AM-2PM" or "9:00AM-2:00PM"
    final parts = timeString.split('-');
    if (parts.length == 2) {
      final startPart = parts[0].trim();
      final endPart = parts[1].trim();
      
      _parseTimePart(day, startPart, true);
      _parseTimePart(day, endPart, false);
    }
  }

  void _parseTimePart(String day, String timePart, bool isStart) {
    // Extract time and period from parts like "9AM" or "9:00AM"
    final regex = RegExp(r'(\d{1,2}):?(\d{0,2})(AM|PM)', caseSensitive: false);
    final match = regex.firstMatch(timePart);
    
    if (match != null) {
      final hour = match.group(1) ?? '9';
      final minute = match.group(2) ?? '00';
      final period = match.group(3)?.toUpperCase() ?? 'AM';
      
      final time = minute.isEmpty ? '$hour:00' : '$hour:$minute';
      
      if (isStart) {
        _startTimes[day] = time;
        _startPeriods[day] = period;
      } else {
        _endTimes[day] = time;
        _endPeriods[day] = period;
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
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Market' : 'Create New Market',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
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
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day checkbox
              CheckboxListTile(
                title: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                value: _selectedDays[day],
                onChanged: (value) {
                  setState(() {
                    _selectedDays[day] = value ?? false;
                  });
                  _updateOperatingDays();
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              // Time picker (only shown when day is selected)
              if (_selectedDays[day]!) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Row(
                    children: [
                      // Start time
                      Expanded(
                        child: _buildTimePickerGroup('Start', day, true),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'to',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      // End time
                      Expanded(
                        child: _buildTimePickerGroup('End', day, false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Preview of formatted time
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatTimeString(day),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePickerGroup(String label, String day, bool isStart) {
    final time = isStart ? _startTimes[day]! : _endTimes[day]!;
    final period = isStart ? _startPeriods[day]! : _endPeriods[day]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            // Time picker
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: time,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    items: _generateTimeOptions(),
                    onChanged: (newTime) {
                      if (newTime != null) {
                        setState(() {
                          if (isStart) {
                            _startTimes[day] = newTime;
                          } else {
                            _endTimes[day] = newTime;
                          }
                        });
                        _updateOperatingDays();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // AM/PM picker
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: period,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    items: const [
                      DropdownMenuItem(value: 'AM', child: Text('AM', style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'PM', child: Text('PM', style: TextStyle(fontSize: 14))),
                    ],
                    onChanged: (newPeriod) {
                      if (newPeriod != null) {
                        setState(() {
                          if (isStart) {
                            _startPeriods[day] = newPeriod;
                          } else {
                            _endPeriods[day] = newPeriod;
                          }
                        });
                        _updateOperatingDays();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _generateTimeOptions() {
    final times = <String>[];
    
    // Generate times from 1:00 to 12:30 in 30-minute intervals
    for (int hour = 1; hour <= 12; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final timeString = '$hour:${minute.toString().padLeft(2, '0')}';
        times.add(timeString);
      }
    }
    
    return times.map((time) => DropdownMenuItem(
      value: time,
      child: Text(time, style: const TextStyle(fontSize: 14)),
    )).toList();
  }
}