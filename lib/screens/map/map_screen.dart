import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
// Replaced demo lists with runtime data from LocationService
import 'package:stitch_smart_church_guide/services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _governorate;
  String? _diocese;
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildMarkers());
  }

  void _buildMarkers() {
    final location = context.read<LocationService>();
    final churches = location.churchesWithDistance(
      governorate: _governorate,
      diocese: _diocese,
    );

    setState(() {
      _markers = [
        Marker(
          width: 40,
          height: 40,
          point: LatLng(location.latitude, location.longitude),
          child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
        ),
        ...churches.map(
          (c) => Marker(
            width: 40,
            height: 40,
            point: LatLng(c.latitude, c.longitude),
            child: Icon(
              Icons.location_on,
              color: c.isOpen ? Colors.green : Colors.red,
              size: 36,
            ),
          ),
        ),
      ];
    });

    // Ensure map centers on current location when markers built
    try {
      _mapController.move(LatLng(location.latitude, location.longitude), 11.0);
    } catch (_) {
      // controller not ready yet
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة الكنائس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              await location.getCurrentLocation();
              _buildMarkers();
              try {
                _mapController.move(
                  LatLng(location.latitude, location.longitude),
                  13.0,
                );
              } catch (_) {
                // ignore if controller not ready
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _governorate,
                    decoration: const InputDecoration(
                      labelText: 'المحافظة',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...context
                          .watch<LocationService>()
                          .availableGovernorates
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          ),
                    ],
                    onChanged: (v) {
                      setState(() => _governorate = v);
                      _buildMarkers();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _diocese,
                    decoration: const InputDecoration(
                      labelText: 'الإيبارشية',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...context.watch<LocationService>().availableDioceses.map(
                        (d) => DropdownMenuItem(value: d, child: Text(d)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _diocese = v);
                      _buildMarkers();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(onTap: (_, __) {}),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'org.stitch_smart_church_guide',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.copticNavy,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Legend(color: Colors.green, label: 'مفتوح'),
                _Legend(color: Colors.red, label: 'مغلق'),
                _Legend(color: Colors.blue, label: 'موقعك'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
