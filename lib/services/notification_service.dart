import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _requestPermission();
    await _initializeToken();
    _setupInteractedMessage();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('📱 Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _initializeToken() async {
    String? token = await _messaging.getToken();
    print('✅ FCM Token: $token');

    // Optional: refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM token refreshed: $newToken');
      // Save to Firestore if needed again
    });
  }

  void _setupInteractedMessage() {
    // Tapped notification when app was terminated
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    // Tapped notification when app in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Foreground handling (optional logging or local alerts)
    FirebaseMessaging.onMessage.listen((message) {
      print('📬 Foreground notification: ${message.notification?.title}');
    });
  }

  void _handleMessage(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(route);
      print('🔀 Navigated to route: $route');
    }
  }
}

// Global key to be declared in main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
