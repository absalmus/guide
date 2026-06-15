import 'package:flutter/foundation.dart';
import 'package:stitch_smart_church_guide/core/constants/enums.dart';
import 'package:stitch_smart_church_guide/models/booking.dart';
import 'package:stitch_smart_church_guide/services/firestore_service.dart';
import 'package:stitch_smart_church_guide/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  final FirestoreService _firestore;
  final _uuid = const Uuid();
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  Future<Booking> createBooking({
    required String userId,
    required String title,
    required BookingType type,
    required String churchName,
    required DateTime date,
    required String location,
    String? adminEmail,
    String? notes,
  }) async {
    final bookingId = _uuid.v4();
    final booking = Booking(
      id: bookingId,
      userId: userId,
      title: title,
      type: type,
      churchName: churchName,
      date: date,
      location: location,
      qrCode: 'REMINDER-${bookingId.substring(0, 8).toUpperCase()}',
      createdAt: DateTime.now(),
      adminEmail: adminEmail,
      notes: notes,
    );

    final reminderTime = booking.date.subtract(const Duration(hours: 1));
    final now = DateTime.now();
    final scheduled = reminderTime.isAfter(now)
        ? reminderTime
        : now.add(const Duration(seconds: 5));

    if (booking.date.isAfter(now)) {
      await NotificationService.instance.scheduleReminder(
        id: booking.id.hashCode.abs(),
        title: 'تذكير قبل ${booking.title}',
        body: 'ستبدأ ${booking.title} في ${booking.churchName} بعد ساعة.',
        scheduledDate: scheduled,
      );
    }

    _bookings.insert(0, booking);
    notifyListeners();

    try {
      await _firestore.saveBooking(booking);
    } catch (_) {
      // Demo/offline mode
    }

    return booking;
  }

  Future<void> loadUserBookings(String userId) async {
    if (_bookings.isNotEmpty) return;
    try {
      final list = await _firestore.getUserBookings(userId);
      _bookings.addAll(list);
      notifyListeners();
    } catch (_) {
      // keep empty if Firestore not available
    }
  }
}
