import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/core/utils/distance_utils.dart';
import 'package:stitch_smart_church_guide/models/monastery.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';

class MonasteriesScreen extends StatefulWidget {
  const MonasteriesScreen({super.key});

  @override
  State<MonasteriesScreen> createState() => _MonasteriesScreenState();
}

class _MonasteriesScreenState extends State<MonasteriesScreen> {
  final MapController _mapController = MapController();
  Monastery? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapController.move(LatLng(28.5, 31.0), 6.0);
      } catch (_) {}
    });
  }

  List<Marker> _buildMarkers(List<Monastery> monasteries) {
    return monasteries
        .map(
          (m) => Marker(
            width: 40,
            height: 40,
            point: LatLng(m.latitude, m.longitude),
            child: GestureDetector(
              onTap: () => setState(() => _selected = m),
              child: const Icon(
                Icons.location_on,
                color: Colors.yellow,
                size: 36,
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final monasteries = context
        .watch<LocationService>()
        .monasteriesWithDistance();

    return Scaffold(
      appBar: AppBar(title: const Text('الأديرة')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          Widget mapSection() {
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onTap: (_, __) => setState(() => _selected = null),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'org.stitch_smart_church_guide',
                ),
                MarkerLayer(markers: _buildMarkers(monasteries)),
              ],
            );
          }

          Widget listSection() {
            if (monasteries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.temple_buddhist,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد أديرة محفوظة بعد',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: monasteries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final m = monasteries[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => setState(() => _selected = m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          m.imageUrl,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 140,
                            color: AppColors.copticGold.withValues(alpha: 0.1),
                            child: const Icon(Icons.temple_buddhist, size: 48),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                m.governorate,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (m.distanceKm != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  DistanceUtils.formatDistance(m.distanceKm!),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: _selected == null ? 1 : 2, child: mapSection()),
                Expanded(
                  flex: 3,
                  child: _selected != null
                      ? _MonasteryDetail(
                          monastery: _selected!,
                          onClose: () => setState(() => _selected = null),
                        )
                      : listSection(),
                ),
              ],
            );
          }

          return Column(
            children: [
              SizedBox(height: 260, child: mapSection()),
              Expanded(
                child: _selected != null
                    ? _MonasteryDetail(
                        monastery: _selected!,
                        onClose: () => setState(() => _selected = null),
                      )
                    : listSection(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonasteryDetail extends StatelessWidget {
  const _MonasteryDetail({required this.monastery, required this.onClose});

  final Monastery monastery;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Image.network(
                  monastery.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.copticGold.withValues(alpha: 0.1),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton.filled(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monastery.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(monastery.governorate),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'معلومات تاريخية',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(monastery.history),
                  const SizedBox(height: 16),
                  Text(
                    'طرق الوصول',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(monastery.directions),
                  const SizedBox(height: 16),
                  Text(
                    'معرض الصور',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: monastery.gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          monastery.gallery[i],
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
