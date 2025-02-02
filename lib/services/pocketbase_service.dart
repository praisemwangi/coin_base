import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketbaseService {
  static final PocketbaseService _instance = PocketbaseService._internal();
  final PocketBase pb;

  factory PocketbaseService() => _instance;

  PocketbaseService._internal()
      : pb = PocketBase('https://cb47-41-90-45-140.ngrok-free.app/') {
    debugPrint("✅ PocketBase initialized with URL: ${pb.baseUrl}");
  }

  /// ✅ Sign in a user with email and password.
  Future<bool> signIn(String email, String password) async {
    try {
      final authData = await pb.collection('users').authWithPassword(email, password);
      debugPrint("✅ Sign-in successful: ${authData.record.id}");
      return true;
    } catch (e) {
      debugPrint("❌ Sign-in failed: $e");
      return false;
    }
  }

  /// ✅ Check if the user is authenticated.
  bool isAuthenticated() => pb.authStore.isValid;

  /// ✅ Sign out the user.
  Future<void> signOut() async {
    pb.authStore.clear();
    debugPrint("🚪 User signed out");
  }

  /// ✅ Fetch transactions for the authenticated user.
  Future<List<RecordModel>> getTransactions() async {
    if (!isAuthenticated()) {
      throw Exception("❌ User not authenticated");
    }

    final user = pb.authStore.model;
    if (user == null) {
      throw Exception("❌ No user found in authStore");
    }

    try {
      debugPrint("🔄 Fetching transactions for user ID: ${user.id}");

      // Use the correct field name (e.g., user_id or userId)
      final records = await pb.collection('transactions').getFullList(
        filter: 'user_id = "${user.id}"', // Updated field name
      );

      debugPrint("✅ Retrieved ${records.length} transactions");
      return records;
    } catch (e) {
      debugPrint("❌ Error fetching transactions: $e");
      return [];
    }
  }

  /// ✅ Add a new transaction for the authenticated user.
  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    if (!isAuthenticated()) {
      throw Exception("❌ User not authenticated");
    }

    final user = pb.authStore.model;
    if (user == null) {
      throw Exception("❌ No user found in authStore");
    }

    try {
      await pb.collection('transactions').create(body: {
        'user_id': user.id, // Updated field name
        'amount': transaction['amount'],
        'description': transaction['description'],
        'category': transaction['category'],
        'type': transaction['type'],
        'date': DateTime.now().toIso8601String(),
      });
      debugPrint("✅ Transaction added successfully");
    } catch (e) {
      debugPrint("❌ Error adding transaction: $e");
      rethrow;
    }
  }

  /// ✅ Delete a transaction by ID.
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await pb.collection('transactions').delete(transactionId);
      debugPrint("✅ Transaction deleted successfully");
    } catch (e) {
      debugPrint("❌ Error deleting transaction: $e");
      rethrow;
    }
  }

  /// ✅ Update an existing transaction by ID.
  Future<void> updateTransaction(String transactionId, Map<String, dynamic> updates) async {
    try {
      await pb.collection('transactions').update(transactionId, body: updates);
      debugPrint("✅ Transaction updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating transaction: $e");
      rethrow;
    }
  }

  /// ✅ Get the current authenticated user's ID.
  String? getCurrentUserId() {
    return pb.authStore.model?.id;
  }

  /// ✅ Clear the authentication store (useful for testing or logging out).
  void clearAuthStore() {
    pb.authStore.clear();
    debugPrint("🧹 Auth store cleared");
  }

  getTips() {}

  addBudget(Map<String, dynamic> budget) {}
}