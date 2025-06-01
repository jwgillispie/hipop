import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/common/location_search_widget.dart';
import '../models/vendor_post.dart';
import '../repositories/vendor_posts_repository.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({super.key});

  @override
  State<ShopperHome> createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  String _searchLocation = '';
  final VendorPostsRepository _vendorPostsRepository = VendorPostsRepository();
  Stream<List<VendorPost>>? _currentStream;

  @override
  void initState() {
    super.initState();
    _initializeAndMigrate();
  }

  Future<void> _initializeAndMigrate() async {
    print('=== INITIALIZING SHOPPER HOME ===');
    
    // Debug: Show all posts in Firestore
    try {
      await _vendorPostsRepository.debugAllPosts();
    } catch (e) {
      print('Debug failed: $e');
    }
    
    // Check if migration is needed and run it
    try {
      final needsMigration = await _vendorPostsRepository.needsMigration();
      print('Needs migration: $needsMigration');
      
      if (needsMigration) {
        print('Running migration for existing posts...');
        await _vendorPostsRepository.migratePostsWithLocationKeywords();
        print('Migration completed successfully');
        
        // Debug again after migration
        await _vendorPostsRepository.debugAllPosts();
      }
    } catch (e) {
      print('Migration failed, but continuing: $e');
    }
    
    // Create a test post if none exist (for debugging)
    try {
      await _createTestPostIfNeeded();
    } catch (e) {
      print('Failed to create test post: $e');
    }
    
    // Start with empty search to show all posts
    print('Starting with empty search...');
    _performSearch('');
  }

  Future<void> _createTestPostIfNeeded() async {
    // Create a simple test post to ensure we have data
    print('Creating test post for debugging...');
    
    final testPost = VendorPost(
      id: '',
      vendorId: 'test-vendor-123',
      vendorName: 'Test Vendor',
      description: 'This is a test pop-up to verify the app is working',
      location: 'your moms',
      locationKeywords: VendorPost.generateLocationKeywords('your moms'),
      popUpDateTime: DateTime.now().add(const Duration(hours: 1)), // 1 hour from now
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    
    try {
      await _vendorPostsRepository.createPost(testPost);
      print('Test post created successfully');
    } catch (e) {
      print('Test post may already exist: $e');
    }
  }

  void _performSearch(String location) {
    setState(() {
      _searchLocation = location;
      _currentStream = _vendorPostsRepository.searchPostsByLocation(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
                LocationSearchWidget(
                  onLocationChanged: _performSearch,
                  initialLocation: _searchLocation,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchLocation.isEmpty 
                        ? 'All Pop-ups' 
                        : 'Pop-ups in $_searchLocation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading pop-ups',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please try again later',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
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
                            child: Text(
                              post.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                Text(
                  post.formattedDateTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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