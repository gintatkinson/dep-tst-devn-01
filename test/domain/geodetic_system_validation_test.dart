import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/geodetic_system.dart';
import 'package:app_flutter/domain/geodetic_system_validation.dart';

void main() {
  group('validateGeodeticSystem — BDD scenarios from feat-02', () {
    test('Scenario 1: default geodetic-datum for Earth', () {
      const system = GeodeticSystem();
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.geodeticDatum, 'wgs-84');
    });

    test('Scenario 2: custom geodetic-datum', () {
      const system = GeodeticSystem(geodeticDatum: 'me');
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.geodeticDatum, 'me');
    });

    test('Scenario 3: invalid pattern (control chars)', () {
      const system = GeodeticSystem(geodeticDatum: 'bad\x00');
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('pattern'));
    });

    test('Scenario 4: space-to-dash normalization', () {
      const system = GeodeticSystem(geodeticDatum: 'wgs 84');
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.geodeticDatum, 'wgs-84');
    });

    test('Scenario 5: coord-accuracy accepted', () {
      const system = GeodeticSystem(coordAccuracy: 0.000010);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.coordAccuracy, 0.000010);
    });

    test('Scenario 6: height-accuracy + Cartesian rejected', () {
      const system = GeodeticSystem(heightAccuracy: 0.5);
      final result = validateGeodeticSystem(system, isCartesian: true);
      expect(result.isValid, isFalse);
      expect(result.error, contains('height-accuracy'));
    });

    test('Scenario 7: height-accuracy + ellipsoidal accepted', () {
      const system = GeodeticSystem(heightAccuracy: 0.5);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.heightAccuracy, 0.5);
    });

    test('Scenario 8: negative coordAccuracy rejected', () {
      const system = GeodeticSystem(coordAccuracy: -1.0);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('non-negative'));
    });

    test('Scenario 9: negative heightAccuracy rejected', () {
      const system = GeodeticSystem(heightAccuracy: -0.5);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('non-negative'));
    });

    test('Scenario 10: whitespace-only datum normalizes to wgs-84', () {
      const system = GeodeticSystem(geodeticDatum: '   ');
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.geodeticDatum, 'wgs-84');
    });

    test('Scenario 11: datum exceeding 32 characters is rejected', () {
      final system = GeodeticSystem(geodeticDatum: 'a' * 33);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('32 characters'));
    });

    test('Scenario 12: coord-accuracy with 7 fractional digits rejected', () {
      const system = GeodeticSystem(coordAccuracy: 0.0000001);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('fractional digits'));
    });

    test('Scenario 13: coord-accuracy with 6 fractional digits accepted', () {
      const system = GeodeticSystem(coordAccuracy: 0.000001);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.coordAccuracy, 0.000001);
    });

    test('Scenario 14: height-accuracy with 7 fractional digits rejected', () {
      const system = GeodeticSystem(heightAccuracy: 0.0000001);
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('fractional digits'));
    });

    test('Scenario 15: empty string datum normalizes to wgs-84', () {
      const system = GeodeticSystem(geodeticDatum: '');
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.geodeticDatum, 'wgs-84');
    });

    test('Scenario 16: fromJson with spaces normalizes to dashes', () {
      final system = GeodeticSystem.fromJson({'geodetic-datum': 'wgs 84'});
      final result = validateGeodeticSystem(system, isCartesian: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedSystem.geodeticDatum, 'wgs-84');
    });
  });
}
