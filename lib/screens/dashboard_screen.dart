import 'package:flutter/material.dart';
import 'package:coin_base/screens/addtransaction_screen.dart' as addTransaction;
import 'package:coin_base/screens/financetips_screen.dart';
import 'package:coin_base/services/pocketbase_service.dart';

class DashboardScreen extends StatefulWidget {
  final PocketbaseService pocketbaseService;

  const DashboardScreen({super.key, required this.pocketbaseService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  double spendingLimit = 50000;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data when the screen is initialized
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Schedule authentication check after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    if (!widget.pocketbaseService.isAuthenticated()) {
      // Show SnackBar after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please sign in to view transactions.")),
        );
      });
      // Optionally, navigate to the sign-in screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
    }
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      if (!widget.pocketbaseService.isAuthenticated()) {
        throw Exception("User not authenticated");
      }

      final transactionRecords = await widget.pocketbaseService.getTransactions();
      debugPrint("Fetched ${transactionRecords.length} transactions");
      for (var record in transactionRecords) {
        debugPrint("Transaction: ${record.data}");
      }

      setState(() {
        transactions = transactionRecords.map((record) => record.data).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch data: ${e.toString()}")),
        );
      });
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showLimitDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBudgetSummary(),
                    const SizedBox(height: 16.0),
                    _buildRecentTransactions(),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FinanceTipsScreen()),
                        );
                      },
                      child: const Text("Finance Tips"),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddTransaction() async {
    if (!widget.pocketbaseService.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please sign in to add a transaction.")),
        );
      });
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const addTransaction.AddTransactionScreen()),
    );

    if (result == true) {
      await _fetchData(); // Refresh the data after adding a transaction
    }
  }

  Widget _buildRecentTransactions() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Transactions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10.0),
          transactions.isEmpty
              ? const Text("No transactions found.")
              : Column(
                  children: transactions.map((transaction) {
                    return ListTile(
                      title: Text(transaction['description'] ?? 'No Description'),
                      subtitle: Text(transaction['date'] ?? 'No Date'),
                      trailing: Text("KSH ${transaction['amount'] ?? '0.00'}"),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTransaction(transaction),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary() {
    double totalSpent = transactions.fold(0, (sum, transaction) {
      final amount = transaction['amount'] ?? 0;
      return sum + (amount is num ? amount.toDouble() : 0);
    });

    double progress = spendingLimit > 0 ? totalSpent / spendingLimit : 0;
    Color progressColor = totalSpent > spendingLimit ? Colors.red : Colors.blue;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Budget",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10.0),
          Text(
            "KSH $totalSpent / KSH $spendingLimit",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: progressColor,
          ),
        ],
      ),
    );
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Spending Limit"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter new limit"),
            onSubmitted: (value) {
              setState(() {
                spendingLimit = double.tryParse(value) ?? spendingLimit;
              });
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(Map<String, dynamic> transaction) async {
    try {
      await widget.pocketbaseService.deleteTransaction(transaction['id']);
      setState(() {
        transactions.remove(transaction);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction deleted successfully!")),
        );
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete transaction: ${e.toString()}")),
        );
      });
      debugPrint("Error deleting transaction: $e");
    }
  }
}