import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.copticNavy,
              AppColors.copticBurgundy,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.copticGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.copticGold, width: 3),
              ),
              child: const Icon(
                Icons.church,
                size: 60,
                color: AppColors.copticGold,
              ),
            )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: 1200.ms, color: AppColors.copticGold),
            const SizedBox(height: 32),
            Text(
              'دليل الكنيسة الذكي',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.copticCream,
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'Smart Church Guide',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.copticGold,
                  ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.copticGold,
              strokeWidth: 2,
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
