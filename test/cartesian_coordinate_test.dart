import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/types.dart';
import 'package:app_flutter/domain/validation.dart';
import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/components/property_grid.dart';

import 'shared/coordinate_fixtures.dart';

void main() {
  group('CartesianCoordinate', () {
    test('stores x, y, z as doubles with correct values', () {
      final coord = CartesianCoordinate(x: kTestCartesianX, y: kTestCartesianY, z: kTestCartesianZ);
      expect(coord.x, kTestCartesianX);
      expect(coord.y, kTestCartesianY);
      expect(coord.z, kTestCartesianZ);
    });

    test('toJson / fromJson round-trip preserves values', () {
      final coord = CartesianCoordinate(x: kTestCartesianX, y: kTestCartesianY, z: kTestCartesianZ);
      final json = coord.toJson();
      final restored = CartesianCoordinate.fromJson(json);
      expect(restored.x, coord.x);
      expect(restored.y, coord.y);
      expect(restored.z, coord.z);
    });

    test('truncates to 6 decimal digits on construction', () {
      final coord = CartesianCoordinate(x: 1.1234567, y: 2.9876543, z: 3.5555555);
      // Should truncate/round to 6 decimal places
      final xStr = coord.x!.toStringAsFixed(6);
      expect(xStr.split('.')[1].length, 6);
    });

    test('allows partial coordinates (only x and y without z)', () {
      final coord = CartesianCoordinate(x: 100.0, y: 200.0);
      expect(coord.x, 100.0);
      expect(coord.y, 200.0);
      expect(coord.z, isNull);
    });
  });

  group('validateCartesianCoordinate', () {
    test('returns true for valid Cartesian coordinates', () {
      final coord = CartesianCoordinate(x: kTestCartesianX, y: kTestCartesianY, z: kTestCartesianZ);
      expect(validateCartesianCoordinate(coord), isTrue);
    });

    test('returns true for partial Cartesian (only x)', () {
      final coord = CartesianCoordinate(x: 100.0);
      expect(validateCartesianCoordinate(coord), isTrue);
    });

    test('returns true when all values are null (empty Cartesian)', () {
      final coord = CartesianCoordinate();
      expect(validateCartesianCoordinate(coord), isTrue);
    });
  });

  group('validateLocationChoice', () {
    test('returns true when neither Cartesian nor ellipsoidal values present', () {
      expect(validateLocationChoice(null, null), isTrue);
    });

    test('returns true when only Cartesian values present', () {
      final cart = CartesianCoordinate(x: 100.0, y: 200.0, z: 300.0);
      expect(validateLocationChoice(cart, null), isTrue);
    });

    test('returns false when both Cartesian and ellipsoidal values present', () {
      final cart = CartesianCoordinate(x: 100.0, y: 200.0);
      final ellipsoidal = {'latitude': 40.0, 'longitude': -74.0};
      expect(validateLocationChoice(cart, ellipsoidal), isFalse);
    });

    test('returns false when both Cartesian x and latitude provided', () {
      final cart = CartesianCoordinate(x: 100.0);
      final ellipsoidal = {'latitude': 40.0};
      expect(validateLocationChoice(cart, ellipsoidal), isFalse);
    });
  });

  group('defaultCartesianAttributes', () {
    test('contains 3 attribute definitions for x, y, z', () {
      expect(defaultCartesianAttributes.length, 3);
      expect(defaultCartesianAttributes[0].key, 'x');
      expect(defaultCartesianAttributes[1].key, 'y');
      expect(defaultCartesianAttributes[2].key, 'z');
    });

    test('all are double type with sectionGroup Cartesian', () {
      for (final attr in defaultCartesianAttributes) {
        expect(attr.type, 'double');
        expect(attr.sectionGroup, 'Cartesian');
      }
    });

    test('has appropriate labels with units', () {
      expect(defaultCartesianAttributes[0].label, 'X (m)');
      expect(defaultCartesianAttributes[1].label, 'Y (m)');
      expect(defaultCartesianAttributes[2].label, 'Z (m)');
    });
  });

  group('validateHeightAccuracyWithCartesian', () {
    test('returns true when heightAccuracy is null', () {
      expect(validateHeightAccuracyWithCartesian(null), isTrue);
    });

    test('returns false when heightAccuracy is provided with Cartesian active', () {
      expect(validateHeightAccuracyWithCartesian(0.5), isFalse);
    });
  });

  group('PropertyGrid Cartesian integration', () {
    testWidgets('renders Cartesian fields when attributes include Cartesian section', (tester) async {
      final attrs = [
        ...defaultGeodeticAttributes,
        ...defaultEllipsoidalAttributes,
        ...defaultCartesianAttributes,
        ...defaultCoordinateAttributes,
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyGrid(activeView: 'Cartesian', attributes: attrs),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Latitude'), findsOneWidget);
      expect(find.text('Longitude'), findsOneWidget);
      expect(find.text('X (m)'), findsOneWidget);
      expect(find.text('Y (m)'), findsOneWidget);
      expect(find.text('Z (m)'), findsOneWidget);
    });

    testWidgets('default PropertyGrid (no custom attrs) shows Cartesian section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PropertyGrid(activeView: 'Cartesian'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('X (m)'), findsOneWidget);
      expect(find.text('Y (m)'), findsOneWidget);
      expect(find.text('Z (m)'), findsOneWidget);
      expect(find.text('Cartesian Coordinates'), findsOneWidget);
    });
  });

  group('Cartesian seed data', () {
    test('CartesianCoordinate fromJson creates correct values from seed map', () {
      final cartesianSeed = {
        'x': kTestCartesianX,
        'y': kTestCartesianY,
        'z': kTestCartesianZ,
      };
      final coord = CartesianCoordinate.fromJson(cartesianSeed);
      expect(coord.x, kTestCartesianX);
      expect(coord.y, kTestCartesianY);
      expect(coord.z, kTestCartesianZ);
    });
  });
}
