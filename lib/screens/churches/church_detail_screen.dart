import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/core/constants/enums.dart';
import 'package:stitch_smart_church_guide/core/utils/distance_utils.dart';
import 'package:stitch_smart_church_guide/models/church.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';
import 'package:stitch_smart_church_guide/widgets/category_chip.dart';

class ChurchDetailScreen extends StatefulWidget {
  const ChurchDetailScreen({super.key, required this.churchId});

  final String churchId;

  @override
  State<ChurchDetailScreen> createState() => _ChurchDetailScreenState();
}

class _ChurchDetailScreenState extends State<ChurchDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Church? _church;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final location = context.read<LocationService>();
    _church = location.findChurchById(widget.churchId);
    if (_church != null) {
      final km = DistanceUtils.haversineKm(
        location.latitude,
        location.longitude,
        _church!.latitude,
        _church!.longitude,
      );
      _church = _church!.copyWith(distanceKm: km);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_church == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('الكنيسة غير موجودة')),
      );
    }

    final church = _church!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    church.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.copticBurgundy.withValues(alpha: 0.2),
                      child: const Icon(Icons.church, size: 80),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                church.name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _InfoChip(
                    icon: Icons.circle,
                    label: church.isOpen ? 'مفتوح' : 'مغلق',
                    color: church.isOpen ? AppColors.openGreen : AppColors.closedRed,
                  ),
                  const SizedBox(width: 8),
                  if (church.distanceKm != null)
                    _InfoChip(
                      icon: Icons.location_on,
                      label: DistanceUtils.formatDistance(church.distanceKm!),
                      color: AppColors.copticBurgundy,
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push('/map'),
                    icon: const Icon(Icons.map),
                    tooltip: 'عرض على الخريطة',
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'معلومات'),
                  Tab(text: 'المواعيد'),
                  Tab(text: 'الاجتماعات'),
                  Tab(text: 'الخدمات'),
                  Tab(text: 'معرض الصور'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _InfoTab(church: church),
            _ScheduleTab(church: church),
            _MeetingsTab(church: church),
            _ServicesTab(church: church),
            _GalleryTab(church: church),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.church});
  final Church church;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(church.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        _DetailRow(icon: Icons.location_on, label: 'العنوان', value: church.address),
        _DetailRow(icon: Icons.phone, label: 'الهاتف', value: church.phone),
        _DetailRow(icon: Icons.account_balance, label: 'الإيبارشية', value: church.diocese),
        _DetailRow(icon: Icons.location_city, label: 'المحافظة', value: church.governorate),
      ],
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.church});
  final Church church;

  @override
  Widget build(BuildContext context) {
    final grouped = <LiturgyType, List<LiturgySchedule>>{};
    for (final l in church.liturgies) {
      grouped.putIfAbsent(l.type, () => []).add(l);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: LiturgyType.values.map((type) {
        final items = grouped[type];
        if (items == null || items.isEmpty) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
            title: Text(type.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            children: items
                .map(
                  (l) => ListTile(
                    title: Text(l.day),
                    trailing: Text(l.time),
                  ),
                )
                .toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _MeetingsTab extends StatelessWidget {
  const _MeetingsTab({required this.church});
  final Church church;

  @override
  Widget build(BuildContext context) {
    final grouped = <AgeCategory, List<MeetingSchedule>>{};
    for (final m in church.meetings) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: AgeCategory.values.map((cat) {
        final items = grouped[cat];
        if (items == null || items.isEmpty) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Icon(categoryIcon(cat), color: AppColors.copticGold),
            title: Text(cat.label),
            children: items
                .map(
                  (m) => ListTile(
                    title: Text(m.title),
                    subtitle: Text(m.location),
                    trailing: Text('${m.day}\n${m.time}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                )
                .toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.church});
  final Church church;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: church.services.length,
      itemBuilder: (_, i) {
        final service = church.services[i];
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.copticOlive, size: 32),
              const SizedBox(height: 8),
              Text(service.label, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.church});
  final Church church;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: church.gallery.length,
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          church.gallery[i],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.image),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.copticBurgundy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
