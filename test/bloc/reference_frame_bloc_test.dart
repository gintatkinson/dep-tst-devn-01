import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/bloc/reference_frame_bloc.dart';
import 'package:app_flutter/domain/reference_frame.dart';
import 'package:app_flutter/persistence/reference_frame_adapter.dart';

import '../shared/node_id_fixtures.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ReferenceFrameBloc', () {
    late SqliteReferenceFrameAdapter adapter;
    late ReferenceFrameBloc bloc;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      adapter = SqliteReferenceFrameAdapter(db);
      await adapter.init();
      bloc = ReferenceFrameBloc(repository: adapter);
    });

    tearDown(() => bloc.dispose());

    test('initial state is ReferenceFrameInitial', () {
      expect(bloc.state, isA<ReferenceFrameInitial>());
    });

    test('load emits ReferenceFrameLoaded with default frame when nothing stored', () async {
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ReferenceFrameLoading>(),
          isA<ReferenceFrameLoaded>(),
        ]),
      );
      bloc.load(kNodeId1);
      await future;
      expect((bloc.state as ReferenceFrameLoaded).frame.astronomicalBody, 'earth');
    });

    test('save persists and emits ReferenceFrameLoaded with saved frame', () async {
      const frame = ReferenceFrame(astronomicalBody: 'moon');
      await bloc.save(kNodeId2, frame);
      expect(bloc.state, isA<ReferenceFrameLoaded>());
      expect((bloc.state as ReferenceFrameLoaded).frame.astronomicalBody, 'moon');
    });

    test('load after save returns previously persisted frame', () async {
      const frame = ReferenceFrame(astronomicalBody: 'mars');
      await adapter.saveReferenceFrame(kNodeId3, frame);
      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ReferenceFrameLoading>(),
          isA<ReferenceFrameLoaded>(),
        ]),
      );
      bloc.load(kNodeId3);
      await future;
      expect((bloc.state as ReferenceFrameLoaded).frame.astronomicalBody, 'mars');
    });

    test('save with validation error emits ReferenceFrameError', () async {
      final frame = ReferenceFrame(astronomicalBody: 'bad\x01body');
      await bloc.save(kNodeId4, frame, alternateSystemsFeatureEnabled: false);
      expect(bloc.state, isA<ReferenceFrameError>());
      expect((bloc.state as ReferenceFrameError).message, contains('pattern'));
    });
  });
}
