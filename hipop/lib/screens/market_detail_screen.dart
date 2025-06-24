import 'package:flutter/material.dart';
import '../models/market.dart';
import '../models/vendor_market.dart';
import '../models/vendor_post.dart';
import '../services/market_service.dart';
import '../repositories/vendor_posts_repository.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/favorite_button.dart';
import '../widgets/market/market_calendar_widget.dart';

class MarketDetailScreen extends StatefulWidget {
  final Market market;

  const MarketDetailScreen({
    super.key,
    required this.market,
  });

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VendorMarket> _allVendors = [];
  List<VendorMarket> _activeVendorsToday = [];
  List<VendorPost> _activePosts = [];
  List<VendorPost> _allMarketPosts = [];
  bool _isLoading = true;
  String? _error;
  
  final VendorPostsRepository _vendorPostsRepository = VendorPostsRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMarketData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all vendors for this market
      final allVendors = await MarketService.getMarketVendors(widget.market.id);
      
      // Load vendors active today
      final activeToday = await MarketService.getActiveVendorsForMarketToday(widget.market.id);
      
      // Load all posts for this market (active, past, and future)
      final allMarketPosts = await _vendorPostsRepository.getMarketPosts(widget.market.id).first;
      final activePosts = allMarketPosts.where((post) => post.isActive).toList();

      setState(() {
        _allVendors = allVendors;
        _activeVendorsToday = activeToday;
        _activePosts = activePosts;
        _allMarketPosts = allMarketPosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load market data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.market.name),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Calendar'),
            Tab(text: 'Active Today'),
            Tab(text: 'All Vendors'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading market details...')
          : _error != null
              ? ErrorDisplayWidget(
                  title: 'Error Loading Market',
                  message: _error!,
                  onRetry: _loadMarketData,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildCalendarTab(),
                    _buildActiveTodayTab(),
                    _buildAllVendorsTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.market.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.market.fullAddress,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Hours
                  if (widget.market.operatingDays.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.market.isOpenToday && widget.market.todaysHours != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Open today: ${widget.market.todaysHours}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'Closed today',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                'Operating Schedule:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              ...widget.market.operatingDays.entries.map((entry) {
                                final day = entry.key;
                                final hours = entry.value;
                                final isToday = widget.market.isOpenToday && 
                                    widget.market.todaysHours == hours;
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '${day[0].toUpperCase()}${day.substring(1)}:',
                                          style: TextStyle(
                                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                            color: isToday ? Colors.green.shade700 : null,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        hours,
                                        style: TextStyle(
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                          color: isToday ? Colors.green.shade700 : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description if available
          if (widget.market.description != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.market.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Vendors',
                  '${_getUniqueVendorCount()}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Today',
                  '${_activeVendorsToday.length}',
                  Icons.today,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Posts',
                  '${_activePosts.length}',
                  Icons.announcement,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(), // Placeholder for future stat
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color.shade600, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    if (_allMarketPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No events scheduled',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for upcoming vendor events at this market.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: MarketCalendarWidget(
        posts: _allMarketPosts,
        onDateSelected: (date, postsForDay) {
          // Optional: Add functionality for date selection
        },
      ),
    );
  }

  Widget _buildActiveTodayTab() {
    if (_activeVendorsToday.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No vendors active today',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back on market days to see active vendors and their latest offerings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Active Posts Section
        if (_activePosts.isNotEmpty) ...[
          Text(
            'Active Posts Today',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ..._activePosts.map((post) => _buildPostCard(post)),
          
          const SizedBox(height: 24),
        ],
        
        // Active Vendors Section
        Text(
          'Vendors Scheduled Today',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ..._activeVendorsToday.map((vendorMarket) => _buildVendorCard(vendorMarket, true)),
      ],
    );
  }

  Widget _buildAllVendorsTab() {
    if (_allVendors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_mall_directory,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No vendors found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This market doesn\'t have any vendors yet. Check back soon!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'All Market Vendors',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ..._allVendors.map((vendorMarket) => _buildVendorCard(vendorMarket, false)),
      ],
    );
  }

  Widget _buildVendorCard(VendorMarket vendorMarket, bool isActiveToday) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActiveToday ? Colors.green.shade100 : Colors.grey.shade200,
                  child: Icon(
                    Icons.person,
                    color: isActiveToday ? Colors.green.shade700 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vendor ${vendorMarket.vendorId}', // TODO: Get actual vendor name
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (vendorMarket.boothNumber != null)
                        Text(
                          'Booth: ${vendorMarket.boothNumber}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isActiveToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Schedule: ${vendorMarket.scheduleDisplay}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(VendorPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.vendorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FavoriteButton(
                  postId: post.id,
                  // TODO: Implement favorites logic
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              post.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  post.formattedTimeRange,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const Spacer(),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: post.isHappening 
                        ? Colors.green.shade100 
                        : post.isUpcoming 
                            ? Colors.orange.shade100 
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.isHappening 
                        ? 'LIVE NOW' 
                        : post.isUpcoming 
                            ? 'UPCOMING' 
                            : 'ENDED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: post.isHappening 
                          ? Colors.green.shade700 
                          : post.isUpcoming 
                              ? Colors.orange.shade700 
                              : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getUniqueVendorCount() {
    // Count unique vendors based on vendor posts rather than vendor-market relationships
    final uniqueVendorIds = _allMarketPosts.map((post) => post.vendorId).toSet();
    return uniqueVendorIds.length;
  }
}