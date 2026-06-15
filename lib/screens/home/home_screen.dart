import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
// Replaced demo events with runtime data
import 'package:stitch_smart_church_guide/services/auth_service.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';
import 'package:stitch_smart_church_guide/widgets/app_search_bar.dart';
import 'package:stitch_smart_church_guide/widgets/church_card.dart';
import 'package:stitch_smart_church_guide/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthService>().currentProfile;
    final location = context.watch<LocationService>();
    final churches = location.churchesWithDistance().take(5).toList();
    final userCategory = profile?.category;

    final meetings = churches
        .expand((c) => c.meetings)
        .where((m) => userCategory == null || m.category == userCategory)
        .take(4)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<LocationService>().getCurrentLocation(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اهلاً',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            Text(
                              profile?.name ?? 'زائر',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                      IconButton(
                        onPressed: () => context.push('/ai-assistant'),
                        icon: const Icon(Icons.smart_toy_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AppSearchBar(onTap: () => context.go('/churches')),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'كنائس قريبة منك',
                  actionLabel: 'عرض الكل',
                  onAction: () => context.go('/churches'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: churches.isEmpty ? 120 : 230,
                  child: churches.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.church,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'لا توجد كنائس محفوظة بعد',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: churches.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (_, i) {
                            final church = churches[i];
                            return SizedBox(
                              width: 300,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () =>
                                    context.push('/church/${church.id}'),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.network(
                                          church.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: AppColors.copticBurgundy
                                                    .withValues(alpha: 0.1),
                                                child: const Icon(
                                                  Icons.church,
                                                  size: 48,
                                                ),
                                              ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.04),
                                              Colors.black.withOpacity(0.28),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 14,
                                        right: 14,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.92,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            church.distanceKm != null
                                                ? '${church.distanceKm!.toStringAsFixed(1)} كم'
                                                : 'موقع قريب',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.72),
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                church.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                church.governorate,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule,
                                                    color: Colors.white70,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      church.nextLiturgy,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 13,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: SectionHeader(title: 'القداسات القادمة'),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  final church = churches[i % churches.length];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.copticBurgundy.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.church,
                        color: AppColors.copticBurgundy,
                      ),
                    ),
                    title: Text(church.name),
                    subtitle: Text(church.nextLiturgy),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push('/church/${church.id}'),
                  );
                }, childCount: churches.length.clamp(0, 3)),
              ),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'الاجتماعات القادمة',
                  actionLabel: 'حسب فئتي',
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  final meeting = meetings[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.groups,
                        color: AppColors.copticGold,
                      ),
                      title: Text(meeting.title),
                      subtitle: Text('${meeting.day} - ${meeting.time}'),
                      trailing: Chip(
                        label: Text(
                          meeting.category.label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  );
                }, childCount: meetings.length),
              ),
              SliverToBoxAdapter(
                child: SectionHeader(title: 'الأنشطة المقترحة'),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  if (meetings.isEmpty) return const SizedBox.shrink();
                  final meeting = meetings[i % meetings.length];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.copticGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: AppColors.copticGold,
                        ),
                      ),
                      title: Text(meeting.title),
                      subtitle: Text('${meeting.day} - ${meeting.location}'),
                      trailing: TextButton(
                        onPressed: () => context.go('/booking'),
                        child: const Text('ذكرني'),
                      ),
                    ),
                  );
                }, childCount: meetings.length.clamp(0, 5)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
