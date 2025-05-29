import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../repositories/vendor_posts_repository.dart';
import '../models/vendor_post.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({super.key});

  @override
  State<ShopperHome> createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  String _selectedLocation = '';
  final _locationController = TextEditingController();
  late final IVendorPostsRepository _postsRepository;

  @override
  void initState() {
    super.initState();
    _postsRepository = VendorPostsRepository();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.displayName ?? 'Shopper'}!'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _showLocationDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLocationHeader(),
          Expanded(
            child: _selectedLocation.isEmpty 
                ? _buildLocationPrompt()
                : _buildPopUpFeed(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (_selectedLocation.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pop-ups near $_selectedLocation',
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showLocationDialog,
              child: const Text('Change location'),
            ),
          ] else ...[
            const Icon(
              Icons.location_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Set your location to discover pop-ups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Find local vendors, food trucks, and pop-up shops near you',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showLocationDialog,
              icon: const Icon(Icons.location_on),
              label: const Text('Set My Location'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationPrompt() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Discover Local Pop-Ups',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Set your location above to find amazing vendors, food trucks, and pop-up shops happening near you!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopUpFeed() {
    return StreamBuilder<List<VendorPost>>(
      stream: _postsRepository.getAllActivePosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load pop-ups',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data ?? [];
        
        // Filter posts by location if a location is selected
        final filteredPosts = _selectedLocation.isEmpty
            ? posts
            : posts.where((post) => 
                post.location.toLowerCase().contains(_selectedLocation.toLowerCase())
              ).toList();

        if (filteredPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Pop-Ups Found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedLocation.isEmpty
                      ? 'No active pop-ups at the moment.'
                      : 'No pop-ups found near $_selectedLocation.',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_selectedLocation.isNotEmpty)
                  TextButton(
                    onPressed: _showLocationDialog,
                    child: const Text('Try a different location'),
                  ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPosts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = filteredPosts[index];
            return PopUpCard(post: post);
          },
        );
      },
    );
  }

  void _showLocationDialog() {
    _locationController.text = _selectedLocation;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Your Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your city or area to find pop-ups near you:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'City or Area',
                hintText: 'e.g., Atlanta, Downtown, Midtown',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedLocation = _locationController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class PopUpCard extends StatelessWidget {
  final VendorPost post;

  const PopUpCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildLocationInfo(),
            const SizedBox(height: 12),
            _buildTimeInfo(),
            if (post.instagramHandle != null && post.instagramHandle!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInstagramInfo(),
            ],
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.orange,
          child: const Icon(
            Icons.store,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.vendorName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String chipText;
    
    if (post.isHappening) {
      chipColor = Colors.green;
      chipText = 'HAPPENING NOW';
    } else if (post.isUpcoming) {
      chipColor = Colors.orange;
      chipText = 'UPCOMING';
    } else {
      chipColor = Colors.grey;
      chipText = 'PAST EVENT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 20, color: Colors.red[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            post.location,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      children: [
        Icon(Icons.schedule, size: 20, color: Colors.blue[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            post.formattedDateTime,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramInfo() {
    return Row(
      children: [
        Icon(Icons.camera_alt, size: 20, color: Colors.pink[400]),
        const SizedBox(width: 8),
        Text(
          '@${post.instagramHandle}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.pink[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      post.description,
      style: const TextStyle(
        fontSize: 16,
        height: 1.4,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: post.isUpcoming || post.isHappening ? () {} : null,
            icon: const Icon(Icons.favorite_border),
            label: const Text('Interested'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}