import 'package:stitch_smart_church_guide/core/constants/enums.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.governorate,
    this.churchId,
    this.category = AgeCategory.youth,
    this.favoriteChurchIds = const [],
    this.phone,
    this.profileComplete = false,
  });

  final String id;
  final String name;
  final String email;
  final int? age;
  final String? governorate;
  final String? churchId;
  final AgeCategory category;
  final List<String> favoriteChurchIds;
  final String? phone;
  final bool profileComplete;

  UserProfile copyWith({
    String? name,
    int? age,
    String? governorate,
    String? churchId,
    AgeCategory? category,
    List<String>? favoriteChurchIds,
    bool? profileComplete,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      age: age ?? this.age,
      governorate: governorate ?? this.governorate,
      churchId: churchId ?? this.churchId,
      category: category ?? this.category,
      favoriteChurchIds: favoriteChurchIds ?? this.favoriteChurchIds,
      phone: phone,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'age': age,
        'governorate': governorate,
        'churchId': churchId,
        'category': category.name,
        'favoriteChurchIds': favoriteChurchIds,
        'phone': phone,
        'profileComplete': profileComplete,
      };

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: map['age'] as int?,
      governorate: map['governorate'] as String?,
      churchId: map['churchId'] as String?,
      category: AgeCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => AgeCategory.youth,
      ),
      favoriteChurchIds:
          List<String>.from(map['favoriteChurchIds'] as List? ?? []),
      phone: map['phone'] as String?,
      profileComplete: map['profileComplete'] as bool? ?? false,
    );
  }
}
