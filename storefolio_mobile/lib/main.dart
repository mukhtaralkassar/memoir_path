import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase services gracefully (template may be built without google-services.json).
  await _safeInitialize(() async {
    await Firebase.initializeApp();
    await AnalyticsService.initialize();
    await NotificationService.instance.initialize();
  });

  runApp(
    const ProviderScope(
      child: StorefolioApp(),
    ),
  );
}

Future<void> _safeInitialize(FutureOr<void> Function() fn) async {
  try {
    await fn();
  } catch (e) {
    debugPrint('main: optional Firebase initialization skipped: $e');
  }
}
