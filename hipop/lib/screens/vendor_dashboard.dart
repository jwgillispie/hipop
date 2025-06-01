import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/common/photo_upload_widget.dart';

class VendorDashboard extends StatelessWidget {
  const VendorDashboard({super.key});

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
            title: const Text('Vendor Dashboard'),
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
                              child: Icon(Icons.store, color: Colors.white),
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
                                  state.user.displayName ?? state.user.email ?? 'Vendor',
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
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        context,
                        'Create Pop-up',
                        'Add a new pop-up event',
                        Icons.add_business,
                        Colors.orange,
                        () => context.go('/vendor/create-popup'),
                      ),
                      _buildActionCard(
                        context,
                        'My Pop-ups',
                        'View your active pop-ups',
                        Icons.store,
                        Colors.blue,
                        () => context.go('/vendor/my-popups'),
                      ),
                      _buildActionCard(
                        context,
                        'Analytics',
                        'View your performance',
                        Icons.analytics,
                        Colors.green,
                        () => _showComingSoon(context),
                      ),
                      _buildActionCard(
                        context,
                        'Upload Photos',
                        'Add photos to your gallery',
                        Icons.add_a_photo,
                        Colors.teal,
                        () => _showPhotoUploadDialog(context),
                      ),
                      _buildActionCard(
                        context,
                        'Profile',
                        'Edit your vendor profile',
                        Icons.person,
                        Colors.purple,
                        () => _showComingSoon(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.go('/vendor/create-popup'),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Photo'),
        content: SizedBox(
          width: 300,
          child: PhotoUploadWidget(
            onPhotoSelected: (File photo) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Photo saved to: ${photo.path}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is under development and will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
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