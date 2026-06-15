import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_smart_church_guide/core/utils/distance_utils.dart';

void main() {
  test('DistanceUtils formats kilometers', () {
    expect(DistanceUtils.formatDistance(0.5), '500 م');
    expect(DistanceUtils.formatDistance(2.3), '2.3 كم');
  });

  test('DistanceUtils haversine calculation', () {
    final distance = DistanceUtils.haversineKm(30.0444, 31.2357, 30.0626, 31.2197);
    expect(distance, greaterThan(0));
    expect(distance, lessThan(10));
  });
}
