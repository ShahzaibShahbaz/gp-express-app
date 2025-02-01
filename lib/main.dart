// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gp_express_application/features/auth/screens/splash_screen.dart';
import 'package:gp_express_application/root.dart';
import 'package:provider/provider.dart';
import 'core/constants/color_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/customer/providers/gp_provider.dart';

import 'features/customer/providers/request_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final provider = AuthProvider();
          provider.init();
          return provider;
        }),
        ChangeNotifierProxyProvider<AuthProvider, GPProvider>(
          create: (context) => GPProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) =>
          previous ?? GPProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RequestProvider>(
          create: (context) => RequestProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) =>
          previous ?? RequestProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GP Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
      ),
      home: Root(),
    );
  }
}