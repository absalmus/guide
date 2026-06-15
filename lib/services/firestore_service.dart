import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stitch_smart_church_guide/models/booking.dart';
import 'package:stitch_smart_church_guide/models/church.dart';
import 'package:stitch_smart_church_guide/models/monastery.dart';
import 'package:stitch_smart_church_guide/models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.id).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(id, doc.data()!);
  }

  Future<void> saveBooking(Booking booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final snapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => Booking.fromMap(d.id, d.data())).toList();
  }

  Future<void> toggleFavoriteChurch(String userId, String churchId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return;
    final favorites = List<String>.from(
      doc.data()?['favoriteChurchIds'] as List? ?? [],
    );
    if (favorites.contains(churchId)) {
      favorites.remove(churchId);
    } else {
      favorites.add(churchId);
    }
    await _db.collection('users').doc(userId).update({
      'favoriteChurchIds': favorites,
    });
  }

  Future<void> saveChurch(Church church) async {
    await _db.collection('churches').doc(church.id).set(church.toMap());
  }

  Future<void> deleteChurch(String churchId) async {
    await _db.collection('churches').doc(churchId).delete();
  }

  Future<List<Church>> getChurches() async {
    final snapshot = await _db.collection('churches').get();
    return snapshot.docs
        .map((doc) => Church.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Monastery>> getMonasteries() async {
    final snapshot = await _db.collection('monasteries').get();
    return snapshot.docs
        .map((doc) => Monastery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<String?> saveDeviceToken(
    String token, {
    String? userId,
    String? platform,
  }) async {
    try {
      final doc = await _db.collection('device_tokens').add({
        'token': token,
        'userId': userId,
        'platform': platform ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (_) {
      return null;
    }
  }

  Future<void> associateTokenWithUser(String token, String userId) async {
    final snapshot = await _db
        .collection('device_tokens')
        .where('token', isEqualTo: token)
        .get();
    for (final doc in snapshot.docs) {
      await _db.collection('device_tokens').doc(doc.id).update({
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
