import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_config.dart';
import 'auth_controller.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Request permissions for iOS and newer Android versions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // 2. Initialize Local Notifications (For Foreground messages)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Create a high-importance channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important push notifications.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');

      if (message.notification != null) {
        // Show local notification
        _localNotificationsPlugin.show(
          id: message.notification.hashCode,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              color: const Color(0xFF1B8A4E),
            ),
          ),
        );
      }
    });

    // 4. Get FCM Token and send to backend
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("FCM Token Generated: $token");
        await _saveTokenToBackend(token);
      }

      // Also listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveTokenToBackend(newToken);
      });
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  /// Sends the FCM token to the Django backend to associate with the logged-in user
  static Future<void> _saveTokenToBackend(String fcmToken) async {
    try {
      // In AuthController, the username is the identifier used in this app's API.
      // Wait for auth to be fully loaded if needed.
      final authCtrl = Get.find<AuthController>();
      if (!authCtrl.isLoggedIn.value) return;

      final username = authCtrl.userName.value;
      if (username.isEmpty) return;

      final response = await http.post(
        Uri.parse(AppConfig.saveFcmToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'fcm_token': fcmToken,
          'device_type': 'android', // or determine dynamically
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Successfully saved FCM token to backend.");
      } else {
        print("Failed to save FCM token. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saving FCM token to backend: $e");
    }
  }
}
