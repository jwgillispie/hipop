import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../models/vendor_application.dart';
import '../models/market.dart';
import '../services/vendor_application_service.dart';

class VendorApplicationForm extends StatefulWidget {
  final Market market;

  const VendorApplicationForm({
    super.key,
    required this.market,
  });

  @override
  State<VendorApplicationForm> createState() => _VendorApplicationFormState();
}

class _VendorApplicationFormState extends State<VendorApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasApplied = false;
  
  // Form controllers
  final _vendorNameController = TextEditingController();
  final _vendorEmailController = TextEditingController();
  final _vendorPhoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  
  final List<String> _selectedCategories = [];
  
  // Available product categories for Community Farmers Market
  static const List<String> _productCategories = [
    'Fresh Produce',
    'Herbs & Spices',
    'Baked Goods',
    'Artisan Breads',
    'Local Honey',
    'Jams & Preserves',
    'Pickled Vegetables',
    'Artisan Cheese',
    'Fresh Flowers',
    'Plants & Seedlings',
    'Handmade Crafts',
    'Woodwork',
    'Pottery & Ceramics',
    'Textiles & Clothing',
    'Jewelry',
    'Soaps & Bath Products',
    'Candles',
    'Hot Food',
    'Beverages',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyApplied();
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _vendorEmailController.dispose();
    _vendorPhoneController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _specialRequestsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkIfAlreadyApplied() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final hasApplied = await VendorApplicationService.hasVendorApplied(
        authState.user.uid,
        widget.market.id,
      );
      setState(() {
        _hasApplied = hasApplied;
      });
      
      if (!hasApplied) {
        _prefillUserData(authState);
      }
    }
  }

  void _prefillUserData(Authenticated authState) {
    _vendorNameController.text = authState.user.displayName ?? '';
    _vendorEmailController.text = authState.user.email ?? '';
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate() || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields and select at least one product category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }

      final application = VendorApplication(
        id: '', // Will be set by Firestore
        marketId: widget.market.id,
        vendorId: authState.user.uid,
        vendorName: _vendorNameController.text.trim(),
        vendorEmail: _vendorEmailController.text.trim(),
        vendorPhone: _vendorPhoneController.text.trim().isEmpty 
            ? null 
            : _vendorPhoneController.text.trim(),
        businessName: _businessNameController.text.trim(),
        businessDescription: _businessDescriptionController.text.trim(),
        productCategories: _selectedCategories,
        websiteUrl: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        instagramHandle: _instagramController.text.trim().isEmpty 
            ? null 
            : _instagramController.text.trim(),
        specialRequests: _specialRequestsController.text.trim().isEmpty 
            ? null 
            : _specialRequestsController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await VendorApplicationService.submitApplication(application);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully! You will receive an email when it\'s reviewed.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply to ${widget.market.name}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _hasApplied ? _buildAlreadyAppliedView() : _buildApplicationForm(),
    );
  }

  Widget _buildAlreadyAppliedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Application Already Submitted',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You have already submitted an application to ${widget.market.name}. '
              'The market organizer will review your application and contact you via email.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return to Market'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Info Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.market.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.market.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green.shade600,
                      ),
                    ),
                    if (widget.market.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.market.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vendor Information Section
            _buildSectionHeader('Vendor Information'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vendorNameController,
              decoration: const InputDecoration(
                labelText: 'Your Full Name *',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vendorEmailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vendorPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // Business Information Section
            _buildSectionHeader('Business Information'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name *',
                hintText: 'Enter your business name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Business name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _businessDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Business Description *',
                hintText: 'Describe what you sell and what makes your business special',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Business description is required';
                }
                if (value.trim().length < 50) {
                  return 'Please provide a more detailed description (at least 50 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                hintText: 'https://your-website.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram Handle',
                hintText: '@yourbusiness',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Product Categories Section
            _buildSectionHeader('Product Categories'),
            const SizedBox(height: 8),
            Text(
              'Select all categories that apply to your products *',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildCategorySelection(),
            const SizedBox(height: 32),

            // Special Requests Section
            _buildSectionHeader('Special Requests'),
            const SizedBox(height: 8),
            Text(
              'Any special equipment, space requirements, or other needs?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _specialRequestsController,
              decoration: const InputDecoration(
                labelText: 'Special Requests',
                hintText: 'e.g., Need electrical outlet, prefer corner spot, require refrigeration, etc.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'By submitting this application, you agree to follow the market\'s vendor guidelines and policies. '
              'The market organizer will review your application and contact you via email.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.green.shade700,
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _productCategories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
          selectedColor: Colors.green.withValues(alpha: 0.2),
          checkmarkColor: Colors.green,
          backgroundColor: Colors.grey.shade100,
        );
      }).toList(),
    );
  }
}