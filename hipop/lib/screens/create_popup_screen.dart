import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../repositories/vendor_posts_repository.dart';
import '../models/vendor_post.dart';
import '../widgets/common/hipop_text_field.dart';

class CreatePopUpScreen extends StatefulWidget {
  final IVendorPostsRepository postsRepository;
  final VendorPost? editingPost;

  const CreatePopUpScreen({
    super.key,
    required this.postsRepository,
    this.editingPost,
  });

  @override
  State<CreatePopUpScreen> createState() => _CreatePopUpScreenState();
}

class _CreatePopUpScreenState extends State<CreatePopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vendorNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instagramController = TextEditingController();
  
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.editingPost != null) {
      final post = widget.editingPost!;
      _vendorNameController.text = post.vendorName;
      _locationController.text = post.location;
      _descriptionController.text = post.description;
      _instagramController.text = post.instagramHandle ?? '';
      _selectedDateTime = post.popUpDateTime;
    } else {
      // Set default vendor name from user profile
      final user = FirebaseAuth.instance.currentUser;
      _vendorNameController.text = user?.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingPost != null ? 'Edit Pop-Up' : 'Create Pop-Up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 32),
            _buildFormFields(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Icon(
          Icons.store,
          size: 64,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          widget.editingPost != null ? 'Update Your Pop-Up' : 'Create Your Pop-Up Event',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Let customers know where and when to find you!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HiPopTextField(
          controller: _vendorNameController,
          labelText: 'Your Business Name',
          prefixIcon: const Icon(Icons.business),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your business name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        HiPopTextField(
          controller: _locationController,
          labelText: 'Exact Location',
          hintText: 'e.g., 123 Main St, Atlanta, GA',
          prefixIcon: const Icon(Icons.location_on),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDateTimePicker(),
        const SizedBox(height: 16),
        HiPopTextField(
          controller: _descriptionController,
          labelText: 'Description',
          hintText: 'Tell customers what you\'ll be selling...',
          prefixIcon: const Icon(Icons.description),
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        HiPopTextField(
          controller: _instagramController,
          labelText: 'Instagram Handle (Optional)',
          hintText: 'username (without @)',
          prefixIcon: const Icon(Icons.camera_alt),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              // Remove @ if user added it
              if (value.startsWith('@')) {
                _instagramController.text = value.substring(1);
              }
              // Basic validation for Instagram username
              if (!RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(_instagramController.text)) {
                return 'Please enter a valid Instagram username';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return InkWell(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pop-Up Date & Time',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDateTime != null
                        ? _formatDateTime(_selectedDateTime!)
                        : 'Select when your pop-up will happen',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDateTime != null 
                          ? Colors.black87 
                          : Colors.grey[500],
                      fontWeight: _selectedDateTime != null 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        HiPopButton(
          text: widget.editingPost != null ? 'Update Pop-Up' : 'Create Pop-Up',
          onPressed: _isLoading ? null : _savePost,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDateTime ?? now.add(const Duration(hours: 1));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (selectedDate == today) {
      dateStr = 'Today';
    } else if (selectedDate == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
    }
    
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$dateStr at $hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time for your pop-up'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pop-up date and time must be in the future'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      
      if (widget.editingPost != null) {
        // Update existing post
        final updatedPost = widget.editingPost!.copyWith(
          vendorName: _vendorNameController.text.trim(),
          location: _locationController.text.trim(),
          popUpDateTime: _selectedDateTime!,
          description: _descriptionController.text.trim(),
          instagramHandle: _instagramController.text.trim().isEmpty 
              ? null 
              : _instagramController.text.trim(),
          updatedAt: now,
        );
        
        await widget.postsRepository.updatePost(updatedPost);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pop-up updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        // Create new post
        final post = VendorPost(
          id: '', // Will be set by repository
          vendorId: user.uid,
          vendorName: _vendorNameController.text.trim(),
          location: _locationController.text.trim(),
          popUpDateTime: _selectedDateTime!,
          description: _descriptionController.text.trim(),
          instagramHandle: _instagramController.text.trim().isEmpty 
              ? null 
              : _instagramController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        
        await widget.postsRepository.createPost(post);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pop-up created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving pop-up: ${e.toString()}'),
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
}