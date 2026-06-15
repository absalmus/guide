import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/router/app_router.dart';
import 'package:stitch_smart_church_guide/core/theme/app_theme.dart';
import 'package:stitch_smart_church_guide/core/theme/theme_provider.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';

class SmartChurchApp extends StatefulWidget {
  const SmartChurchApp({super.key});

  @override
  State<SmartChurchApp> createState() => _SmartChurchAppState();
}

class _SmartChurchAppState extends State<SmartChurchApp> {
  late final AuthService _authService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _router = createRouter(_authService);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'دليل الكنيسة الذكي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
