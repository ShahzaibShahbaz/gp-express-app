import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/text_constants.dart';
import '../../gp/screens/gp_home_screen.dart';
import '../providers/auth_provider.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryBlue,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppTexts.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
                Builder(
                  builder: (_) {
                    if (auth.isAuthenticated) {
                      Future.microtask(() => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => auth.isGP
                              ? const GPHomeScreen()
                              : const Text("he"),
                        ),
                      ));
                    } else if (auth.state == AuthState.initial) {
                      Future.microtask(() => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}