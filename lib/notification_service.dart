import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print('[NotificationService] Initializing notifications...');
    
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      
      final bool? initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('[NotificationService] Notification tapped: ${response.payload}');
        },
      );
      
      print('[NotificationService] Initialization result: $initialized');
      
      // Create notification channels for Android
      await _createNotificationChannels();
      
      print('[NotificationService] Initialization complete.');
    } catch (e) {
      print('[NotificationService] Error during initialization: $e');
    }
  }

  static Future<void> _createNotificationChannels() async {
    try {
      // Create timer channel
      const AndroidNotificationChannel timerChannel = AndroidNotificationChannel(
        'timer_channel',
        'Timer Notifications',
        description: 'Notifications for timer events',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(timerChannel);
          
      print('[NotificationService] Timer notification channel created successfully');
    } catch (e) {
      print('[NotificationService] Error creating notification channels: $e');
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    print('[NotificationService] showNotification called: title=$title, body=$body');
    
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'timer_channel',
        'Timer Notifications',
        channelDescription: 'Notifications for timer events',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      
      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
      );
      print('[NotificationService] Notification should be shown now.');
    } catch (e) {
      print('[NotificationService] Error showing notification: $e');
    }
  }


} 