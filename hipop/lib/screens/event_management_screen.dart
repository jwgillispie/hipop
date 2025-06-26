import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/market_event.dart';
import '../models/managed_vendor.dart';
import '../models/market.dart';
import '../services/market_event_service.dart';
import '../services/managed_vendor_service.dart';
import '../services/market_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  String? get _currentMarketId {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated && state.userProfile?.isMarketOrganizer == true) {
      return state.userProfile!.managedMarketIds.isNotEmpty 
          ? state.userProfile!.managedMarketIds.first 
          : null;
    }
    return null;
  }
  
  String? get _currentOrganizerId {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      return state.user.uid;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateEventDialog(),
            tooltip: 'Create New Event',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showEventStats(),
            tooltip: 'Event Analytics',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Published'),
            Tab(text: 'Draft'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsList(null),
          _buildUpcomingEventsList(),
          _buildEventsList(EventStatus.published),
          _buildEventsList(EventStatus.draft),
          _buildEventsList(EventStatus.completed),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventDialog(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  Widget _buildEventsList(EventStatus? filterStatus) {
    final marketId = _currentMarketId;
    if (marketId == null) {
      return const Center(child: Text('No market assigned to your account'));
    }
    
    final stream = filterStatus == null
        ? MarketEventService.getEventsForMarket(marketId)
        : MarketEventService.getEventsByStatus(marketId, filterStatus);

    return StreamBuilder<List<MarketEvent>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  filterStatus == null 
                      ? 'No events yet'
                      : 'No ${filterStatus.name} events',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first market event to get started.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateEventDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event);
          },
        );
      },
    );
  }

  Widget _buildUpcomingEventsList() {
    final marketId = _currentMarketId;
    if (marketId == null) {
      return const Center(child: Text('No market assigned to your account'));
    }
    
    return StreamBuilder<List<MarketEvent>>(
      stream: MarketEventService.getUpcomingEvents(marketId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No upcoming events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text('Schedule some events to see them here.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event);
          },
        );
      },
    );
  }

  Widget _buildEventCard(MarketEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.eventTypeDisplayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (event.theme != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Theme: ${event.theme}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildStatusChip(event.status),
                      if (event.isRecurring) ...[
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            'RECURRING',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.blue[100],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.formattedDateRange,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${event.bookedVendorSlots}/${event.maxVendorSlots} vendors',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.grey[300],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: event.occupancyRate,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: event.occupancyRate >= 0.8 
                              ? Colors.red 
                              : event.occupancyRate >= 0.6 
                                  ? Colors.orange 
                                  : Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (event.isDraft) ...[
                    TextButton.icon(
                      onPressed: () => _publishEvent(event),
                      icon: const Icon(Icons.publish, size: 16),
                      label: const Text('Publish'),
                      style: TextButton.styleFrom(foregroundColor: Colors.green),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (event.isPublished || event.isActive) ...[
                    TextButton.icon(
                      onPressed: () => _showCancelDialog(event),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton.icon(
                    onPressed: () => _editEvent(event),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 16),
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red, size: 16),
                          title: Text('Delete Event', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteEvent(event);
                      }
                    },
                  ),
                  const Spacer(),
                  Text(
                    'Created: ${_formatDate(event.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(EventStatus status) {
    Color color;
    switch (status) {
      case EventStatus.draft:
        color = Colors.grey;
        break;
      case EventStatus.published:
        color = Colors.blue;
        break;
      case EventStatus.active:
        color = Colors.green;
        break;
      case EventStatus.completed:
        color = Colors.purple;
        break;
      case EventStatus.cancelled:
        color = Colors.red;
        break;
      case EventStatus.postponed:
        color = Colors.orange;
        break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateEventDialog() {
    final marketId = _currentMarketId;
    final organizerId = _currentOrganizerId;
    
    if (marketId == null || organizerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create event: Market or organizer info missing')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => _CreateEventDialog(
        marketId: marketId,
        organizerId: organizerId,
        onEventCreated: () => setState(() {}),
      ),
    );
  }

  void _showEventDetails(MarketEvent event) {
    showDialog(
      context: context,
      builder: (context) => _EventDetailsDialog(event: event),
    );
  }

  void _showEventStats() async {
    final marketId = _currentMarketId;
    if (marketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No market assigned to your account')),
      );
      return;
    }
    
    try {
      final stats = await MarketEventService.getEventStats(marketId);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _EventStatsDialog(stats: stats),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _publishEvent(MarketEvent event) async {
    try {
      await MarketEventService.publishEvent(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error publishing event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog(MarketEvent event) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancel "${event.title}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await MarketEventService.cancelEvent(
                  event.id, 
                  controller.text.trim().isEmpty 
                      ? 'Cancelled by organizer' 
                      : controller.text.trim(),
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event cancelled'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Event', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editEvent(MarketEvent event) {
    final marketId = _currentMarketId;
    final organizerId = _currentOrganizerId;
    
    if (marketId == null || organizerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to edit event: Market or organizer info missing')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => _EditEventDialog(
        event: event,
        marketId: marketId,
        organizerId: organizerId,
        onEventUpdated: () => setState(() {}),
      ),
    );
  }

  void _deleteEvent(MarketEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${event.title}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. All event data including vendor assignments will be permanently removed.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _confirmDeleteEvent(event),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(MarketEvent event) async {
    try {
      await MarketEventService.deleteEvent(event.id);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "${event.title}" deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Create Event Dialog
class _CreateEventDialog extends StatefulWidget {
  final String marketId;
  final String organizerId;
  final VoidCallback onEventCreated;

  const _CreateEventDialog({
    required this.marketId,
    required this.organizerId,
    required this.onEventCreated,
  });

  @override
  State<_CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<_CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _themeController = TextEditingController();
  final _maxSlotsController = TextEditingController(text: '50');
  final _vendorFeeController = TextEditingController();

  EventType _selectedEventType = EventType.farmersMarket;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  DateTime _startDateTime = DateTime.now().add(const Duration(days: 1));
  DateTime _endDateTime = DateTime.now().add(const Duration(days: 1, hours: 6));
  DateTime? _recurrenceEndDate;
  bool _isPublic = true;
  bool _requiresVendorApproval = true;
  bool _isLoading = false;
  
  // Market selection
  List<String> _selectedMarketIds = [];
  List<Market> _availableMarkets = [];
  
  // Vendor selection
  List<String> _selectedVendorIds = [];
  List<ManagedVendor> _availableVendors = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableMarkets();
    _loadAvailableVendors();
  }

  void _loadAvailableMarkets() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated && authState.userProfile?.isMarketOrganizer == true) {
        final managedMarketIds = authState.userProfile!.managedMarketIds;
        
        final markets = <Market>[];
        for (final marketId in managedMarketIds) {
          final market = await MarketService.getMarket(marketId);
          if (market != null) {
            markets.add(market);
          }
        }
        
        if (mounted) {
          setState(() {
            _availableMarkets = markets;
            _selectedMarketIds = markets.isNotEmpty ? [markets.first.id] : [];
          });
          _loadAvailableVendors();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading markets: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _loadAvailableVendors() async {
    try {
      final vendors = await ManagedVendorService.getVendorsForEventAssignment(
        widget.marketId,
        _selectedMarketIds,
      );
      if (mounted) {
        setState(() {
          _availableVendors = vendors;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vendors: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _themeController.dispose();
    _maxSlotsController.dispose();
    _vendorFeeController.dispose();
    super.dispose();
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
                const Text(
                  'Create New Event',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<EventType>(
                        value: _selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(),
                        ),
                        items: EventType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getEventTypeDisplayName(type)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedEventType = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _themeController,
                        decoration: const InputDecoration(
                          labelText: 'Theme (Optional)',
                          hintText: 'e.g., Holiday Market, Summer Festival',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Date & Time'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDateTime(true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(_formatDateTime(_startDateTime)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Date & Time'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDateTime(false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(_formatDateTime(_endDateTime)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<RecurrenceType>(
                        value: _selectedRecurrence,
                        decoration: const InputDecoration(
                          labelText: 'Recurrence',
                          border: OutlineInputBorder(),
                        ),
                        items: RecurrenceType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getRecurrenceDisplayName(type)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedRecurrence = value!),
                      ),
                      if (_selectedRecurrence != RecurrenceType.none) ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recurrence End Date (Optional)'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectRecurrenceEndDate(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(_recurrenceEndDate != null 
                                    ? _formatDate(_recurrenceEndDate!)
                                    : 'Select end date'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _maxSlotsController,
                              decoration: const InputDecoration(
                                labelText: 'Max Vendor Slots',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _vendorFeeController,
                              decoration: const InputDecoration(
                                labelText: 'Vendor Fee (\$)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                                  return 'Must be a valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Public Event'),
                        subtitle: const Text('Visible to shoppers'),
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('Require Vendor Approval'),
                        subtitle: const Text('Organizer must approve vendor applications'),
                        value: _requiresVendorApproval,
                        onChanged: (value) => setState(() => _requiresVendorApproval = value!),
                      ),
                      const SizedBox(height: 24),
                      _buildMarketSelectionSection(),
                      const SizedBox(height: 24),
                      _buildVendorSelectionSection(),
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
                    onPressed: _isLoading ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                        : const Text('Create Event'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isStart) async {
    final currentDateTime = isStart ? _startDateTime : _endDateTime;
    
    final date = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );
      
      if (time != null && mounted) {
        final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          if (isStart) {
            _startDateTime = newDateTime;
            // Ensure end time is after start time
            if (_endDateTime.isBefore(_startDateTime)) {
              _endDateTime = _startDateTime.add(const Duration(hours: 4));
            }
          } else {
            _endDateTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _selectRecurrenceEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? _startDateTime.add(const Duration(days: 30)),
      firstDate: _startDateTime,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      setState(() => _recurrenceEndDate = date);
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final event = MarketEvent(
        id: '',
        marketId: widget.marketId,
        participatingMarketIds: _selectedMarketIds,
        organizerId: widget.organizerId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        eventType: _selectedEventType,
        theme: _themeController.text.trim().isEmpty ? null : _themeController.text.trim(),
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        recurrenceType: _selectedRecurrence,
        recurrenceEndDate: _recurrenceEndDate,
        maxVendorSlots: int.parse(_maxSlotsController.text),
        vendorFee: _vendorFeeController.text.isEmpty ? null : double.parse(_vendorFeeController.text),
        selectedVendorIds: _selectedVendorIds,
        bookedVendorSlots: _selectedVendorIds.length,
        isPublic: _isPublic,
        requiresVendorApproval: _requiresVendorApproval,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (_selectedRecurrence != RecurrenceType.none) {
        await MarketEventService.createRecurringEvents(event);
      } else {
        await MarketEventService.createEvent(event);
      }
      
      if (mounted) {
        Navigator.pop(context);
        widget.onEventCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedRecurrence != RecurrenceType.none 
                ? 'Recurring events created successfully!' 
                : 'Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $amPm';
  }

  String _getEventTypeDisplayName(EventType type) {
    switch (type) {
      case EventType.farmersMarket:
        return 'Farmers Market';
      case EventType.artisanMarket:
        return 'Artisan Market';
      case EventType.foodFestival:
        return 'Food Festival';
      case EventType.holidayMarket:
        return 'Holiday Market';
      case EventType.communityEvent:
        return 'Community Event';
      case EventType.specialEvent:
        return 'Special Event';
      case EventType.popupMarket:
        return 'Pop-up Market';
      case EventType.other:
        return 'Other';
    }
  }

  String _getRecurrenceDisplayName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'One-time event';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.biweekly:
        return 'Bi-weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.custom:
        return 'Custom schedule';
    }
  }

  Widget _buildMarketSelectionSection() {
    if (_availableMarkets.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Selection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  'No markets available. Create markets first in Market Management.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Select Markets for Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${_selectedMarketIds.length} selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Choose which markets will participate in this event',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedMarketIds = _availableMarkets.map((m) => m.id).toList();
                });
                _loadAvailableVendors();
              },
              icon: const Icon(Icons.select_all, size: 16),
              label: const Text('Select All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 32),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedMarketIds = _availableMarkets.isNotEmpty ? [_availableMarkets.first.id] : [];
                });
                _loadAvailableVendors();
              },
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(100, 32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _availableMarkets.length,
            itemBuilder: (context, index) {
              final market = _availableMarkets[index];
              final isSelected = _selectedMarketIds.contains(market.id);
              
              return CheckboxListTile(
                title: Text(
                  market.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${market.city}, ${market.state}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedMarketIds.add(market.id);
                    } else {
                      _selectedMarketIds.remove(market.id);
                    }
                  });
                  _loadAvailableVendors();
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVendorSelectionSection() {
    if (_availableVendors.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vendor Selection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  _selectedMarketIds.isEmpty 
                    ? 'Select markets first to see available vendors.'
                    : 'No vendors available for selected markets. Create vendors first in Vendor Management.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Select Vendors for Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${_selectedVendorIds.length} selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Choose which vendors from selected markets can participate in this event',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedVendorIds = _availableVendors.map((v) => v.id).toList();
                });
              },
              icon: const Icon(Icons.select_all, size: 16),
              label: const Text('Select All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 32),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedVendorIds.clear();
                });
              },
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Clear All'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(100, 32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _availableVendors.length,
            itemBuilder: (context, index) {
              final vendor = _availableVendors[index];
              final isSelected = _selectedVendorIds.contains(vendor.id);
              
              return CheckboxListTile(
                title: Text(
                  vendor.businessName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.categoriesDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (vendor.products.isNotEmpty)
                      Text(
                        vendor.products.take(3).join(', '),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedVendorIds.add(vendor.id);
                    } else {
                      _selectedVendorIds.remove(vendor.id);
                    }
                  });
                },
                secondary: vendor.isFeatured
                    ? Icon(
                        Icons.star,
                        color: Colors.amber[700],
                        size: 20,
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Edit Event Dialog
class _EditEventDialog extends StatefulWidget {
  final MarketEvent event;
  final String marketId;
  final String organizerId;
  final VoidCallback onEventUpdated;

  const _EditEventDialog({
    required this.event,
    required this.marketId,
    required this.organizerId,
    required this.onEventUpdated,
  });

  @override
  State<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<_EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _themeController;
  late final TextEditingController _maxSlotsController;
  late final TextEditingController _vendorFeeController;

  late EventType _selectedEventType;
  late RecurrenceType _selectedRecurrence;
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  DateTime? _recurrenceEndDate;
  late bool _isPublic;
  late bool _requiresVendorApproval;
  bool _isLoading = false;
  
  // Market selection
  late List<String> _selectedMarketIds;
  List<Market> _availableMarkets = [];
  
  // Vendor selection
  late List<String> _selectedVendorIds;
  List<ManagedVendor> _availableVendors = [];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _loadAvailableMarkets();
    _loadAvailableVendors();
  }

  void _initializeFormData() {
    final event = widget.event;
    
    _titleController = TextEditingController(text: event.title);
    _descriptionController = TextEditingController(text: event.description);
    _themeController = TextEditingController(text: event.theme ?? '');
    _maxSlotsController = TextEditingController(text: event.maxVendorSlots.toString());
    _vendorFeeController = TextEditingController(text: event.vendorFee?.toString() ?? '');
    
    _selectedEventType = event.eventType;
    _selectedRecurrence = event.recurrenceType;
    _startDateTime = event.startDateTime;
    _endDateTime = event.endDateTime;
    _recurrenceEndDate = event.recurrenceEndDate;
    _isPublic = event.isPublic;
    _requiresVendorApproval = event.requiresVendorApproval;
    _selectedMarketIds = List<String>.from(event.participatingMarketIds);
    _selectedVendorIds = List<String>.from(event.selectedVendorIds);
  }

  void _loadAvailableMarkets() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated && authState.userProfile?.isMarketOrganizer == true) {
        final managedMarketIds = authState.userProfile!.managedMarketIds;
        
        final markets = <Market>[];
        for (final marketId in managedMarketIds) {
          final market = await MarketService.getMarket(marketId);
          if (market != null) {
            markets.add(market);
          }
        }
        
        if (mounted) {
          setState(() {
            _availableMarkets = markets;
            // Ensure selected markets are still valid
            _selectedMarketIds = _selectedMarketIds.where((id) => 
              managedMarketIds.contains(id)).toList();
          });
          _loadAvailableVendors();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading markets: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _loadAvailableVendors() async {
    try {
      final vendors = await ManagedVendorService.getVendorsForEventAssignment(
        widget.marketId,
        _selectedMarketIds,
      );
      if (mounted) {
        setState(() {
          _availableVendors = vendors;
          // Ensure selected vendors are still valid
          final availableVendorIds = vendors.map((v) => v.id).toSet();
          _selectedVendorIds = _selectedVendorIds.where((id) => 
            availableVendorIds.contains(id)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vendors: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _themeController.dispose();
    _maxSlotsController.dispose();
    _vendorFeeController.dispose();
    super.dispose();
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
                const Text(
                  'Edit Event',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<EventType>(
                        value: _selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(),
                        ),
                        items: EventType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getEventTypeDisplayName(type)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedEventType = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _themeController,
                        decoration: const InputDecoration(
                          labelText: 'Theme (Optional)',
                          hintText: 'e.g., Holiday Market, Summer Festival',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Date & Time'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDateTime(true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(_formatDateTime(_startDateTime)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Date & Time'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDateTime(false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(_formatDateTime(_endDateTime)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<RecurrenceType>(
                        value: _selectedRecurrence,
                        decoration: const InputDecoration(
                          labelText: 'Recurrence',
                          border: OutlineInputBorder(),
                        ),
                        items: RecurrenceType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getRecurrenceDisplayName(type)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedRecurrence = value!),
                      ),
                      if (_selectedRecurrence != RecurrenceType.none) ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recurrence End Date (Optional)'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectRecurrenceEndDate(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(_recurrenceEndDate != null 
                                    ? _formatDate(_recurrenceEndDate!)
                                    : 'Select end date'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _maxSlotsController,
                              decoration: const InputDecoration(
                                labelText: 'Max Vendor Slots',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Required';
                                if (int.tryParse(value!) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _vendorFeeController,
                              decoration: const InputDecoration(
                                labelText: 'Vendor Fee (\$)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                                  return 'Must be a valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Public Event'),
                        subtitle: const Text('Visible to shoppers'),
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('Require Vendor Approval'),
                        subtitle: const Text('Organizer must approve vendor applications'),
                        value: _requiresVendorApproval,
                        onChanged: (value) => setState(() => _requiresVendorApproval = value!),
                      ),
                      const SizedBox(height: 24),
                      _buildMarketSelectionSection(),
                      const SizedBox(height: 24),
                      _buildVendorSelectionSection(),
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
                    onPressed: _isLoading ? null : _updateEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
                        : const Text('Update Event'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isStart) async {
    final currentDateTime = isStart ? _startDateTime : _endDateTime;
    
    final date = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );
      
      if (time != null && mounted) {
        final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          if (isStart) {
            _startDateTime = newDateTime;
            // Ensure end time is after start time
            if (_endDateTime.isBefore(_startDateTime)) {
              _endDateTime = _startDateTime.add(const Duration(hours: 4));
            }
          } else {
            _endDateTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _selectRecurrenceEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? _startDateTime.add(const Duration(days: 30)),
      firstDate: _startDateTime,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      setState(() => _recurrenceEndDate = date);
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final updatedEvent = widget.event.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        eventType: _selectedEventType,
        theme: _themeController.text.trim().isEmpty ? null : _themeController.text.trim(),
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        recurrenceType: _selectedRecurrence,
        recurrenceEndDate: _recurrenceEndDate,
        maxVendorSlots: int.parse(_maxSlotsController.text),
        vendorFee: _vendorFeeController.text.isEmpty ? null : double.parse(_vendorFeeController.text),
        selectedVendorIds: _selectedVendorIds,
        bookedVendorSlots: _selectedVendorIds.length,
        participatingMarketIds: _selectedMarketIds,
        isPublic: _isPublic,
        requiresVendorApproval: _requiresVendorApproval,
        updatedAt: DateTime.now(),
      );
      
      await MarketEventService.updateEvent(widget.event.id, updatedEvent);
      
      if (mounted) {
        Navigator.pop(context);
        widget.onEventUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $amPm';
  }

  String _getEventTypeDisplayName(EventType type) {
    switch (type) {
      case EventType.farmersMarket:
        return 'Farmers Market';
      case EventType.artisanMarket:
        return 'Artisan Market';
      case EventType.foodFestival:
        return 'Food Festival';
      case EventType.holidayMarket:
        return 'Holiday Market';
      case EventType.communityEvent:
        return 'Community Event';
      case EventType.specialEvent:
        return 'Special Event';
      case EventType.popupMarket:
        return 'Pop-up Market';
      case EventType.other:
        return 'Other';
    }
  }

  String _getRecurrenceDisplayName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'One-time event';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.biweekly:
        return 'Bi-weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.custom:
        return 'Custom schedule';
    }
  }

  Widget _buildMarketSelectionSection() {
    if (_availableMarkets.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Selection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  'No markets available. Create markets first in Market Management.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Select Markets for Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${_selectedMarketIds.length} selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Choose which markets will participate in this event',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedMarketIds = _availableMarkets.map((m) => m.id).toList();
                });
                _loadAvailableVendors();
              },
              icon: const Icon(Icons.select_all, size: 16),
              label: const Text('Select All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 32),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedMarketIds = _availableMarkets.isNotEmpty ? [_availableMarkets.first.id] : [];
                });
                _loadAvailableVendors();
              },
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(100, 32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _availableMarkets.length,
            itemBuilder: (context, index) {
              final market = _availableMarkets[index];
              final isSelected = _selectedMarketIds.contains(market.id);
              
              return CheckboxListTile(
                title: Text(
                  market.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${market.city}, ${market.state}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedMarketIds.add(market.id);
                    } else {
                      _selectedMarketIds.remove(market.id);
                    }
                  });
                  _loadAvailableVendors();
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVendorSelectionSection() {
    if (_availableVendors.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vendor Selection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  _selectedMarketIds.isEmpty 
                    ? 'Select markets first to see available vendors.'
                    : 'No vendors available for selected markets. Create vendors first in Vendor Management.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Select Vendors for Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${_selectedVendorIds.length} selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Choose which vendors from selected markets can participate in this event',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedVendorIds = _availableVendors.map((v) => v.id).toList();
                });
              },
              icon: const Icon(Icons.select_all, size: 16),
              label: const Text('Select All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 32),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedVendorIds.clear();
                });
              },
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Clear All'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(100, 32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _availableVendors.length,
            itemBuilder: (context, index) {
              final vendor = _availableVendors[index];
              final isSelected = _selectedVendorIds.contains(vendor.id);
              
              return CheckboxListTile(
                title: Text(
                  vendor.businessName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.categoriesDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (vendor.products.isNotEmpty)
                      Text(
                        vendor.products.take(3).join(', '),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedVendorIds.add(vendor.id);
                    } else {
                      _selectedVendorIds.remove(vendor.id);
                    }
                  });
                },
                secondary: vendor.isFeatured
                    ? Icon(
                        Icons.star,
                        color: Colors.amber[700],
                        size: 20,
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Event Details Dialog
class _EventDetailsDialog extends StatelessWidget {
  final MarketEvent event;

  const _EventDetailsDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Event Type', event.eventTypeDisplayName),
                    if (event.theme != null) _buildDetailRow('Theme', event.theme!),
                    _buildDetailRow('Status', event.statusDisplayName),
                    _buildDetailRow('Date & Time', event.formattedDateRange),
                    if (event.isRecurring) _buildDetailRow('Recurrence', event.recurrenceDisplayName),
                    _buildDetailRow('Vendor Slots', '${event.bookedVendorSlots}/${event.maxVendorSlots}'),
                    if (event.participatingMarketIds.isNotEmpty) _buildDetailRow('Participating Markets', '${event.participatingMarketIds.length} markets'),
                    if (event.selectedVendorIds.isNotEmpty) _buildDetailRow('Selected Vendors', '${event.selectedVendorIds.length} vendors selected'),
                    if (event.vendorFee != null) _buildDetailRow('Vendor Fee', '\$${event.vendorFee!.toStringAsFixed(2)}'),
                    _buildDetailRow('Public Event', event.isPublic ? 'Yes' : 'No'),
                    _buildDetailRow('Requires Approval', event.requiresVendorApproval ? 'Yes' : 'No'),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(event.description),
                    if (event.specialFeatures.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Special Features',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...event.specialFeatures.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(feature),
                          ],
                        ),
                      )),
                    ],
                    if (event.cancellationReason != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Cancellation Reason',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(event.cancellationReason!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Event Stats Dialog
class _EventStatsDialog extends StatelessWidget {
  final Map<String, int> stats;

  const _EventStatsDialog({required this.stats});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Event Statistics'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatRow('Total Events', stats['total'] ?? 0, Colors.blue),
          _buildStatRow('Upcoming Events', stats['upcoming'] ?? 0, Colors.green),
          _buildStatRow('This Month', stats['thisMonth'] ?? 0, Colors.orange),
          _buildStatRow('Published', stats['published'] ?? 0, Colors.purple),
          _buildStatRow('Draft', stats['draft'] ?? 0, Colors.grey),
          _buildStatRow('Completed', stats['completed'] ?? 0, Colors.teal),
          _buildStatRow('Cancelled', stats['cancelled'] ?? 0, Colors.red),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}