import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/carbon_provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarbonProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const EcoTrackerApp(),
    ),
  );
}

class EcoTrackerApp extends StatelessWidget {
  const EcoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
      ),
      // Wrapped in a Consumer to monitor real-time authentication state changes
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // 1. If the provider already has an active, valid memory state, load Dashboard instantly
          if (authProvider.isAuthenticated) {
            return const DashboardScreen();
          }

          // 2. Otherwise, check physical hardware storage for old user sessions
          return FutureBuilder<bool>(
            future: authProvider.tryAutoLogin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  ),
                );
              }
              
              // If auto-login recovers a session token, it triggers consumer to load dashboard.
              // Otherwise, safely fallback to the Auth login portal screen.
              if (snapshot.data == true) {
                return const DashboardScreen();
              } else {
                return const AuthScreen();
              }
            },
          );
        },
      ),
    );
  }
}