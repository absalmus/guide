class Monastery {
  const Monastery({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.governorate,
    required this.history,
    required this.directions,
    required this.gallery,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String governorate;
  final String history;
  final String directions;
  final List<String> gallery;
  final double? distanceKm;

  Monastery copyWith({double? distanceKm}) {
    return Monastery(
      id: id,
      name: name,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      governorate: governorate,
      history: history,
      directions: directions,
      gallery: gallery,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  static Monastery fromMap(String id, Map<String, dynamic> data) {
    return Monastery(
      id: id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      governorate: data['governorate'] as String? ?? '',
      history: data['history'] as String? ?? '',
      directions: data['directions'] as String? ?? '',
      gallery:
          (data['gallery'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
