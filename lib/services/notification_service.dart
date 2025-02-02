import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showBudgetExceedNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'budget_exceed_channel',
      'Budget Exceed',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

        await _notificationsPlugin.show(
          0,
          'Budget Exceed',
          'You have exceeded your budget limit',
          notificationDetails,
        );
  }
}
