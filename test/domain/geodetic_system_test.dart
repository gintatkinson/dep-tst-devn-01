import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/geodetic_system.dart';

void main() {
  group('GeodeticSystem', () {
    test('default constructor uses wgs-84', () {
      const system = GeodeticSystem();
      expect(system.geodeticDatum, 'wgs-84');
      expect(system.coordAccuracy, isNull);
      expect(system.heightAccuracy, isNull);
    });

    test('fromJson with spaces normalizes to dashes', () {
      final system = GeodeticSystem.fromJson({'geodetic-datum': 'wgs 84'});
      expect(system.geodeticDatum, 'wgs-84');
    });

    test('fromJson with null values uses defaults', () {
      final system = GeodeticSystem.fromJson({});
      expect(system.geodeticDatum, 'wgs-84');
      expect(system.coordAccuracy, isNull);
      expect(system.heightAccuracy, isNull);
    });

    test('fromJson with null geodetic-datum uses default', () {
      final system = GeodeticSystem.fromJson({'geodetic-datum': null});
      expect(system.geodeticDatum, 'wgs-84');
    });

    test('toJson omits null coord-accuracy', () {
      const system = GeodeticSystem();
      final json = system.toJson();
      expect(json.containsKey('coord-accuracy'), isFalse);
    });

    test('toJson omits null height-accuracy', () {
      const system = GeodeticSystem();
      final json = system.toJson();
      expect(json.containsKey('height-accuracy'), isFalse);
    });

    test('toJson includes all fields when present', () {
      const system = GeodeticSystem(
        geodeticDatum: 'itrf-2020',
        coordAccuracy: 0.5,
        heightAccuracy: 0.25,
      );
      final json = system.toJson();
      expect(json['geodetic-datum'], 'itrf-2020');
      expect(json['coord-accuracy'], 0.5);
      expect(json['height-accuracy'], 0.25);
    });

    test('round-trip fromJson to toJson preserves all fields', () {
      final original = {
        'geodetic-datum': 'nad-83',
        'coord-accuracy': 0.001,
        'height-accuracy': 0.01,
      };
      final system = GeodeticSystem.fromJson(original);
      final output = system.toJson();
      expect(output['geodetic-datum'], 'nad-83');
      expect(output['coord-accuracy'], 0.001);
      expect(output['height-accuracy'], 0.01);
    });

    test('equality', () {
      const a = GeodeticSystem(geodeticDatum: 'wgs-84');
      const b = GeodeticSystem(geodeticDatum: 'wgs-84');
      expect(a, equals(b));
    });

    test('inequality', () {
      const a = GeodeticSystem(geodeticDatum: 'wgs-84');
      const b = GeodeticSystem(geodeticDatum: 'itrf-2020');
      expect(a, isNot(equals(b)));
    });
  });
}
