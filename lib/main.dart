import 'package:flutter/material.dart';
import 'package:coin_base/screens/welcome_screen.dart';
import 'package:coin_base/services/pocketbase_service.dart'; // Import your Pocketbase service

final pocketbaseService = PocketbaseService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding is initialized for async operations
  
  // Optional: Perform any Pocketbase-related initialization here if needed
  // For example, loading initial data or checking for an active session:
  try {
    if (pocketbaseService.pb.authStore.isValid) {
      // Example: print active user's details
      print("Logged in as: ${pocketbaseService.pb.authStore.model?.toJson()}");
    }
  } catch (e) {
    print("Pocketbase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Base',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
