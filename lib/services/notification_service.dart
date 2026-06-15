import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stitch_smart_church_guide/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirestoreService _firestore = FirestoreService();
  String? _currentToken;

  Future<void> init() async {
    try {
      // Request permission (iOS)
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await _messaging.getToken();
      final platform = kIsWeb ? 'web' : Platform.operatingSystem;
      if (token != null) {
        _currentToken = token;
        await _firestore.saveDeviceToken(
          token,
          userId: FirebaseAuth.instance.currentUser?.uid,
          platform: platform,
        );
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        _currentToken = newToken;
        await _firestore.saveDeviceToken(
          newToken,
          userId: FirebaseAuth.instance.currentUser?.uid,
          platform: platform,
        );
      });
    } catch (_) {
      // ignore errors — app should continue even if messaging fails
    }
  }

  Future<void> linkTokenToUser(String userId) async {
    if (_currentToken == null) return;
    await _firestore.associateTokenWithUser(_currentToken!, userId);
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Local schedule not implemented; keep placeholder
  }

  Future<void> cancelNotification(int id) async {}

  Future<void> cancelAllNotifications() async {}
}
