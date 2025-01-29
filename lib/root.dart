// lib/root.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/gp/screens/gp_home_screen.dart';
import 'features/customer/navigation/customer_navigation.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        debugPrint("Root widget state: ${authProvider.state}");

        // Show splash screen while checking auth
        if (authProvider.state == AuthState.authenticating) {
          return const SplashScreen();
        }

        // Navigate based on auth state
        if (authProvider.isAuthenticated && authProvider.user != null) {
          return authProvider.isGP
              ? const GPHomeScreen()
              : const CustomerNavigation();
        }

        return const LoginScreen();
      },
    );
  }
}