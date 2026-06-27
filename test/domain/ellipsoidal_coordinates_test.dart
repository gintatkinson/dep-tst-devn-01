import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';

import '../shared/coordinate_fixtures.dart';

void main() {
  group('EllipsoidalCoordinates', () {
    test('default constructor sets all fields to null', () {
      const coords = EllipsoidalCoordinates();
      expect(coords.latitude, isNull);
      expect(coords.longitude, isNull);
      expect(coords.height, isNull);
    });

    test('named constructor with lat/lon', () {
      const coords = EllipsoidalCoordinates(latitude: kTestLatitude, longitude: kTestLongitude);
      expect(coords.latitude, kTestLatitude);
      expect(coords.longitude, kTestLongitude);
      expect(coords.height, isNull);
    });

    test('constructor with all fields', () {
      const coords = EllipsoidalCoordinates(
        latitude: kTestLatitude,
        longitude: kTestLongitude,
        height: kTestHeight,
      );
      expect(coords.latitude, kTestLatitude);
      expect(coords.longitude, kTestLongitude);
      expect(coords.height, kTestHeight);
    });

    test('fromJson round-trip', () {
      final json = {
        'latitude': kTestLatitude,
        'longitude': kTestLongitude,
        'height': kTestHeight,
      };
      final coords = EllipsoidalCoordinates.fromJson(json);
      expect(coords.latitude, kTestLatitude);
      expect(coords.longitude, kTestLongitude);
      expect(coords.height, kTestHeight);
      final output = coords.toJson();
      expect(output['latitude'], kTestLatitude);
      expect(output['longitude'], kTestLongitude);
      expect(output['height'], kTestHeight);
    });

    test('fromJson with missing fields uses null', () {
      final coords = EllipsoidalCoordinates.fromJson({});
      expect(coords.latitude, isNull);
      expect(coords.longitude, isNull);
      expect(coords.height, isNull);
    });

    test('toJson omits null height', () {
      const coords = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      final json = coords.toJson();
      expect(json['latitude'], 40.0);
      expect(json['longitude'], -74.0);
      expect(json.containsKey('height'), isFalse);
    });

    test('equality', () {
      const a = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      const b = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      expect(a, equals(b));
    });

    test('inequality', () {
      const a = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      const b = EllipsoidalCoordinates(latitude: 41.0, longitude: -74.0);
      expect(a, isNot(equals(b)));
    });

    test('hashCode consistent with equality', () {
      const a = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      const b = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
