import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';

void main() {
  group('EllipsoidalCoordinates', () {
    test('default constructor sets all fields to null', () {
      const coords = EllipsoidalCoordinates();
      expect(coords.latitude, isNull);
      expect(coords.longitude, isNull);
      expect(coords.height, isNull);
    });

    test('named constructor with lat/lon', () {
      const coords = EllipsoidalCoordinates(latitude: 40.73297, longitude: -74.007696);
      expect(coords.latitude, 40.73297);
      expect(coords.longitude, -74.007696);
      expect(coords.height, isNull);
    });

    test('constructor with all fields', () {
      const coords = EllipsoidalCoordinates(
        latitude: 40.73297,
        longitude: -74.007696,
        height: 35.0,
      );
      expect(coords.latitude, 40.73297);
      expect(coords.longitude, -74.007696);
      expect(coords.height, 35.0);
    });

    test('fromJson round-trip', () {
      final json = {
        'latitude': 40.73297,
        'longitude': -74.007696,
        'height': 35.0,
      };
      final coords = EllipsoidalCoordinates.fromJson(json);
      expect(coords.latitude, 40.73297);
      expect(coords.longitude, -74.007696);
      expect(coords.height, 35.0);
      final output = coords.toJson();
      expect(output['latitude'], 40.73297);
      expect(output['longitude'], -74.007696);
      expect(output['height'], 35.0);
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
