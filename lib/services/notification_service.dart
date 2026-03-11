import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../models/hive_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // --- هذا هو السطر الذي عالجنا فيه الخطأين ---
    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    _startPeriodicChecks();
  }

  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationTap(payload);
    }
  }

  static void _handleNotificationTap(String payload) {
    final parts = payload.split('|');
    if (parts.length >= 2) {
      final type = parts[0];
      final id = parts[1];

      switch (type) {
        case 'hive_inspection':
        case 'hive_upgrade':
        case 'hive_division':
          _navigateToHiveDetails(id);
          break;
        case 'treatment_end':
          _navigateToTreatmentDetails(id);
          break;
      }
    }
  }

  static void _navigateToHiveDetails(String hiveId) {}
  static void _navigateToTreatmentDetails(String treatmentId) {}

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'hivelog_bee_channel',
      'HiveLog Bee Notifications',
      channelDescription: 'Notifications for beekeeping activities',
      importance: _getImportance(priority),
      priority: _getPriority(priority),
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFFC107),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // استخدام الوسائط المسماة كما هو مطلوب في الإصدارات الحديثة
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  static void _startPeriodicChecks() {
    Timer.periodic(const Duration(hours: 1), (_) {
      _checkOverdueInspections();
      _checkTreatmentReminders();
      _checkHiveUpgrades();
      _checkHiveDivisions();
    });
  }

  static Future<void> _checkOverdueInspections() async {}
  static Future<void> _checkTreatmentReminders() async {}
  static Future<void> _checkHiveUpgrades() async {}
  static Future<void> _checkHiveDivisions() async {}

  static Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }

  static Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }

  static Future<void> createReminderNotification(ReminderModel reminder) async {}
  static Future<void> updateReminderNotification(ReminderModel reminder) async {}
  static Future<void> deleteReminderNotification(String reminderId) async {}
  static Future<void> notifyHiveAdded(HiveModel hive) async {}
}

enum NotificationPriority {
  low,
  defaultPriority,
  high,
  max,
}