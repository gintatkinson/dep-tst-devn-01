import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/bloc/reference_frame_bloc.dart';
import 'package:app_flutter/domain/reference_frame.dart';
import 'package:app_flutter/persistence/reference_frame_adapter.dart';
import 'package:app_flutter/components/reference_frame_editor.dart';

import '../shared/node_id_fixtures.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ReferenceFrameEditor', () {
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

    setUpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReferenceFrameEditor(bloc: bloc, nodeId: kTestNodeId),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders astronomical-body field with default "earth"', (WidgetTester tester) async {
      await setUpWidget(tester);

      expect(find.text('Astronomical Body'), findsOneWidget);
      expect(find.text('earth'), findsOneWidget);
    });

    testWidgets('saves astronomical-body value and persists it', (WidgetTester tester) async {
      await setUpWidget(tester);

      await tester.enterText(find.byType(TextFormField), 'mars');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();

      final saved = await tester.runAsync<ReferenceFrame?>(
        () => adapter.fetchReferenceFrame(kTestNodeId),
      );
      expect(saved, isNotNull);
      expect(saved!.astronomicalBody, 'mars');
    });

    testWidgets('shows validation error for invalid astronomical body', (WidgetTester tester) async {
      await setUpWidget(tester);

      final TextFormField textField = tester.widget(find.byType(TextFormField));
      textField.controller!.text = 'caf\u00E9';
      expect(textField.controller!.text, 'caf\u00E9');
      await tester.pump();

      await tester.tap(find.text('Save'));
      expect(bloc.state, isA<ReferenceFrameError>());

      await tester.pump();
      expect(find.text('pattern constraint violation: astronomical-body contains invalid characters'), findsOneWidget);
    });

    testWidgets('does not show alternate system field by default', (WidgetTester tester) async {
      await setUpWidget(tester);

      expect(find.text('Alternate System'), findsNothing);
    });

    testWidgets('shows alternate system field when feature is enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReferenceFrameEditor(
              bloc: bloc,
              nodeId: kTestNodeId,
              alternateSystemsFeatureEnabled: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alternate System'), findsOneWidget);
    });
  });
}
