import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/bloc/ellipsoidal_coordinates_bloc.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';
import 'package:app_flutter/persistence/ellipsoidal_coordinates_adapter.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EllipsoidalCoordinatesBloc', () {
    late SqliteEllipsoidalCoordinatesAdapter adapter;
    late EllipsoidalCoordinatesBloc bloc;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      adapter = SqliteEllipsoidalCoordinatesAdapter(db);
      await adapter.init();
      bloc = EllipsoidalCoordinatesBloc(repository: adapter);
    });

    tearDown(() => bloc.dispose());

    test('initial state is EllipsoidalCoordinatesInitial', () {
      expect(bloc.state, isA<EllipsoidalCoordinatesInitial>());
    });

    test('load emits Loading then Loaded', () async {
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EllipsoidalCoordinatesLoading>(),
          isA<EllipsoidalCoordinatesLoaded>(),
        ]),
      );
      bloc.load('node-1');
      await future;
      expect((bloc.state as EllipsoidalCoordinatesLoaded).coordinates, isNotNull);
    });

    test('load without stored data emits Loaded with empty coordinates', () async {
      bloc.load('no-such-node');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<EllipsoidalCoordinatesLoaded>());
      final loaded = bloc.state as EllipsoidalCoordinatesLoaded;
      expect(loaded.coordinates.latitude, isNull);
      expect(loaded.coordinates.longitude, isNull);
    });

    test('save persists and emits Loaded', () async {
      const coords = EllipsoidalCoordinates(latitude: 40.73297, longitude: -74.007696);
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EllipsoidalCoordinatesLoading>(),
          isA<EllipsoidalCoordinatesLoaded>(),
        ]),
      );
      await bloc.save('node-2', coords);
      await future;
      expect(
        (bloc.state as EllipsoidalCoordinatesLoaded).coordinates.latitude,
        40.73297,
      );
    });

    test('save with invalid fraction digits emits Error', () async {
      const coords = EllipsoidalCoordinates(
        latitude: 0.0,
        longitude: 0.0,
        height: 0.1234567, // 7 fraction digits
      );
      await bloc.save('node-3', coords);
      expect(bloc.state, isA<EllipsoidalCoordinatesError>());
      expect((bloc.state as EllipsoidalCoordinatesError).message, contains('height'));
    });

    test('load after save returns persisted coordinates', () async {
      const coords = EllipsoidalCoordinates(latitude: 10.0, longitude: 20.0);
      await adapter.saveEllipsoidalCoordinates('node-4', coords);
      bloc.load('node-4');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect((bloc.state as EllipsoidalCoordinatesLoaded).coordinates, equals(coords));
    });

    test('dispose does not throw on double call', () {
      bloc.dispose();
      expect(() => bloc.dispose(), returnsNormally);
    });
  });
}
