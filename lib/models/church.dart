import 'package:stitch_smart_church_guide/core/constants/enums.dart';

class LiturgySchedule {
  const LiturgySchedule({
    required this.type,
    required this.day,
    required this.time,
  });

  final LiturgyType type;
  final String day;
  final String time;
}

class MeetingSchedule {
  const MeetingSchedule({
    required this.category,
    required this.title,
    required this.day,
    required this.time,
    required this.location,
  });

  final AgeCategory category;
  final String title;
  final String day;
  final String time;
  final String location;
}

class Church {
  const Church({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.governorate,
    required this.diocese,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.nextLiturgy,
    required this.description,
    required this.liturgies,
    required this.meetings,
    required this.services,
    required this.gallery,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String governorate;
  final String diocese;
  final String address;
  final String phone;
  final bool isOpen;
  final String nextLiturgy;
  final String description;
  final List<LiturgySchedule> liturgies;
  final List<MeetingSchedule> meetings;
  final List<ChurchService> services;
  final List<String> gallery;
  final double? distanceKm;

  Church copyWith({double? distanceKm, bool? isOpen}) {
    return Church(
      id: id,
      name: name,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      governorate: governorate,
      diocese: diocese,
      address: address,
      phone: phone,
      isOpen: isOpen ?? this.isOpen,
      nextLiturgy: nextLiturgy,
      description: description,
      liturgies: liturgies,
      meetings: meetings,
      services: services,
      gallery: gallery,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'governorate': governorate,
      'diocese': diocese,
      'address': address,
      'phone': phone,
      'isOpen': isOpen,
      'nextLiturgy': nextLiturgy,
      'description': description,
      'liturgies': liturgies
          .map((l) => {'type': l.type.name, 'day': l.day, 'time': l.time})
          .toList(),
      'meetings': meetings
          .map(
            (m) => {
              'category': m.category.name,
              'title': m.title,
              'day': m.day,
              'time': m.time,
              'location': m.location,
            },
          )
          .toList(),
      'services': services.map((s) => s.name).toList(),
      'gallery': gallery,
    };
  }

  factory Church.fromMap(String id, Map<String, dynamic> data) {
    return Church(
      id: id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      governorate: data['governorate'] as String? ?? '',
      diocese: data['diocese'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      isOpen: data['isOpen'] as bool? ?? true,
      nextLiturgy: data['nextLiturgy'] as String? ?? 'غير محدد',
      description: data['description'] as String? ?? 'لا يوجد وصف إضافي.',
      liturgies: (data['liturgies'] as List<dynamic>? ?? []).map((item) {
        final map = item as Map<String, dynamic>;
        return LiturgySchedule(
          type: LiturgyType.values.firstWhere(
            (type) => type.name == map['type'],
            orElse: () => LiturgyType.liturgy,
          ),
          day: map['day'] as String? ?? '',
          time: map['time'] as String? ?? '',
        );
      }).toList(),
      meetings: (data['meetings'] as List<dynamic>? ?? []).map((item) {
        final map = item as Map<String, dynamic>;
        return MeetingSchedule(
          category: AgeCategory.values.firstWhere(
            (category) => category.name == map['category'],
            orElse: () => AgeCategory.youth,
          ),
          title: map['title'] as String? ?? '',
          day: map['day'] as String? ?? '',
          time: map['time'] as String? ?? '',
          location: map['location'] as String? ?? '',
        );
      }).toList(),
      services: (data['services'] as List<dynamic>? ?? [])
          .map(
            (service) => ChurchService.values.firstWhere(
              (value) => value.name == service,
              orElse: () => ChurchService.choir,
            ),
          )
          .toList(),
      gallery: (data['gallery'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
    );
  }
}
