import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../services/analytics_service.dart';
import '../services/onboarding_service.dart';
import '../blocs/auth/auth_event.dart';

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
}