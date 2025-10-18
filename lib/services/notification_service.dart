import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_providers.dart';
import 'firebase_service_registry.dart';

class NotificationService {
  NotificationService({required FirebaseServiceRegistry registry})
      : _messaging = registry.firebaseMessaging;

  final FirebaseMessaging _messaging;

  Future<void> initialize({required BuildContext context, required GoRouter router}) async {
    await _requestPermissions();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, router);
    });
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleMessage(initial, router);
    }
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  void _handleMessage(RemoteMessage message, GoRouter router) {
    final type = message.data['type'] as String?;
    switch (type) {
      case 'LOW_WATER':
      case 'LEAK':
      case 'OVERFLOW':
      case 'TAMPER':
        router.go('/alerts');
        break;
      default:
        router.go('/home');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final registry = ref.watch(firebaseServiceRegistryProvider);
  return NotificationService(registry: registry);
});
