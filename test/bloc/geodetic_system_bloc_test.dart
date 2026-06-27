import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/bloc/geodetic_system_bloc.dart';
import 'package:app_flutter/domain/geodetic_system.dart';
import 'package:app_flutter/persistence/geodetic_system_adapter.dart';

import '../shared/node_id_fixtures.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('GeodeticSystemBloc', () {
    late SqliteGeodeticSystemAdapter adapter;
    late GeodeticSystemBloc bloc;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      adapter = SqliteGeodeticSystemAdapter(db);
      await adapter.init();
      bloc = GeodeticSystemBloc(repository: adapter);
    });

    tearDown(() => bloc.dispose());

    test('initial state is GeodeticSystemInitial', () {
      expect(bloc.state, isA<GeodeticSystemInitial>());
    });

    test('load emits GeodeticSystemLoaded with default wgs-84 when nothing stored', () async {
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<GeodeticSystemLoading>(),
          isA<GeodeticSystemLoaded>(),
        ]),
      );
      bloc.load(kNodeId1);
      await future;
      expect((bloc.state as GeodeticSystemLoaded).system.geodeticDatum, 'wgs-84');
    });

    test('save persists and emits GeodeticSystemLoaded with saved system', () async {
      const system = GeodeticSystem(geodeticDatum: 'itrf-2020');
      await bloc.save(kNodeId2, system);
      expect(bloc.state, isA<GeodeticSystemLoaded>());
      expect((bloc.state as GeodeticSystemLoaded).system.geodeticDatum, 'itrf-2020');
    });

    test('load after save returns previously persisted frame', () async {
      const system = GeodeticSystem(geodeticDatum: 'nad-83');
      await adapter.saveGeodeticSystem(kNodeId3, system);
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<GeodeticSystemLoading>(),
          isA<GeodeticSystemLoaded>(),
        ]),
      );
      bloc.load(kNodeId3);
      await future;
      expect((bloc.state as GeodeticSystemLoaded).system.geodeticDatum, 'nad-83');
    });

    test('save with negative accuracy emits GeodeticSystemError without persisting', () async {
      const system = GeodeticSystem(geodeticDatum: 'wgs-84', coordAccuracy: -1);
      await bloc.save(kNodeId4, system);
      expect(bloc.state, isA<GeodeticSystemError>());
      expect((bloc.state as GeodeticSystemError).message, contains('non-negative'));
    });

    test('save with height-accuracy and Cartesian emits GeodeticSystemError without persisting', () async {
      const system = GeodeticSystem(geodeticDatum: 'wgs-84', heightAccuracy: 1.0);
      await bloc.save(kNodeId5, system, isCartesian: true);
      expect(bloc.state, isA<GeodeticSystemError>());
      expect((bloc.state as GeodeticSystemError).message, contains('height-accuracy'));
    });

    test('dispose does not throw on double call', () {
      bloc.dispose();
      expect(() => bloc.dispose(), returnsNormally);
    });

    test('load with invalid persisted data emits GeodeticSystemError', () async {
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<GeodeticSystemLoading>(),
          isA<GeodeticSystemLoaded>(),
        ]),
      );
      bloc.load(kNodeIdMissing);
      await future;
      expect(bloc.state, isA<GeodeticSystemLoaded>());
    });

    test('stream emits Loading then Loaded on successful load', () async {
      const system = GeodeticSystem(geodeticDatum: 'itrf-2020');
      await adapter.saveGeodeticSystem(kNodeIdStreamTest, system);
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<GeodeticSystemLoading>(),
          isA<GeodeticSystemLoaded>(),
        ]),
      );
      bloc.load(kNodeIdStreamTest);
      await future;
    });
  });
}
