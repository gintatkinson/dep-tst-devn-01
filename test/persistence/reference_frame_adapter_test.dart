import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/persistence/reference_frame_adapter.dart';
import 'package:app_flutter/domain/reference_frame.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteReferenceFrameAdapter', () {
    late SqliteReferenceFrameAdapter adapter;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      adapter = SqliteReferenceFrameAdapter(db);
      await adapter.init();
    });

    test('saves and reads back a ReferenceFrame', () async {
      const frame = ReferenceFrame(astronomicalBody: 'moon');
      await adapter.saveReferenceFrame('node-1', frame);
      final loaded = await adapter.fetchReferenceFrame('node-1');
      expect(loaded, equals(frame));
    });

    test('saves and reads back a ReferenceFrame with alternate system', () async {
      const frame = ReferenceFrame(astronomicalBody: 'mars', alternateSystem: 'sim-env-1');
      await adapter.saveReferenceFrame('node-2', frame);
      final loaded = await adapter.fetchReferenceFrame('node-2');
      expect(loaded, equals(frame));
    });

    test('returns null for non-existent node', () async {
      final loaded = await adapter.fetchReferenceFrame('no-such-node');
      expect(loaded, isNull);
    });

    test('overwrite: saving twice returns latest value', () async {
      const first = ReferenceFrame(astronomicalBody: 'earth');
      const second = ReferenceFrame(astronomicalBody: 'venus');
      await adapter.saveReferenceFrame('node-3', first);
      await adapter.saveReferenceFrame('node-3', second);
      final loaded = await adapter.fetchReferenceFrame('node-3');
      expect(loaded, equals(second));
    });
  });
}
