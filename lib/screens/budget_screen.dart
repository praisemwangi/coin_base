import 'package:coin_base/main.dart';
import 'package:flutter/material.dart';
import 'package:coin_base/services/pocketbase_service.dart';
import 'package:coin_base/services/notification_service.dart';
import 'package:pocketbase/pocketbase.dart';

class BudgetManagementScreen extends StatefulWidget {
  final Map<String, dynamic> budget;

  const BudgetManagementScreen({super.key, required this.budget});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  Future<void> _addExpense(double amount) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense amount must be greater than 0")),
      );
      return;
    }

    try {
      final updatedSpent = widget.budget["spent"] + amount;
      await pocketbaseService.pb
          .collection('budgets')
          .update(widget.budget["id"], body: {
        "spent": updatedSpent,
      });
      setState(() {
        widget.budget["spent"] = updatedSpent;
      });

      if (updatedSpent > widget.budget["amount"]) {
        NotificationService.showBudgetExceedNotification();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add expense: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.budget["spent"] / widget.budget["amount"];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget["category"]),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue),
                  const SizedBox(height: 10.0),
                  Text(
                      "\$${widget.budget["spent"]} / \$${widget.budget["amount"]}"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showAddExpenseDialog(),
              child: const Text("Add Expense"),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Expense"),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              amount = double.tryParse(value) ?? 0.0;
            },
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (amount > 0) {
                  _addExpense(amount);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter a valid amount")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
