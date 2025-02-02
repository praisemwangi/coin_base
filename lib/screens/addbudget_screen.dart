import 'package:coin_base/main.dart';
import 'package:flutter/material.dart';
import 'package:coin_base/services/pocketbase_service.dart';

class AddBudgetScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onBudgetAdded;

  const AddBudgetScreen({super.key, required this.onBudgetAdded});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Budget"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addBudget,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBudget() async {
    if (_categoryController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final budget = {
        "category": _categoryController.text,
        "amount": double.parse(_amountController.text),
        "spent": 0.0,
      };

      await pocketbaseService.addBudget(budget);
      widget.onBudgetAdded(budget); // Notify parent widget
      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add budget: ${e.toString()}")),
      );
    }
  }
}

extension on PocketbaseService {
  addBudget(Map<String, Object> budget) {}
}