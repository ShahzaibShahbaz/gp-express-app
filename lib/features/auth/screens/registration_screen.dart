import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/user_type_switch.dart';
import '../../../core/utils/feedback_utils.dart';
import '../../../core/constants/color_constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _isGP = false;
  bool _acceptTerms = false;
  bool _hasSubmittedId = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_acceptTerms) {
      FeedbackUtils.showErrorSnackBar(
        context,
        'Please accept the terms and privacy policy',
      );
      return;
    }

    if (_isGP && !_hasSubmittedId) {
      FeedbackUtils.showErrorSnackBar(
        context,
        'Please indicate that you have submitted your ID',
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        final success = await context.read<AuthProvider>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          userType: _isGP ? UserType.gp : UserType.customer,
          phoneNumber: _phoneController.text.trim(),
          hasSubmittedId: _hasSubmittedId,
        );

        if (success && mounted) {
          FeedbackUtils.showSuccessSnackBar(
            context,
            'Account created successfully! Please login.',
          );

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.pop(context, _emailController.text);
          }
        }
      } catch (e) {
        if (mounted) {
          FeedbackUtils.showErrorSnackBar(
            context,
            e.toString(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and logo
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      'gpEx',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // User Type Switch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: UserTypeSwitch(
                  isGP: _isGP,
                  onChanged: (value) => setState(() => _isGP = value),
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isGP
                              ? 'Inscription en tant que GP'
                              : 'Inscription en tant que Client',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _fullNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (_isGP && (value == null || value.isEmpty)) {
                              return 'Phone number is required for GPs';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        if (_isGP) ...[
                          const SizedBox(height: 24),
                          // ID Submission Checkbox
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _hasSubmittedId,
                                  onChanged: (value) {
                                    setState(() {
                                      _hasSubmittedId = value ?? false;
                                    });
                                  },
                                  fillColor: MaterialStateProperty.resolveWith(
                                        (states) => states.contains(MaterialState.selected)
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  checkColor: AppColors.primaryBlue,
                                  side: const BorderSide(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'I confirm that I have submitted my ID document',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Terms and Privacy Policy Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                fillColor: MaterialStateProperty.resolveWith(
                                      (states) => states.contains(MaterialState.selected)
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                checkColor: AppColors.primaryBlue,
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'I accept the terms and privacy policy',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Sign Up Button
                        AuthButton(
                          text: 'Sign up',
                          onPressed: context.watch<AuthProvider>().isLoading
                              ? null
                              : _register,
                          isLoading: context.watch<AuthProvider>().isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: context.watch<AuthProvider>().isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}