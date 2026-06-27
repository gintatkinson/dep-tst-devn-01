import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/geodetic_system.dart';

void main() {
  group('GeodeticSystem', () {
    test('default geodeticDatum is "wgs-84" when no args given', () {
      const system = GeodeticSystem();
      expect(system.geodeticDatum, 'wgs-84');
      expect(system.coordAccuracy, isNull);
      expect(system.heightAccuracy, isNull);
    });

    test('custom geodeticDatum is stored and returned', () {
      const system = GeodeticSystem(geodeticDatum: 'me');
      expect(system.geodeticDatum, 'me');
    });

    test('coordAccuracy and heightAccuracy stored as doubles', () {
      const system = GeodeticSystem(coordAccuracy: 1.5, heightAccuracy: 2.5);
      expect(system.coordAccuracy, 1.5);
      expect(system.heightAccuracy, 2.5);
    });

    test('JSON round-trip preserves all values', () {
      const system = GeodeticSystem(
        geodeticDatum: 'nad-83',
        coordAccuracy: 0.5,
        heightAccuracy: 1.0,
      );
      final json = system.toJson();
      final restored = GeodeticSystem.fromJson(json);
      expect(restored, equals(system));
    });

    test('optional fields are null when not provided in JSON', () {
      final json = <String, dynamic>{'geodetic-datum': 'wgs-84'};
      final restored = GeodeticSystem.fromJson(json);
      expect(restored.geodeticDatum, 'wgs-84');
      expect(restored.coordAccuracy, isNull);
      expect(restored.heightAccuracy, isNull);
    });

    test('equality: same values are equal', () {
      const a = GeodeticSystem(geodeticDatum: 'wgs-84');
      const b = GeodeticSystem(geodeticDatum: 'wgs-84');
      expect(a, equals(b));
    });

    test('equality: different values are not equal', () {
      const a = GeodeticSystem(geodeticDatum: 'wgs-84');
      const b = GeodeticSystem(geodeticDatum: 'nad-83');
      expect(a, isNot(equals(b)));
    });
  });
}
