import 'package:coin_base/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketbaseService {
  final PocketBase pb =
      PocketBase('https://cabd-41-220-228-218.ngrok-free.app/');

  // Factory constructor to return the same instance

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      print('email: $email, password: $password');
     final authData= await pb.collection('users').authWithPassword(email, password);
      print('authData: $authData');
      // After authentication, store the user session if needed (e.g., using shared_preferences)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      print('Sign in failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      return true;
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }

  Future<void> logout() async {
    pb.authStore.clear();
  }
}

final pocketbaseService = PocketbaseService();
