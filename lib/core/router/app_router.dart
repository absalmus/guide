import 'package:go_router/go_router.dart';
import 'package:stitch_smart_church_guide/screens/ai/ai_assistant_screen.dart';
import 'package:stitch_smart_church_guide/core/constants/app_constants.dart';
import 'package:stitch_smart_church_guide/screens/admin/admin_portal_screen.dart';
import 'package:stitch_smart_church_guide/screens/auth/login_screen.dart';
import 'package:stitch_smart_church_guide/screens/auth/phone_auth_screen.dart';
import 'package:stitch_smart_church_guide/screens/auth/register_screen.dart';
import 'package:stitch_smart_church_guide/screens/booking/booking_screen.dart';
import 'package:stitch_smart_church_guide/screens/churches/church_detail_screen.dart';
import 'package:stitch_smart_church_guide/screens/churches/churches_explore_screen.dart';
import 'package:stitch_smart_church_guide/screens/home/home_screen.dart';
import 'package:stitch_smart_church_guide/screens/map/map_screen.dart';
import 'package:stitch_smart_church_guide/screens/monasteries/monasteries_screen.dart';
import 'package:stitch_smart_church_guide/screens/notifications/notifications_screen.dart';
import 'package:stitch_smart_church_guide/screens/profile/complete_profile_screen.dart';
import 'package:stitch_smart_church_guide/screens/profile/profile_screen.dart';
import 'package:stitch_smart_church_guide/screens/shell/main_shell.dart';
import 'package:stitch_smart_church_guide/screens/splash/splash_screen.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authService,
    redirect: (context, state) {
      final isAuth = authService.isAuthenticated;
      final path = state.matchedLocation;
      final isAuthRoute =
          path == '/login' ||
          path == '/register' ||
          path == '/phone-auth' ||
          path == '/';
      final isProfileComplete =
          authService.currentProfile?.profileComplete ?? false;

      if (path == '/') return null;

      if (!isAuth && !isAuthRoute) return '/login';

      if (isAuth && isAuthRoute && path != '/') {
        if (!isProfileComplete) return '/complete-profile';
        return '/home';
      }

      if (isAuth && !isProfileComplete && path != '/complete-profile') {
        return '/complete-profile';
      }

      if (path == '/admin' && !(authService.currentProfile?.isAdmin ?? false)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/phone-auth', builder: (_, __) => const PhoneAuthScreen()),
      GoRoute(
        path: '/complete-profile',
        builder: (_, __) => const CompleteProfileScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/churches',
            builder: (_, __) => const ChurchesExploreScreen(),
          ),
          GoRoute(path: '/booking', builder: (_, __) => const BookingScreen()),
          GoRoute(
            path: '/monasteries',
            builder: (_, __) => const MonasteriesScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminPortalScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/church/:id',
        builder: (_, state) =>
            ChurchDetailScreen(churchId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (_, __) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: '/booking-qr/:id',
        builder: (_, state) =>
            BookingQrScreen(bookingId: state.pathParameters['id']!),
      ),
    ],
  );
}
