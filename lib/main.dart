import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/app.dart';
import 'package:stitch_smart_church_guide/core/theme/theme_provider.dart';
import 'package:stitch_smart_church_guide/firebase_options.dart';
import 'package:stitch_smart_church_guide/providers/booking_provider.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';
import 'package:stitch_smart_church_guide/services/firestore_service.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';
import 'package:stitch_smart_church_guide/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady =
        DefaultFirebaseOptions.currentPlatform.apiKey != 'YOUR_API_KEY';
  } catch (_) {
    firebaseReady = false;
  }

  final authService = AuthService();
  if (!firebaseReady) {
    await authService.init();
  }

  final firestoreService = FirestoreService();
  final locationService = LocationService(firestoreService: firestoreService);
  await locationService.init();

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: locationService),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const SmartChurchApp(),
    ),
  );
}
