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
            // Clean, instantaneous routing without the FutureBuilder loop!
            if (authProvider.isAuthenticated) {
              return const DashboardScreen();
            } else {
              return const AuthScreen(); // (or LoginScreen, depending on your naming)
            }
          },
        ),
    );
  }
}