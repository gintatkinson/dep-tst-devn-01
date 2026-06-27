import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/bloc/ellipsoidal_coordinates_bloc.dart';
import 'package:app_flutter/persistence/ellipsoidal_coordinates_adapter.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';
import 'package:app_flutter/components/layout.dart';
import 'package:app_flutter/components/property_grid.dart';

import '../shared/coordinate_fixtures.dart';

class _NoopRepository implements AbstractRepository {
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}
  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) => Stream.value({});
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EllipsoidalCoordinates integration with Layout PropertyGrid', () {
    late Database db;
    late SqliteEllipsoidalCoordinatesAdapter adapter;
    late EllipsoidalCoordinatesBloc bloc;
    late String layoutConfig;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      adapter = SqliteEllipsoidalCoordinatesAdapter(db);
      await adapter.init();
      bloc = EllipsoidalCoordinatesBloc(repository: adapter);

      layoutConfig = jsonEncode({
        'layout': {
          'root_container': {
            'type': 'SidebarLayout',
            'children': [
              {'type': 'HierarchyTreeSelector'},
              {
                'type': 'SplitWorkspace',
                'children': [
                  {'type': 'TopographicalView'},
                  {
                    'type': 'TabbedContainer',
                    'children': [
                      {'id': 'sub_elements_table', 'type': 'TableView'}
                    ]
                  }
                ]
              }
            ]
          }
        }
      });
    });

    tearDown(() {
      bloc.dispose();
      db.close();
    });

    Future<void> setUpWidget(WidgetTester tester,
        {required String activeView}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Layout(
            activeView: activeView,
            layoutConfig: layoutConfig,
            ellipsoidalCoordinatesBloc: bloc,
            repository: _NoopRepository(),
            child: PropertyGrid(
              activeView: activeView,
              initialValues: const {},
              onSave: (key, value) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('Location view shows Latitude field when BLoC is provided',
        (WidgetTester tester) async {
      await setUpWidget(tester, activeView: 'Location');
      expect(find.text('Latitude'), findsAtLeast(1));
    });

    testWidgets('Location view shows Longitude field',
        (WidgetTester tester) async {
      await setUpWidget(tester, activeView: 'Location');
      expect(find.text('Longitude'), findsAtLeast(1));
    });

    testWidgets('Location view shows Height field',
        (WidgetTester tester) async {
      await setUpWidget(tester, activeView: 'Location');
      expect(find.text('Height (m)'), findsOneWidget);
    });

    testWidgets('Saving latitude persists via BLoC',
        (WidgetTester tester) async {
      await setUpWidget(tester, activeView: 'Location');

      final latColumn = find.byWidgetPredicate((w) =>
        w is Column &&
        w.children.isNotEmpty &&
        w.children.first is Text &&
        (w.children.first as Text).data == 'Latitude');
      final latField = find.descendant(
        of: latColumn,
        matching: find.byType(TextField),
      );
      expect(latField, findsOneWidget);

      await tester.enterText(latField.first, kTestLatitude.toString());
      await tester.pump();

      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      final saved = await tester.runAsync<EllipsoidalCoordinates?>(
        () => adapter.fetchEllipsoidalCoordinates('Location'),
      );
      expect(saved, isNotNull);
      expect(saved!.latitude, kTestLatitude);
    });
  });
}
