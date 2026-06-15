import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/core/theme/theme_provider.dart';
import 'package:stitch_smart_church_guide/providers/booking_provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_constants.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<AuthService>().currentProfile;
      if (profile != null) {
        context.read<BookingProvider>().loadUserBookings(profile.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthService>().currentProfile;
    final themeProvider = context.watch<ThemeProvider>();
    final bookings = context.watch<BookingProvider>().bookings;
    final favoriteChurches = context
        .watch<LocationService>()
        .churches
        .where((c) => profile?.favoriteChurchIds.contains(c.id) ?? false)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.copticBurgundy.withValues(alpha: 0.15),
              child: Text(
                (profile?.name.isNotEmpty == true)
                    ? profile!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 36,
                  color: AppColors.copticBurgundy,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile?.name ?? 'زائر',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              profile?.email ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _ProfileTile(
              icon: Icons.category,
              title: 'الفئة العمرية',
              subtitle: profile?.category.label ?? '—',
            ),
            _ProfileTile(
              icon: Icons.location_city,
              title: 'المحافظة',
              subtitle: profile?.governorate ?? '—',
            ),
            if (profile?.churchId != null)
              _ProfileTile(
                icon: Icons.church,
                title: 'الكنيسة التابعة',
                subtitle:
                    context
                        .read<LocationService>()
                        .findChurchById(profile!.churchId!)
                        ?.name ??
                    '—',
              ),
            const Divider(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الكنائس المفضلة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            if (favoriteChurches.isEmpty)
              const Text(
                'لا توجد كنائس مفضلة بعد',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...favoriteChurches.map(
                (c) => ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: AppColors.copticBurgundy,
                  ),
                  title: Text(c.name),
                  dense: true,
                ),
              ),
            const Divider(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الحجوزات السابقة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            if (bookings.isEmpty)
              const Text('لا توجد حجوزات', style: TextStyle(color: Colors.grey))
            else
              ...bookings
                  .take(3)
                  .map(
                    (b) => ListTile(
                      leading: Icon(b.type.icon),
                      title: Text(b.title),
                      subtitle: Text(b.churchName),
                      trailing: const Icon(Icons.qr_code),
                      onTap: () => context.push('/booking-qr/${b.id}'),
                    ),
                  ),
            const Divider(height: 32),
            SwitchListTile(
              title: const Text('الوضع الداكن'),
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggle(),
            ),
            const SizedBox(height: 16),
            if (profile?.email == kAdminEmail)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/admin'),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('لوحة الإدارة'),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthService>().signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.closedRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.copticBurgundy),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}
