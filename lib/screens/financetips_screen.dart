import 'package:coin_base/main.dart';
import 'package:flutter/material.dart';
import 'package:coin_base/services/pocketbase_service.dart';

class FinanceTipsScreen extends StatefulWidget {
  const FinanceTipsScreen({super.key});

  @override
  State<FinanceTipsScreen> createState() => _FinanceTipsScreenState();
}

class _FinanceTipsScreenState extends State<FinanceTipsScreen> {
  List<Map<String, dynamic>> tips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTips();
  }

  Future<void> _fetchTips() async {
    try {
      final tipRecords = await pocketbaseService.getTips();
      setState(() {
        tips = tipRecords.map((record) => record.toJson()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch tips: \${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Tips"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                tip["title"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(tip["description"]),
            ),
          );
        },
      ),
    );
  }
}

extension on PocketbaseService {
  getTips() {}
}
