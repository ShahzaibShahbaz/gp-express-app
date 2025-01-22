import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/user_type_switch.dart';
import '../../../core/utils/feedback_utils.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isGP = false;

  @override
  void initState() {
    super.initState();
    // Clear fields when screen is loaded/reloaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final success = await context.read<AuthProvider>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          isGP: _isGP, // Pass the selected user type
        );

        if (success && mounted) {
          FeedbackUtils.showSuccessSnackBar(
            context,
            'Successfully logged in!',
          );
          // Add a small delay before navigation
          await Future.delayed(const Duration(seconds: 1));
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
      backgroundColor: const Color(0xFF1976D2),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1976D2),
              const Color(0xFF1976D2).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with app name
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'gpEx',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        const Text(
                          'Connectez-vous à gpExpress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
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
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
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
                        const SizedBox(height: 32),
                        AuthButton(
                          text: 'Log in',
                          onPressed: context.watch<AuthProvider>().isLoading
                              ? null
                              : () async {  // Wrap in a synchronous callback
                            await _login();
                          },
                          isLoading: context.watch<AuthProvider>().isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Vous n\'avez pas de compte ? ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: context.watch<AuthProvider>().isLoading
                                  ? null
                                  : () async {
                                final email = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const RegistrationScreen(),
                                  ),
                                );

                                if (email != null && mounted) {
                                  _emailController.text = email;
                                }
                              },
                              child: const Text(
                                'S\'inscrire',
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