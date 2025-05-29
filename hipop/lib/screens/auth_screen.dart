import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/common/hipop_text_field.dart';

class AuthScreen extends StatefulWidget {
  final String userType;
  
  const AuthScreen({super.key, required this.userType});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isSignUp = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    print('DEBUG: Submit button pressed!');
    
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }
    
    print('DEBUG: Form validation passed');

    if (_isSignUp) {
      if (_passwordController.text != _confirmPasswordController.text) {
        print('DEBUG: Passwords do not match');
        _showErrorSnackBar('Passwords do not match');
        return;
      }
      
      print('DEBUG: Dispatching SignUpEvent for ${widget.userType}');
      context.read<AuthBloc>().add(SignUpEvent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        userType: widget.userType,
      ));
    } else {
      print('DEBUG: Dispatching LoginEvent for ${widget.userType}');
      context.read<AuthBloc>().add(LoginEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('DEBUG: AuthScreen received state: ${state.runtimeType}');
          if (state is AuthError) {
            print('DEBUG: Auth error: ${state.message}');
            _showErrorSnackBar(state.message);
          } else if (state is PasswordResetSent) {
            _showSuccessSnackBar('Password reset email sent to ${state.email}');
          } else if (state is EmailVerificationSent) {
            _showSuccessSnackBar('Verification email sent');
          } else if (state is Authenticated) {
            print('DEBUG: User authenticated as ${state.userType}');
          } else if (state is AuthLoading) {
            print('DEBUG: Auth loading: ${state.message}');
          }
          // Note: Navigation is handled by AppWrapper in main.dart
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange, Colors.deepOrange],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildForm(),
                            const SizedBox(height: 24),
                            _buildSubmitButton(),
                            const SizedBox(height: 16),
                            _buildToggleButton(),
                            if (!_isSignUp) ...[
                              const SizedBox(height: 16),
                              _buildForgotPasswordButton(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          widget.userType == 'vendor' ? Icons.store : Icons.shopping_bag,
          size: 64,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          '${widget.userType == 'vendor' ? 'Vendor' : 'Shopper'} ${_isSignUp ? 'Sign Up' : 'Login'}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp 
              ? 'Create your account to get started'
              : 'Welcome back! Please sign in',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (_isSignUp) ...[
          HiPopTextField(
            controller: _nameController,
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person_outline),
            textCapitalization: TextCapitalization.words,
            obscureText: false,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
        HiPopTextField(
          controller: _emailController,
          labelText: 'Email',
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          obscureText: false,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        HiPopTextField(
          controller: _passwordController,
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline),
          obscureText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your password';
            }
            if (_isSignUp && value.trim().length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        if (_isSignUp) ...[
          const SizedBox(height: 16),
          HiPopTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please confirm your password';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return HiPopButton(
          text: _isSignUp ? 'Create Account' : 'Sign In',
          onPressed: isLoading ? null : _submitForm,
          isLoading: isLoading,
        );
      },
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _toggleAuthMode,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey[600]),
          children: [
            TextSpan(
              text: _isSignUp 
                  ? 'Already have an account? ' 
                  : "Don't have an account? ",
            ),
            TextSpan(
              text: _isSignUp ? 'Sign In' : 'Sign Up',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        if (_emailController.text.trim().isEmpty) {
          _showErrorSnackBar('Please enter your email address first');
          return;
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Password'),
            content: Text('Send password reset email to ${_emailController.text.trim()}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(
                    ForgotPasswordEvent(email: _emailController.text.trim()),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}