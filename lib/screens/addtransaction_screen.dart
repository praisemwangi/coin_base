import 'package:flutter/material.dart';
import 'package:coin_base/services/pocketbase_service.dart';

final PocketbaseService pocketbaseService = PocketbaseService();

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  String _transactionType = 'expense';
  bool _isLoading = false;

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (!pocketbaseService.isAuthenticated()) {
        throw Exception("User not authenticated");
      }

      final transaction = {
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
        'category': _selectedCategory ?? 'Other', // Ensuring category is not null
        'type': _transactionType,
        'date': DateTime.now().toIso8601String(),
      };

      await pocketbaseService.addTransaction(transaction);

      // Return to the previous screen and refresh
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add transaction: ${e.toString()}")),
      );
      debugPrint("Error adding transaction: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter an amount";
                  if (double.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => value == null || value.isEmpty ? "Please enter a description" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text("Select Category"),
                items: ["Food", "Transport", "Entertainment", "Other"]
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) => value == null ? "Select a category" : null,
              ),
              const SizedBox(height: 12),
              const Text("Transaction Type", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(
                    value: "income",
                    groupValue: _transactionType,
                    onChanged: (value) => setState(() => _transactionType = value!),
                  ),
                  const Text("Income"),
                  Radio<String>(
                    value: "expense",
                    groupValue: _transactionType,
                    onChanged: (value) => setState(() => _transactionType = value!),
                  ),
                  const Text("Expense"),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitTransaction,
                        child: const Text("Add Transaction"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}