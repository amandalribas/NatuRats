import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:naturats/service/user_service.dart';

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    UserService? userService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _userService = userService ?? UserService();

  final FirebaseMessaging _messaging;
  final UserService _userService;
  StreamSubscription<String>? _tokenSubscription;

  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }


  Future<void> registerDeviceToken(String userId) async {
    final granted = await _requestPermission();
    if (!granted) {
      debugPrint('Notification permission not granted.');
      return;
    }

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('FCM token not available.');
      return;
    }

    await _userService.addFcmToken(userId, token);
  }

  void startTokenRefreshListener(String userId) {
    _tokenSubscription?.cancel();
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      try {
        await _userService.addFcmToken(userId, token);
      } catch (e) {
        debugPrint('Error updating FCM token: $e');
      }
    });
  }

  Future<void> unregisterDeviceToken(String userId) async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await _userService.removeFcmToken(userId, token);
  }

  void stopTokenRefreshListener() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
  }
}
