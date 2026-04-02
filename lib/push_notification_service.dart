import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';
import 'exam_model.dart';
import 'study_controller.dart';
import 'story_controller.dart';
import 'characteristic_controller.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static RemoteMessage? coldStartMessage; // 🚀 To store message for SplashPage

  static Future<void> initialize() async {
    // 1. Request permissions for iOS and newer Android versions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Permission granted
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // Provisional permission (iOS)
    } else {
      // Permission denied or not determined
    }

    // 2. Initialize Local Notifications (For Foreground messages)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Named parameter 'settings' is required for v21.0.0
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            processNotification(data);
          } catch (_) {}
        }
      },
    );

    // Create a high-importance channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel_v2', // id (v2 to force refresh)
      'High Importance Notifications', // title
      description:
          'This channel is used for important push notifications.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 3. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show local notification using named parameters (v21.0.0)
        _localNotificationsPlugin.show(
          id: message.notification.hashCode,
          title: message.notification?.title,
          body: message.notification?.body,
          payload: jsonEncode(message.data), // 🔥 Pass data to click handler
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              color: const Color(0xFF1B8A4E),
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
            ),
          ),
        );
      }
    });

    // 4. Handle Notification Clicks (Background/Resume)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      processNotification(message.data);
    });

    // 5. Handle Cold Start (App completely closed)
    // We fetch it here, but SplashPage will trigger the navigation
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        coldStartMessage = message;
      }
    });

    // 6. Get FCM Token and send to backend
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        _saveTokenToBackend(token);
      }

      // Also listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveTokenToBackend(newToken);
      });
    } catch (e) {
      // Handle potential errors quietly
    }
  }

  static void processNotification(Map<String, dynamic> data, {bool isColdStart = false}) {
    // Extract potential navigation keys
    final String nav =
        data['navigation']?.toString() ?? data['route']?.toString() ?? "";
    final String endpoint =
        data['endpoint']?.toString() ?? data['url']?.toString() ?? "";
    final String keyword =
        data['keywords']?.toString() ?? data['keyword']?.toString() ?? "";
    final String id =
        data['id']?.toString() ?? data['exam_id']?.toString() ?? "";

    // Fallback for title: Use provided title OR keywords OR "New Update"
    final String title =
        data['title']?.toString() ??
        data['exam_name']?.toString() ??
        (keyword.isNotEmpty ? keyword : "New Update");

    if (nav.isEmpty) {
      return;
    }

    // 🚀 For cold starts, first ensure we go to Home if the user is logged in
    if (isColdStart) {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn.value) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
        return; // Don't proceed to target route if not logged in
      }
    }

    // Normalization: Map "hierarchy" or add missing "/"
    String route = nav;
    if (nav.toLowerCase() == "hierarchy") {
      route = "/dynamicMenu";
    } else if (!nav.startsWith('/')) {
      route = "/$nav";
    }

    if ((route == "/examSplash" || route == "/exam") && id.isNotEmpty) {
      // 📝 Construct a temporary Exam model for the splash page
      final exam = Exam(
        id: int.tryParse(id) ?? 0,
        category: data['category']?.toString() ?? "Exam",
        specialization: title,
        locked: false,
        totalQuestions:
            int.tryParse(data['total_questions']?.toString() ?? "50") ?? 50,
      );
      Get.toNamed('/examSplash', arguments: {'exam': exam});
    } else if (route == "/story") {
      // 📖 Clear previous story data
      Get.delete<StoryController>();

      // 📖 Story Navigation
      Get.toNamed(
        '/story',
        arguments: {
          'title': title,
          'keywords': [keyword.isNotEmpty ? keyword : title],
          'endpoint': endpoint,
        },
      );
    } else if (route == "/characteristic") {
      // ✨ Clear previous characteristic data
      Get.delete<CharacteristicController>();

      // ✨ Characteristic Navigation
      Get.toNamed(
        '/characteristic',
        arguments: {
          'title': title,
          'keywords': [keyword.isNotEmpty ? keyword : title],
        },
      );
    } else if (route == "/dynamicMenu") {
      // 📂 Dynamic Menu (Hierarchy)
      Get.toNamed(
        '/dynamicMenu',
        arguments: {'title': title, 'endpoint': endpoint},
      );
    } else {
      // 🚀 Special handling for study page
      if (route == "/studyFull") {
        Get.delete<StudyController>();
      }

      // 🚀 General Navigation
      Get.toNamed(
        route,
        arguments: {
          'title': title,
          'id': id,
          'url': endpoint,
          'endpoint': endpoint,
          'keywords': [keyword.isNotEmpty ? keyword : title],
        },
      );
    }
  }

  static Future<void> _saveTokenToBackend(String fcmToken) async {
    try {
      final authCtrl = Get.find<AuthController>();
      if (!authCtrl.isLoggedIn.value) {
        return;
      }

      final userId = authCtrl.userId.value;

      await http.post(
        Uri.parse(AppConfig.saveFcmToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userid': userId,
          'fcm_token': fcmToken,
          'device_type': 'android',
        }),
      );
    } catch (_) {
      // Quietly ignore network failures in background
    }
  }
}
