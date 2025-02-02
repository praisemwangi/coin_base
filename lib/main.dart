import 'package:flutter/material.dart';
import 'package:coin_base/screens/welcome_screen.dart';
import 'package:coin_base/services/pocketbase_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:coin_base/services/notification_service.dart';

final PocketbaseService pocketbaseService = PocketbaseService();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding is initialized for async operations

  await initNotifications();

  // Check if user is already authenticated
  try {
    if (pocketbaseService.isAuthenticated()) {
      print("Logged in as: ${pocketbaseService.pb.authStore.model.toJson()}");
    }
  } catch (e) {
    print("Pocketbase initialization failed: $e");
  }

  runApp(const MyApp());
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await NotificationService.initNotifications();
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