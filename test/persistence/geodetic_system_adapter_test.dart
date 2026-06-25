import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/persistence/geodetic_system_adapter.dart';
import 'package:app_flutter/domain/geodetic_system.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteGeodeticSystemAdapter', () {
    late SqliteGeodeticSystemAdapter adapter;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      adapter = SqliteGeodeticSystemAdapter(db);
      await adapter.init();
    });

    test('saves and reads back a GeodeticSystem with defaults only', () async {
      const system = GeodeticSystem();
      await adapter.saveGeodeticSystem('node-1', system);
      final loaded = await adapter.fetchGeodeticSystem('node-1');
      expect(loaded, equals(system));
    });

    test('saves and reads back with all fields', () async {
      const system = GeodeticSystem(
        geodeticDatum: 'nad83',
        coordAccuracy: 0.5,
        heightAccuracy: 0.25,
      );
      await adapter.saveGeodeticSystem('node-2', system);
      final loaded = await adapter.fetchGeodeticSystem('node-2');
      expect(loaded, equals(system));
    });

    test('returns null for non-existent node', () async {
      final loaded = await adapter.fetchGeodeticSystem('no-such-node');
      expect(loaded, isNull);
    });

    test('overwrite: saving twice returns latest value', () async {
      const first = GeodeticSystem(geodeticDatum: 'wgs-84');
      const second = GeodeticSystem(geodeticDatum: 'itrf-2020');
      await adapter.saveGeodeticSystem('node-3', first);
      await adapter.saveGeodeticSystem('node-3', second);
      final loaded = await adapter.fetchGeodeticSystem('node-3');
      expect(loaded, equals(second));
    });
  });
}
