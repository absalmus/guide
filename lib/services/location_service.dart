import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stitch_smart_church_guide/core/utils/distance_utils.dart';
import 'package:stitch_smart_church_guide/models/church.dart';
import 'package:stitch_smart_church_guide/models/monastery.dart';
import 'package:stitch_smart_church_guide/services/firestore_service.dart';

class LocationService extends ChangeNotifier {
  LocationService({FirestoreService? firestoreService})
    : _firestore = firestoreService ?? FirestoreService();

  final FirestoreService _firestore;
  final List<Church> _churches = [];
  final List<Monastery> _monasteries = [];
  Position? _position;
  bool _loading = false;
  String? _error;

  List<Church> get churches => List.unmodifiable(_churches);
  Position? get position => _position;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasLocation => _position != null;

  static const defaultLat = 30.0444;
  static const defaultLng = 31.2357;

  double get latitude => _position?.latitude ?? defaultLat;
  double get longitude => _position?.longitude ?? defaultLng;

  Future<void> init() async {
    await _loadChurches();
    await _loadMonasteries();
  }

  Future<void> _loadChurches() async {
    try {
      final churches = await _firestore.getChurches();
      _churches
        ..clear()
        ..addAll(churches);
      notifyListeners();
    } catch (_) {
      // If Firestore is not configured yet, keep an empty church list.
    }
  }

  Future<void> _loadMonasteries() async {
    try {
      final monasteries = await _firestore.getMonasteries();
      _monasteries
        ..clear()
        ..addAll(monasteries);
      notifyListeners();
    } catch (_) {
      // keep demo or empty list if Firestore not available
    }
  }

  Future<void> getCurrentLocation() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error = 'تم رفض إذن الموقع';
        _loading = false;
        notifyListeners();
        return;
      }

      _position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (e) {
      _error = 'تعذر الحصول على الموقع';
    }

    _loading = false;
    notifyListeners();
  }

  List<Church> churchesWithDistance({String? governorate, String? diocese}) {
    var churches = _churches;
    if (governorate != null && governorate.isNotEmpty) {
      churches = churches.where((c) => c.governorate == governorate).toList();
    }
    if (diocese != null && diocese.isNotEmpty) {
      churches = churches.where((c) => c.diocese == diocese).toList();
    }

    final withDistance = churches.map((church) {
      final km = DistanceUtils.haversineKm(
        latitude,
        longitude,
        church.latitude,
        church.longitude,
      );
      return church.copyWith(distanceKm: km);
    }).toList();

    withDistance.sort(
      (a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0),
    );
    return withDistance;
  }

  List<Monastery> monasteriesWithDistance({String? governorate}) {
    var monasteries = _monasteries;
    if (governorate != null && governorate.isNotEmpty) {
      monasteries = monasteries
          .where((m) => m.governorate == governorate)
          .toList();
    }

    return monasteries.map((m) {
        final km = DistanceUtils.haversineKm(
          latitude,
          longitude,
          m.latitude,
          m.longitude,
        );
        return m.copyWith(distanceKm: km);
      }).toList()
      ..sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
  }

  List<String> get availableGovernorates {
    final set = <String>{};
    for (final c in _churches) set.add(c.governorate);
    for (final m in _monasteries) set.add(m.governorate);
    return set.toList()..sort();
  }

  List<String> get availableDioceses {
    final set = <String>{};
    for (final c in _churches) set.add(c.diocese);
    return set.toList()..sort();
  }

  Future<void> saveChurch(Church church) async {
    await _firestore.saveChurch(church);
    final index = _churches.indexWhere((c) => c.id == church.id);
    if (index >= 0) {
      _churches[index] = church;
    } else {
      _churches.insert(0, church);
    }
    notifyListeners();
  }

  Future<void> deleteChurch(String churchId) async {
    await _firestore.deleteChurch(churchId);
    _churches.removeWhere((c) => c.id == churchId);
    notifyListeners();
  }

  Church? findChurchById(String id) {
    return _churches.cast<Church?>().firstWhere(
      (c) => c!.id == id,
      orElse: () => null,
    );
  }
}
