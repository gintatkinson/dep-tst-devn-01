import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/persistence/ellipsoidal_coordinates_adapter.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';

import '../shared/coordinate_fixtures.dart';
import '../shared/node_id_fixtures.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteEllipsoidalCoordinatesAdapter', () {
    late SqliteEllipsoidalCoordinatesAdapter adapter;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      adapter = SqliteEllipsoidalCoordinatesAdapter(db);
      await adapter.init();
    });

    test('saves and reads back all fields', () async {
      const coords = EllipsoidalCoordinates(
        latitude: kTestLatitude,
        longitude: kTestLongitude,
        height: kTestHeight,
      );
      await adapter.saveEllipsoidalCoordinates(kNodeId1, coords);
      final loaded = await adapter.fetchEllipsoidalCoordinates(kNodeId1);
      expect(loaded, equals(coords));
    });

    test('saves and reads back without height', () async {
      const coords = EllipsoidalCoordinates(latitude: 40.0, longitude: -74.0);
      await adapter.saveEllipsoidalCoordinates(kNodeId2, coords);
      final loaded = await adapter.fetchEllipsoidalCoordinates(kNodeId2);
      expect(loaded, equals(coords));
    });

    test('returns null for non-existent node', () async {
      final loaded = await adapter.fetchEllipsoidalCoordinates(kNodeIdNoSuch);
      expect(loaded, isNull);
    });

    test('overwrite returns latest value', () async {
      const first = EllipsoidalCoordinates(latitude: 1.0, longitude: 2.0);
      const second = EllipsoidalCoordinates(latitude: 3.0, longitude: 4.0);
      await adapter.saveEllipsoidalCoordinates(kNodeId3, first);
      await adapter.saveEllipsoidalCoordinates(kNodeId3, second);
      final loaded = await adapter.fetchEllipsoidalCoordinates(kNodeId3);
      expect(loaded, equals(second));
    });

    test('partial update preserves fields', () async {
      const original = EllipsoidalCoordinates(
        latitude: 10.0, longitude: 20.0, height: 30.0,
      );
      await adapter.saveEllipsoidalCoordinates(kNodeId4, original);
      const partial = EllipsoidalCoordinates(latitude: 99.0);
      await adapter.saveEllipsoidalCoordinates(kNodeId4, partial);
      final loaded = await adapter.fetchEllipsoidalCoordinates(kNodeId4);
      expect(loaded, equals(partial));
    });
  });
}
