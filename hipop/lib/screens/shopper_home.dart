import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/common/google_places_widget.dart';
import '../services/places_service.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/favorite_button.dart';
import '../models/vendor_post.dart';
import '../repositories/vendor_posts_repository.dart';
import '../blocs/favorites/favorites_bloc.dart';
import 'dart:math' as math;

class ShopperHome extends StatefulWidget {
  const ShopperHome({super.key});

  @override
  State<ShopperHome> createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  String _searchLocation = '';
  PlaceDetails? _selectedSearchPlace;
  double _searchRadius = 10.0; // Default 10km radius
  final VendorPostsRepository _vendorPostsRepository = VendorPostsRepository();
  Stream<List<VendorPost>>? _currentStream;
  
  static const List<double> _radiusOptions = [5.0, 10.0, 25.0, 50.0];

  @override
  void initState() {
    super.initState();
    // Initialize the stream immediately to show posts
    _currentStream = _vendorPostsRepository.getAllActivePosts();
    _initializeAndMigrate();
  }

  Future<void> _initializeAndMigrate() async {
    print('=== INITIALIZING SHOPPER HOME ===');
    
    // Skip migration and deletion in production - just start showing posts
    // These operations require admin permissions and are only needed for development
    
    // Start with empty search to show all posts
    print('Starting with empty search...');
    _performSearch('');
  }


  void _performSearch(String location) {
    setState(() {
      _searchLocation = location;
      _selectedSearchPlace = null; // Clear place when doing text search
      _currentStream = _vendorPostsRepository.searchPostsByLocation(location);
    });
  }
  
  void _clearSearch() {
    setState(() {
      _searchLocation = '';
      _selectedSearchPlace = null;
      _searchRadius = 10.0; // Reset to default
    });
    _performSearch('');
  }
  
  void _performPlaceSearch(PlaceDetails place) {
    setState(() {
      _searchLocation = place.formattedAddress;
      _selectedSearchPlace = place;
      _currentStream = _vendorPostsRepository.searchPostsByLocationAndProximity(
        location: place.formattedAddress,
        latitude: place.latitude,
        longitude: place.longitude,
        radiusKm: _searchRadius,
      );
    });
  }

  // Helper method to calculate distance for display
  double? _calculateDistance(VendorPost post) {
    if (_selectedSearchPlace?.latitude == null || 
        _selectedSearchPlace?.longitude == null ||
        post.latitude == null || 
        post.longitude == null) {
      return null;
    }
    
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _toRadians(post.latitude! - _selectedSearchPlace!.latitude);
    final double dLon = _toRadians(post.longitude! - _selectedSearchPlace!.longitude);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(_selectedSearchPlace!.latitude)) * math.cos(_toRadians(post.latitude!)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: LoadingWidget(message: 'Signing you in...'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('HiPop'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.shopping_bag, color: Colors.white),
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
                                  state.user.displayName ?? state.user.email ?? 'Shopper',
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
                Text(
                  'Find Pop-ups Near You',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    GooglePlacesWidget(
                      initialLocation: _searchLocation,
                      onPlaceSelected: _performPlaceSearch,
                      onTextSearch: _performSearch,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or browse all',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedSearchPlace != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'Search Radius',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                const Spacer(),
                                DropdownButton<double>(
                                  value: _searchRadius,
                                  underline: const SizedBox(),
                                  items: _radiusOptions.map((radius) {
                                    return DropdownMenuItem<double>(
                                      value: radius,
                                      child: Text('${radius.toInt()} km'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null && _selectedSearchPlace != null) {
                                      setState(() {
                                        _searchRadius = value;
                                      });
                                      _performPlaceSearch(_selectedSearchPlace!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_searchLocation.isNotEmpty || _selectedSearchPlace != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Show All Pop-ups'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _searchLocation.isEmpty 
                          ? 'All Pop-ups' 
                          : 'Pop-ups in $_searchLocation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StreamBuilder<List<VendorPost>>(
                      stream: _currentStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Text(
                            '${snapshot.data!.length} found',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<VendorPost>>(
                    stream: _currentStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget(message: 'Finding pop-ups near you...');
                      }
                      
                      if (snapshot.hasError) {
                        print('=== STREAM ERROR ===');
                        print('Error: ${snapshot.error}');
                        print('Stack trace: ${snapshot.stackTrace}');
                        return ErrorDisplayWidget.network(
                          onRetry: () {
                            setState(() {
                              _currentStream = _vendorPostsRepository.getAllActivePosts();
                            });
                          },
                        );
                      }
                      
                      final posts = snapshot.data ?? [];
                      
                      if (posts.isEmpty) {
                        return _buildNoPostsMessage();
                      }
                      
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _buildVendorPostCard(post);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVendorPostCard(VendorPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    post.vendorName.isNotEmpty 
                        ? post.vendorName[0].toUpperCase() 
                        : 'V',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.vendorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_selectedSearchPlace != null) ...[
                                  Builder(
                                    builder: (context) {
                                      final distance = _calculateDistance(post);
                                      if (distance != null) {
                                        return Text(
                                          '${distance.toStringAsFixed(1)} km away',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    FavoriteButton(
                      postId: post.id!,
                      vendorId: post.vendorId,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: post.isHappening 
                            ? Colors.green 
                            : post.isUpcoming 
                                ? Colors.orange 
                                : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.isHappening 
                            ? 'Live' 
                            : post.isUpcoming 
                                ? 'Upcoming' 
                                : 'Past',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.formattedDateTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        post.formattedTimeRange,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (post.instagramHandle != null) ...[
                  const Icon(Icons.alternate_email, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    post.instagramHandle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPostsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchLocation.isEmpty ? Icons.event_busy : Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchLocation.isEmpty 
                ? 'No Pop-ups Available'
                : 'No Pop-ups Found in $_searchLocation',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchLocation.isEmpty
                ? 'Check back later for new pop-up events!'
                : 'Try searching for a different location.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchLocation.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(''),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show All Pop-ups'),
            ),
          ],
        ],
      ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}