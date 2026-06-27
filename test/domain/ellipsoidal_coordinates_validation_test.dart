import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates_validation.dart';

import '../shared/coordinate_fixtures.dart';

void main() {
  group('validateEllipsoidalCoordinates', () {
    test('valid lat/lon accepted', () {
      const coords = EllipsoidalCoordinates(latitude: kTestLatitude, longitude: kTestLongitude);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });

    test('valid lat/lon/height accepted', () {
      const coords = EllipsoidalCoordinates(latitude: kTestLatitude, longitude: kTestLongitude, height: kTestHeight);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isTrue);
    });

    test('latitude with >16 fraction digits rejected', () {
      const coords = EllipsoidalCoordinates(latitude: 0.123456789012345678, longitude: 0.0);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isFalse);
      expect(result.error, contains('latitude'));
    });

    test('longitude with >16 fraction digits rejected', () {
      const coords = EllipsoidalCoordinates(latitude: 0.0, longitude: 0.123456789012345678);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isFalse);
      expect(result.error, contains('longitude'));
    });

    test('height with >6 fraction digits rejected', () {
      const coords = EllipsoidalCoordinates(latitude: 0.0, longitude: 0.0, height: 0.1234567);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isFalse);
      expect(result.error, contains('height'));
    });

    test('height with exactly 6 fraction digits accepted', () {
      const coords = EllipsoidalCoordinates(latitude: 0.0, longitude: 0.0, height: 0.123456);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isTrue);
    });

    test('latitude with exactly 16 fraction digits accepted', () {
      const coords = EllipsoidalCoordinates(latitude: 1.2345678901234567, longitude: 0.0);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isTrue);
    });

    test('null height accepted', () {
      const coords = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isTrue);
    });

    test('all null coordinates accepted (no location set)', () {
      const coords = EllipsoidalCoordinates();
      final result = validateEllipsoidalCoordinates(coords);
      expect(result.isValid, isTrue);
    });
  });
}
