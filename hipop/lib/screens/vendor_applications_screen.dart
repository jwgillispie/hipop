import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vendor_application.dart';
import '../services/vendor_application_service.dart';

class VendorApplicationsScreen extends StatefulWidget {
  const VendorApplicationsScreen({super.key});

  @override
  State<VendorApplicationsScreen> createState() => _VendorApplicationsScreenState();
}

class _VendorApplicationsScreenState extends State<VendorApplicationsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String marketId = 'temp_market_id'; // TODO: Get from context/auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Vendor Applications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: _addTestData,
            tooltip: 'Add Test Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList(null),
          _buildApplicationsList(ApplicationStatus.pending),
          _buildApplicationsList(ApplicationStatus.approved),
          _buildApplicationsList(ApplicationStatus.rejected),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareApplicationLink,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.share),
        label: const Text('Share Application Link'),
      ),
    );
  }

  Widget _buildApplicationsList(ApplicationStatus? filterStatus) {
    final stream = filterStatus == null
        ? VendorApplicationService.getApplicationsForMarket(marketId)
        : VendorApplicationService.getApplicationsByStatus(marketId, filterStatus);

    return StreamBuilder<List<VendorApplication>>(
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

        final applications = snapshot.data ?? [];

        if (applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  filterStatus == null 
                      ? 'No applications yet'
                      : 'No ${filterStatus.name} applications',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vendor applications will appear here when submitted.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            return _buildApplicationCard(application);
          },
        );
      },
    );
  }

  Widget _buildApplicationCard(VendorApplication application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        application.businessName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.vendorName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        application.vendorEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(application.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              application.businessDescription,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (application.productCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: application.productCategories
                    .take(3)
                    .map((category) => Chip(
                          label: Text(
                            category,
                            style: const TextStyle(fontSize: 12),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Applied: ${_formatDate(application.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (application.status == ApplicationStatus.pending) ...[
                  TextButton(
                    onPressed: () => _showReviewDialog(application, ApplicationStatus.rejected),
                    child: const Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showReviewDialog(application, ApplicationStatus.approved),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color color;
    switch (status) {
      case ApplicationStatus.pending:
        color = Colors.orange;
        break;
      case ApplicationStatus.approved:
        color = Colors.green;
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        break;
      case ApplicationStatus.waitlisted:
        color = Colors.blue;
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

  void _showReviewDialog(VendorApplication application, ApplicationStatus newStatus) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus.name.toUpperCase()} Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${application.businessName} - ${application.vendorName}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Review Notes (Optional)',
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
                await VendorApplicationService.updateApplicationStatus(
                  application.id,
                  newStatus,
                  'current_organizer_id', // TODO: Get from auth
                  reviewNotes: controller.text.trim().isEmpty ? null : controller.text.trim(),
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Application ${newStatus.name}'),
                      backgroundColor: newStatus == ApplicationStatus.approved ? Colors.green : Colors.red,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == ApplicationStatus.approved ? Colors.green : Colors.red,
            ),
            child: Text(
              newStatus.name.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApplicationLink() async {
    // Generate the shareable application link
    // For development: Use localhost or your development domain
    // For production: Use your actual domain
    const String baseUrl = 'https://hipop.app'; // Change this to your domain
    final applicationUrl = '$baseUrl/apply/$marketId';
    final testUrl = 'hipop://apply/$marketId'; // For development testing
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.green),
            SizedBox(width: 8),
            Expanded(
              child: Text('Share Vendor Application'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this link with potential vendors to let them apply to your market:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      applicationUrl,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: applicationUrl));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This link works without requiring vendors to create an account first. They can apply and you\'ll get their information here.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: testUrl));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test URL copied! Use this for development testing.'),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.bug_report),
            label: const Text('Copy Test URL'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: applicationUrl));
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copied to clipboard!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTestData() async {
    try {
      final applications = [
        VendorApplication(
          id: '',
          marketId: marketId,
          vendorId: 'vendor_1',
          vendorName: 'Sarah Johnson',
          vendorEmail: 'sarah@localbakes.com',
          vendorPhone: '+1-555-0123',
          businessName: 'Local Bakes Co.',
          businessDescription: 'Artisanal bakery specializing in sourdough breads, pastries, and seasonal treats made with locally sourced ingredients.',
          productCategories: ['Baked Goods', 'Artisanal', 'Local'],
          websiteUrl: 'https://localbakes.com',
          instagramHandle: '@localbakes',
          specialRequests: 'Need access to electrical outlet for display refrigerator',
          status: ApplicationStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        VendorApplication(
          id: '',
          marketId: marketId,
          vendorId: 'vendor_2',
          vendorName: 'Mike Chen',
          vendorEmail: 'mike@freshgreens.com',
          vendorPhone: '+1-555-0456',
          businessName: 'Fresh Greens Farm',
          businessDescription: 'Organic vegetable farm offering fresh, seasonal produce including heirloom tomatoes, leafy greens, and herbs.',
          productCategories: ['Organic', 'Vegetables', 'Farm Fresh'],
          websiteUrl: 'https://freshgreens.farm',
          instagramHandle: '@freshgreensfarm',
          specialRequests: 'Would like corner spot for easy truck access',
          status: ApplicationStatus.approved,
          reviewedBy: 'organizer_1',
          reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
          reviewNotes: 'Great addition to our market. Approved!',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        VendorApplication(
          id: '',
          marketId: marketId,
          vendorId: 'vendor_3',
          vendorName: 'Lisa Rodriguez',
          vendorEmail: 'lisa@handmadecrafts.com',
          businessName: 'Handmade Crafts Studio',
          businessDescription: 'Unique handcrafted jewelry, pottery, and home decor items made with sustainable materials.',
          productCategories: ['Handmade', 'Jewelry', 'Home Decor'],
          websiteUrl: 'https://handmadecrafts.com',
          instagramHandle: '@handmadecraftsstudio',
          status: ApplicationStatus.waitlisted,
          reviewedBy: 'organizer_1',
          reviewedAt: DateTime.now().subtract(const Duration(hours: 12)),
          reviewNotes: 'Good application but crafts category is full. Added to waitlist.',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        VendorApplication(
          id: '',
          marketId: marketId,
          vendorId: 'vendor_4',
          vendorName: 'Tom Wilson',
          vendorEmail: 'tom@streetfood.com',
          businessName: 'Tom\'s Street Food',
          businessDescription: 'Gourmet food truck offering Asian fusion dishes, tacos, and specialty sandwiches.',
          productCategories: ['Food Truck', 'Asian Fusion', 'Street Food'],
          specialRequests: 'Need large space for food truck and seating area',
          status: ApplicationStatus.rejected,
          reviewedBy: 'organizer_1',
          reviewedAt: DateTime.now().subtract(const Duration(hours: 6)),
          reviewNotes: 'Food trucks not permitted at this market location due to space constraints.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        VendorApplication(
          id: '',
          marketId: marketId,
          vendorId: 'vendor_5',
          vendorName: 'Emma Thompson',
          vendorEmail: 'emma@naturalsoaps.com',
          vendorPhone: '+1-555-0789',
          businessName: 'Natural Soaps & More',
          businessDescription: 'Handcrafted natural soaps, bath bombs, and skincare products made with organic ingredients.',
          productCategories: ['Natural', 'Skincare', 'Handmade'],
          websiteUrl: 'https://naturalsoaps.com',
          instagramHandle: '@naturalsoapsmore',
          status: ApplicationStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ];

      for (final application in applications) {
        await VendorApplicationService.submitApplication(application);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test data added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding test data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}