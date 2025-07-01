import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../services/analytics_service.dart';
import '../services/onboarding_service.dart';
import '../blocs/auth/auth_event.dart';
import '../models/market.dart';
import '../models/managed_vendor.dart';
import '../models/vendor_post.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  Map<String, dynamic>? _realTimeMetrics;
  bool _isLoading = true;
  List<String> _lastManagedMarketIds = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final authState = context.read<AuthBloc>().state;
      
      // Only check onboarding for authenticated market organizers
      if (authState is! Authenticated || authState.userType != 'market_organizer') {
        return;
      }
      
      final isCompleted = await OnboardingService.isOrganizerOnboardingComplete();
      debugPrint('Organizer onboarding completed: $isCompleted');
      
      if (!isCompleted && mounted) {
        debugPrint('Showing organizer onboarding');
        // Show onboarding after a short delay to let the dashboard load
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pushNamed('organizerOnboarding');
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking onboarding: $e');
    }
  }

  Future<void> _loadMetrics() async {
    try {
      final authState = context.read<AuthBloc>().state;
      
      if (authState is! Authenticated || authState.userProfile?.isMarketOrganizer != true) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final managedMarketIds = authState.userProfile!.managedMarketIds;
      _lastManagedMarketIds = List.from(managedMarketIds);
      
      if (managedMarketIds.isEmpty) {
        setState(() {
          _realTimeMetrics = _getEmptyMetrics();
          _isLoading = false;
        });
        return;
      }
      
      // Aggregate metrics from all managed markets
      Map<String, dynamic> aggregatedMetrics = {
        'vendors': {'total': 0, 'active': 0, 'pending': 0, 'approved': 0, 'rejected': 0, 'markets': managedMarketIds.length},
        'recipes': {'total': 0, 'public': 0, 'featured': 0, 'likes': 0, 'saves': 0, 'shares': 0},
        'events': {'total': 0, 'upcoming': 0, 'published': 0, 'averageOccupancy': 0.0},
        'lastUpdated': DateTime.now(),
      };
      
      // Fetch and aggregate metrics from each market
      for (final marketId in managedMarketIds) {
        final marketMetrics = await AnalyticsService.getRealTimeMetrics(marketId);
        _aggregateMetrics(aggregatedMetrics, marketMetrics);
      }
      
      setState(() {
        _realTimeMetrics = aggregatedMetrics;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading metrics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Map<String, dynamic> _getEmptyMetrics() {
    return {
      'vendors': {'total': 0, 'active': 0, 'pending': 0, 'approved': 0, 'rejected': 0, 'markets': 0},
      'recipes': {'total': 0, 'public': 0, 'featured': 0, 'likes': 0, 'saves': 0, 'shares': 0},
      'events': {'total': 0, 'upcoming': 0, 'published': 0, 'averageOccupancy': 0.0},
      'lastUpdated': DateTime.now(),
    };
  }
  
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  void _aggregateMetrics(Map<String, dynamic> aggregated, Map<String, dynamic> marketMetrics) {
    final vendorMetrics = (marketMetrics['vendors'] as Map<String, dynamic>?) ?? {};
    final recipeMetrics = (marketMetrics['recipes'] as Map<String, dynamic>?) ?? {};
    final eventMetrics = (marketMetrics['events'] as Map<String, dynamic>?) ?? {};
    
    // Aggregate vendor metrics
    final aggVendors = aggregated['vendors'] as Map<String, dynamic>;
    aggVendors['total'] = (aggVendors['total'] ?? 0) + (vendorMetrics['total'] ?? 0);
    aggVendors['active'] = (aggVendors['active'] ?? 0) + (vendorMetrics['active'] ?? 0);
    aggVendors['pending'] = (aggVendors['pending'] ?? 0) + (vendorMetrics['pending'] ?? 0);
    aggVendors['approved'] = (aggVendors['approved'] ?? 0) + (vendorMetrics['approved'] ?? 0);
    aggVendors['rejected'] = (aggVendors['rejected'] ?? 0) + (vendorMetrics['rejected'] ?? 0);
    
    // Aggregate recipe metrics
    final aggRecipes = aggregated['recipes'] as Map<String, dynamic>;
    aggRecipes['total'] = (aggRecipes['total'] ?? 0) + (recipeMetrics['total'] ?? 0);
    aggRecipes['public'] = (aggRecipes['public'] ?? 0) + (recipeMetrics['public'] ?? 0);
    aggRecipes['featured'] = (aggRecipes['featured'] ?? 0) + (recipeMetrics['featured'] ?? 0);
    aggRecipes['likes'] = (aggRecipes['likes'] ?? 0) + (recipeMetrics['likes'] ?? 0);
    aggRecipes['saves'] = (aggRecipes['saves'] ?? 0) + (recipeMetrics['saves'] ?? 0);
    aggRecipes['shares'] = (aggRecipes['shares'] ?? 0) + (recipeMetrics['shares'] ?? 0);
    
    // Aggregate event metrics (currently unused but prepared for future)
    final aggEvents = aggregated['events'] as Map<String, dynamic>;
    aggEvents['total'] = (aggEvents['total'] ?? 0) + (eventMetrics['total'] ?? 0);
    aggEvents['upcoming'] = (aggEvents['upcoming'] ?? 0) + (eventMetrics['upcoming'] ?? 0);
    aggEvents['published'] = (aggEvents['published'] ?? 0) + (eventMetrics['published'] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Reload metrics when managed markets change (e.g., after market creation)
        if (state is Authenticated && state.userProfile?.isMarketOrganizer == true) {
          final currentMarketIds = state.userProfile!.managedMarketIds;
          if (!_listsEqual(_lastManagedMarketIds, currentMarketIds)) {
            _lastManagedMarketIds = List.from(currentMarketIds);
            _loadMetrics();
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Market Organizer Dashboard'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onSelected: (String value) {
                  switch (value) {
                    case 'onboarding':
                      context.pushNamed('organizerOnboarding');
                      break;
                    case 'reset-onboarding':
                      _resetOnboarding();
                      break;
                    case 'profile':
                      context.pushNamed('organizerProfile');
                      break;
                    case 'change-password':
                      context.pushNamed('organizerChangePassword');
                      break;
                    case 'logout':
                      context.read<AuthBloc>().add(LogoutEvent());
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'onboarding',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('View Tutorial'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'change-password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.grey),
                        SizedBox(width: 12),
                        Text('Change Password'),
                      ],
                    ),
                  ),
                  if (kDebugMode) ...[
                    const PopupMenuItem<String>(
                      value: 'reset-onboarding',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Reset Tutorial'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                  ],
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.grey),
                        SizedBox(width: 12),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.storefront, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  state.user.displayName ?? state.user.email ?? 'Organizer',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Market Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadMetrics,
                        tooltip: 'Refresh data',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? _buildLoadingStats()
                    : _buildRealTimeStats(),
                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _buildActionCard(
                      'Market Management',
                      'Create and manage markets',
                      Icons.storefront,
                      Colors.teal,
                      () => context.pushNamed('marketManagement'),
                    ),
                    _buildActionCard(
                      'Vendor Management',
                      'Create and manage vendors',
                      Icons.store_mall_directory,
                      Colors.indigo,
                      () => context.pushNamed('vendorManagement'),
                    ),
                    _buildActionCard(
                      'Vendor Applications',
                      'Review new applications',
                      Icons.assignment_turned_in,
                      Colors.orange,
                      () => context.pushNamed('vendorApplications'),
                    ),
                    _buildActionCard(
                      'Custom Items',
                      'Manage recipes and content',
                      Icons.tune,
                      Colors.purple,
                      () => context.pushNamed('customItems'),
                    ),
                    _buildActionCard(
                      'Analytics',
                      'View market insights',
                      Icons.analytics,
                      Colors.green,
                      () => context.pushNamed('analytics'),
                    ),
                    _buildActionCard(
                      'Market Calendar',
                      'View market schedules',
                      Icons.calendar_today,
                      Colors.teal,
                      () => context.pushNamed('organizerCalendar'),
                    ),
                    if (kDebugMode)
                      _buildActionCard(
                        'Fix Market Association',
                        'Run if vendor/event management shows errors',
                        Icons.build_circle,
                        Colors.orange,
                        () => context.pushNamed('adminFix'),
                      ),
                    if (kDebugMode)
                      _buildActionCard(
                        'Add L5P Markets',
                        'Create Little 5 Points markets for Bien Vegano demo',
                        Icons.add_location_alt,
                        Colors.green,
                        () => _addLittle5PointsMarkets(),
                      ),
                    if (kDebugMode)
                      _buildActionCard(
                        'Add SK8 THE ROOF',
                        'Create Ponce City Market roller rink event',
                        Icons.sports_hockey,
                        Colors.purple,
                        () => _addSk8TheRoof(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _buildLoadingStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardSkeleton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 32,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeStats() {
    if (_realTimeMetrics == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final vendorMetrics = (_realTimeMetrics!['vendors'] as Map<String, dynamic>?) ?? {};
    final recipeMetrics = (_realTimeMetrics!['recipes'] as Map<String, dynamic>?) ?? {};
    final favoritesMetrics = (_realTimeMetrics!['favorites'] as Map<String, dynamic>?) ?? {};
    
    debugPrint('Dashboard favorites metrics: $favoritesMetrics');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending Applications',
                (vendorMetrics['pending'] ?? 0).toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Vendors',
                (vendorMetrics['active'] ?? 0).toString(),
                Icons.store,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Published Recipes',
                (recipeMetrics['public'] ?? 0).toString(),
                Icons.restaurant_menu,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Market Favorites',
                (favoritesMetrics['totalMarketFavorites'] ?? 0).toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Vendor Favorites',
                (favoritesMetrics['totalVendorFavorites'] ?? 0).toString(),
                Icons.favorite_border,
                Colors.pink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Markets',
                (vendorMetrics['markets'] ?? 0).toString(),
                Icons.storefront,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetOnboarding() async {
    await OnboardingService.resetOrganizerOnboarding();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutorial reset! It will show again next time you open the dashboard.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addLittle5PointsMarkets() async {
    if (!kDebugMode) return; // Extra safety check
    
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating Little 5 Points markets...'),
            ],
          ),
        ),
      );

      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      // Create Little 5 Points Market for July 13th, 2025
      final market1 = Market(
        id: 'little5points_liminal_july13_2025',
        name: 'Little 5 Points Community Market at Liminal Space - July 13th',
        address: '483 Moreland Ave NE, Atlanta, GA 30307',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7656,
        longitude: -84.3477,
        placeId: 'ChIJX8XLpTwE9YgRBvtEHCwPl8k',
        operatingDays: const {'sunday': '1:00 PM - 5:00 PM'},
        description: 'A vibrant plant-based market in the heart of Little 5 Points featuring vegan vendors, handmade crafts, and community energy. Free and open to all!',
        imageUrl: 'https://example.com/little5points_market_july13.jpg',
        isActive: true,
        createdAt: now,
      );

      // Create Little 5 Points Market for July 20th, 2025
      final market2 = Market(
        id: 'little5points_liminal_july20_2025',
        name: 'Little 5 Points Community Market at Liminal Space - July 20th',
        address: '483 Moreland Ave NE, Atlanta, GA 30307',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7656,
        longitude: -84.3477,
        placeId: 'ChIJX8XLpTwE9YgRBvtEHCwPl8k',
        operatingDays: const {'sunday': '1:00 PM - 5:00 PM'},
        description: 'A vibrant plant-based market in the heart of Little 5 Points featuring vegan vendors, handmade crafts, and community energy. Free and open to all!',
        imageUrl: 'https://example.com/little5points_market_july20.jpg',
        isActive: true,
        createdAt: now,
      );

      // Save markets
      await firestore.collection('markets').doc(market1.id).set(market1.toFirestore());
      await firestore.collection('markets').doc(market2.id).set(market2.toFirestore());

      // Create Bien Vegano vendor for both markets
      final bienVeganoVendor1 = ManagedVendor(
        id: 'bien_vegano_july13_2025',
        marketId: market1.id,
        organizerId: 'liminal_space_organizer',
        businessName: 'Bien Vegano',
        contactName: 'Bien Vegano Team',
        email: 'hello@bienvegano.com',
        phoneNumber: '(404) 555-0123',
        address: 'Atlanta, GA',
        city: 'Atlanta',
        state: 'GA',
        zipCode: '30307',
        categories: const [VendorCategory.prepared_foods, VendorCategory.beverages, VendorCategory.other],
        products: const [
          'Plant-based meals',
          'Vegan desserts',
          'Cold-pressed juices',
          'Organic smoothies',
          'Raw treats'
        ],
        specialties: const [
          'Handcrafted vegan cuisine',
          'Locally sourced ingredients',
          'Sustainable packaging'
        ],
        description: 'Bringing plant-based goodness and community energy to Atlanta markets. We specialize in handmade vegan foods that nourish both body and soul.',
        story: 'Born from a passion for plant-based living and community connection, Bien Vegano creates delicious vegan foods that bring people together.',
        slogan: 'Plant-based goodness, handmade magic & community energy',
        instagramHandle: 'bienvegano',
        website: 'https://bienvegano.com',
        isOrganic: true,
        isLocallySourced: true,
        certifications: 'Organic, Plant-based certified',
        operatingDays: const ['sunday'],
        canDeliver: false,
        acceptsOrders: true,
        imageUrl: 'https://example.com/bien_vegano_logo.jpg',
        logoUrl: 'https://example.com/bien_vegano_logo.jpg',
        tags: const ['vegan', 'organic', 'plant-based', 'handmade'],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final bienVeganoVendor2 = bienVeganoVendor1.copyWith(
        id: 'bien_vegano_july20_2025',
        marketId: market2.id,
      );

      // Save vendors
      await firestore.collection('managed_vendors').doc(bienVeganoVendor1.id).set(bienVeganoVendor1.toFirestore());
      await firestore.collection('managed_vendors').doc(bienVeganoVendor2.id).set(bienVeganoVendor2.toFirestore());

      // Create vendor posts for Instagram announcement
      final vendorPost1 = VendorPost(
        id: 'bien_vegano_l5p_july13_2025',
        vendorId: bienVeganoVendor1.id,
        vendorName: 'Bien Vegano',
        description: 'Bien Vegano is headed to Little 5 Points this July for TWO back-to-back cozy markets! We\'re bringing all the plant-based goodness, handmade magic & community energy to this iconic ATL spot — and you don\'t want to miss it!',
        location: '483 Moreland Ave NE, Atlanta, GA 30307',
        locationKeywords: VendorPost.generateLocationKeywords('483 Moreland Ave NE, Atlanta, GA 30307'),
        latitude: 33.7656,
        longitude: -84.3477,
        placeId: 'ChIJX8XLpTwE9YgRBvtEHCwPl8k',
        locationName: 'Liminal Space ATL',
        popUpStartDateTime: DateTime(2025, 7, 13, 13, 0),
        popUpEndDateTime: DateTime(2025, 7, 13, 17, 0),
        instagramHandle: 'bienvegano',
        marketId: market1.id,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final vendorPost2 = vendorPost1.copyWith(
        id: 'bien_vegano_l5p_july20_2025',
        vendorId: bienVeganoVendor2.id,
        popUpStartDateTime: DateTime(2025, 7, 20, 13, 0),
        popUpEndDateTime: DateTime(2025, 7, 20, 17, 0),
        marketId: market2.id,
      );

      // Save vendor posts
      await firestore.collection('vendor_posts').doc(vendorPost1.id).set(vendorPost1.toFirestore());
      await firestore.collection('vendor_posts').doc(vendorPost2.id).set(vendorPost2.toFirestore());

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌱 Successfully created Little 5 Points markets for Bien Vegano demo!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error creating markets: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  Future<void> _addSk8TheRoof() async {
    if (!kDebugMode) return; // Extra safety check
    
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating SK8 THE ROOF...'),
            ],
          ),
        ),
      );

      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      // Create SK8 THE ROOF event at Ponce City Market
      final market = Market(
        id: 'sk8_the_roof_pcm_2025',
        name: 'SK8 THE ROOF - Ponce City Market Roller Rink',
        address: '675 Ponce De Leon Ave NE, Atlanta, GA 30308',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7701,
        longitude: -84.3677,
        placeId: 'ChIJBYXhVwYE9YgRbHKXCVHVTDQ',
        operatingDays: const {
          'monday': '10:00 AM - 10:00 PM',
          'tuesday': '10:00 AM - 10:00 PM',
          'wednesday': '10:00 AM - 10:00 PM',
          'thursday': '10:00 AM - 10:00 PM',
          'friday': '10:00 AM - 10:00 PM',
          'saturday': '10:00 AM - 10:00 PM',
          'sunday': '10:00 AM - 10:00 PM',
        },
        description: 'Get ready to roll with SK8 THE ROOF, a new roller rink at Ponce City Market. Open daily all summer, the 3,000-square-foot, 80s-inspired rink features complimentary skate rentals, weekend DJ sets, and nightly laser shows. Access is included with all access gameplay tickets or Skyline memberships.',
        imageUrl: 'https://example.com/sk8_the_roof.jpg',
        isActive: true,
        createdAt: now,
      );

      // Save market/event
      await firestore.collection('markets').doc(market.id).set(market.toFirestore());

      // Create vendor for the roller rink itself
      final sk8Vendor = ManagedVendor(
        id: 'sk8_the_roof_vendor_2025',
        marketId: market.id,
        organizerId: 'ponce_city_organizer',
        businessName: 'SK8 THE ROOF',
        contactName: 'Ponce City Roof Team',
        description: '80s-inspired roller rink experience with complimentary skate rentals, weekend DJ sets, and nightly laser shows.',
        categories: const [VendorCategory.other],
        products: const [
          'Roller skating sessions',
          'Complimentary skate rentals',
          'DJ entertainment',
          'Laser light shows',
          'All access gameplay tickets',
          'Skyline memberships'
        ],
        specialties: const [
          '80s-inspired atmosphere',
          'Weekend DJ sets',
          'Nightly laser shows',
          'Free skate rentals'
        ],
        instagramHandle: 'poncecityroof',
        website: 'https://poncecityroof.com',
        address: '675 Ponce De Leon Ave NE, Atlanta, GA 30308',
        city: 'Atlanta',
        state: 'GA',
        zipCode: '30308',
        canDeliver: false,
        acceptsOrders: true,
        operatingDays: const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
        tags: const ['roller-skating', '80s', 'entertainment', 'laser-shows', 'dj', 'summer'],
        specialRequirements: '3,000-square-foot rink space',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Save vendor
      await firestore.collection('managed_vendors').doc(sk8Vendor.id).set(sk8Vendor.toFirestore());

      // Create announcement post
      final eventPost = VendorPost(
        id: 'sk8_the_roof_announcement_2025',
        vendorId: sk8Vendor.id,
        vendorName: 'SK8 THE ROOF',
        description: 'Get ready to roll at @poncecityroof with SK8 THE ROOF, a new roller rink at Ponce City Market. Open daily all summer, the 3,000-square-foot, 80s-inspired rink features complimentary skate rentals, weekend DJ sets, and nightly laser shows. Access is included with all access gameplay tickets or Skyline memberships. Learn more at poncecityroof.com.',
        location: '675 Ponce De Leon Ave NE, Atlanta, GA 30308',
        locationKeywords: VendorPost.generateLocationKeywords('675 Ponce De Leon Ave NE, Atlanta, GA 30308'),
        latitude: 33.7701,
        longitude: -84.3677,
        placeId: 'ChIJBYXhVwYE9YgRbHKXCVHVTDQ',
        locationName: 'Ponce City Market Roof',
        popUpStartDateTime: DateTime(2025, 6, 1, 10, 0), // Summer season start
        popUpEndDateTime: DateTime(2025, 8, 31, 22, 0),  // Summer season end
        instagramHandle: 'poncecityroof',
        marketId: market.id,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Save event post
      await firestore.collection('vendor_posts').doc(eventPost.id).set(eventPost.toFirestore());

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🛼 Successfully created SK8 THE ROOF roller rink event!'),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error creating SK8 THE ROOF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }
}