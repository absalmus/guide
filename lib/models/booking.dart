import 'package:stitch_smart_church_guide/core/constants/enums.dart';

class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.churchName,
    required this.date,
    required this.location,
    required this.qrCode,
    required this.createdAt,
    this.adminEmail,
    this.notes,
  });

  final String id;
  final String userId;
  final String title;
  final BookingType type;
  final String churchName;
  final DateTime date;
  final String location;
  final String qrCode;
  final DateTime createdAt;
  final String? adminEmail;
  final String? notes;

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'type': type.name,
    'churchName': churchName,
    'date': date.toIso8601String(),
    'location': location,
    'qrCode': qrCode,
    'createdAt': createdAt.toIso8601String(),
    'adminEmail': adminEmail,
    'notes': notes,
  };

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      type: BookingType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => BookingType.conference,
      ),
      churchName: map['churchName'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String,
      qrCode: map['qrCode'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      adminEmail: map['adminEmail'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
