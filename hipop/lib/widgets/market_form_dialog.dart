import 'package:flutter/material.dart';
import '../models/market.dart';
import '../models/market_schedule.dart';
import '../services/market_service.dart';
import '../widgets/market_schedule_form.dart';

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

  // New schedule system
  List<MarketSchedule> _marketSchedules = [];
  
  bool _isLoading = false;
  bool get _isEditing => widget.market != null;

  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields
    if (_isEditing) {
      final market = widget.market!;
      _nameController.text = market.name;
      _addressController.text = market.address;
      _cityController.text = market.city;
      _stateController.text = market.state;
      _descriptionController.text = market.description ?? '';
      
      // Load existing schedules if available
      _loadExistingSchedules();
    }
  }
  
  Future<void> _loadExistingSchedules() async {
    if (widget.market?.scheduleIds?.isNotEmpty == true) {
      try {
        // TODO: Load existing schedules from the scheduleIds
        // For now, we'll convert legacy operatingDays to schedule format
        _convertLegacyOperatingDays();
      } catch (e) {
        // If loading fails, fall back to legacy conversion
        _convertLegacyOperatingDays();
      }
    } else {
      // Convert legacy operating days to new schedule format
      _convertLegacyOperatingDays();
    }
  }
  
  void _convertLegacyOperatingDays() {
    if (widget.market?.operatingDays.isNotEmpty == true) {
      // Convert old operatingDays format to MarketSchedule
      final operatingDays = widget.market!.operatingDays;
      final daysOfWeek = <int>[];
      String? startTime;
      String? endTime;
      
      // Extract days and times from legacy format
      for (final entry in operatingDays.entries) {
        final dayIndex = _getDayIndex(entry.key);
        if (dayIndex != null) {
          daysOfWeek.add(dayIndex);
          
          // Parse time from format like "9AM-2PM"
          final times = _parseLegacyTimeString(entry.value);
          startTime ??= times['start'];
          endTime ??= times['end'];
        }
      }
      
      if (daysOfWeek.isNotEmpty && startTime != null && endTime != null) {
        _marketSchedules = [
          MarketSchedule.recurring(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            marketId: widget.market!.id,
            startTime: startTime,
            endTime: endTime,
            pattern: RecurrencePattern.weekly,
            daysOfWeek: daysOfWeek,
            startDate: DateTime.now(),
          ),
        ];
      }
    }
  }
  
  int? _getDayIndex(String dayKey) {
    switch (dayKey.toLowerCase()) {
      case 'monday': return 1;
      case 'tuesday': return 2;
      case 'wednesday': return 3;
      case 'thursday': return 4;
      case 'friday': return 5;
      case 'saturday': return 6;
      case 'sunday': return 7;
      default: return null;
    }
  }
  
  Map<String, String> _parseLegacyTimeString(String timeString) {
    // Parse strings like "9AM-2PM" or "9:00AM-2:00PM"
    final parts = timeString.split('-');
    if (parts.length == 2) {
      return {
        'start': _formatTime(parts[0].trim()),
        'end': _formatTime(parts[1].trim()),
      };
    }
    return {'start': '9:00 AM', 'end': '2:00 PM'};
  }
  
  String _formatTime(String timePart) {
    // Convert "9AM" or "9:00AM" to "9:00 AM"
    final regex = RegExp(r'(\d{1,2}):?(\d{0,2})(AM|PM)', caseSensitive: false);
    final match = regex.firstMatch(timePart);
    
    if (match != null) {
      final hour = match.group(1) ?? '9';
      final minute = match.group(2)?.isEmpty == true ? '00' : (match.group(2) ?? '00');
      final period = match.group(3)?.toUpperCase() ?? 'AM';
      return '$hour:$minute $period';
    }
    return timePart;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_marketSchedules.isEmpty) {
      _showErrorSnackBar('Please configure at least one market schedule');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Update existing market
        await _updateMarketWithSchedules();
      } else {
        // Create new market
        await _createMarketWithSchedules();
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
  
  Future<void> _createMarketWithSchedules() async {
    // First create the market
    final market = Market(
      id: '',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      latitude: 0.0, // TODO: Add geocoding
      longitude: 0.0, // TODO: Add geocoding
      operatingDays: _generateLegacyOperatingDays(), // Keep for backward compatibility
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      createdAt: DateTime.now(),
    );

    final createdMarketId = await MarketService.createMarket(market);
    
    // Then create the schedules and link them to the market
    final scheduleIds = <String>[];
    for (final schedule in _marketSchedules) {
      final scheduleWithMarketId = schedule.copyWith(marketId: createdMarketId);
      final scheduleId = await MarketService.createMarketSchedule(scheduleWithMarketId);
      scheduleIds.add(scheduleId);
    }
    
    // Update the market with schedule IDs
    final updatedMarket = market.copyWith(
      id: createdMarketId,
      scheduleIds: scheduleIds,
    );
    await MarketService.updateMarket(createdMarketId, updatedMarket.toFirestore());
    
    if (mounted) {
      Navigator.pop(context, updatedMarket);
    }
  }
  
  Future<void> _updateMarketWithSchedules() async {
    final market = widget.market!;
    
    // Update market basic info
    final updatedMarket = market.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      operatingDays: _generateLegacyOperatingDays(), // Keep for backward compatibility
    );
    
    // TODO: Handle schedule updates properly
    // For now, we'll just update the market info
    await MarketService.updateMarket(market.id, updatedMarket.toFirestore());
    
    if (mounted) {
      Navigator.pop(context, updatedMarket);
    }
  }
  
  Map<String, String> _generateLegacyOperatingDays() {
    final operatingDays = <String, String>{};
    
    for (final schedule in _marketSchedules) {
      if (schedule.type == ScheduleType.recurring && schedule.daysOfWeek != null) {
        for (final dayIndex in schedule.daysOfWeek!) {
          final dayName = _getDayNameFromIndex(dayIndex);
          if (dayName != null) {
            operatingDays[dayName.toLowerCase()] = '${schedule.startTime}-${schedule.endTime}';
          }
        }
      }
    }
    
    return operatingDays;
  }
  
  String? _getDayNameFromIndex(int dayIndex) {
    switch (dayIndex) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return null;
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
                      // Market Schedule Form
                      MarketScheduleForm(
                        initialSchedules: _marketSchedules,
                        onSchedulesChanged: (schedules) {
                          setState(() {
                            _marketSchedules = schedules;
                          });
                        },
                      ),
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

}