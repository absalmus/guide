import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// Use runtime data from LocationService instead of demo constants.
import 'package:stitch_smart_church_guide/services/location_service.dart';
import 'package:stitch_smart_church_guide/widgets/app_search_bar.dart';
import 'package:stitch_smart_church_guide/widgets/church_card.dart';

class ChurchesExploreScreen extends StatefulWidget {
  const ChurchesExploreScreen({super.key});

  @override
  State<ChurchesExploreScreen> createState() => _ChurchesExploreScreenState();
}

class _ChurchesExploreScreenState extends State<ChurchesExploreScreen> {
  String _search = '';
  String? _governorate;

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();
    var churches = location.churchesWithDistance(governorate: _governorate);

    if (_search.isNotEmpty) {
      churches = churches
          .where(
            (c) => c.name.contains(_search) || c.governorate.contains(_search),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('استكشاف الكنائس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/map'),
          ),
        ],
      ),
      body: Column(
        children: [
          AppSearchBar(
            readOnly: false,
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: _governorate == null,
                  onSelected: (_) => setState(() => _governorate = null),
                ),
                const SizedBox(width: 8),
                ...context.watch<LocationService>().availableGovernorates.map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(g),
                      selected: _governorate == g,
                      onSelected: (_) => setState(() => _governorate = g),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: churches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => ChurchCard(
                church: churches[i],
                onTap: () => context.push('/church/${churches[i].id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
