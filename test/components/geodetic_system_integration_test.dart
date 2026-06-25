import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/bloc/geodetic_system_bloc.dart';
import 'package:app_flutter/persistence/geodetic_system_adapter.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/domain/geodetic_system.dart';
import 'package:app_flutter/components/layout.dart';
import 'package:app_flutter/components/property_grid.dart';

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

  group('GeodeticSystem integration with Layout PropertyGrid', () {
    late Database db;
    late SqliteGeodeticSystemAdapter adapter;
    late GeodeticSystemBloc bloc;
    late String layoutConfig;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );

      adapter = SqliteGeodeticSystemAdapter(db);
      await adapter.init();
      bloc = GeodeticSystemBloc(repository: adapter);

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
            geodeticSystemBloc: bloc,
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

    testWidgets(
        'Location view shows Geodetic Datum field when GeodeticSystemBloc is provided',
        (WidgetTester tester) async {
      await setUpWidget(tester, activeView: 'Location');

      expect(find.text('Geodetic Datum'), findsOneWidget);
    });

    testWidgets('Saving Geodetic Datum persists via BLoC',
        (WidgetTester tester) async {
      await setUpWidget(tester, activeView: 'Location');
      expect(find.text('Geodetic Datum'), findsOneWidget);

      final datumField = find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text == 'wgs-84',
      );
      expect(datumField, findsOneWidget);

      await tester.enterText(datumField, 'wgs-1984');
      await tester.pump();

      // Remove focus to trigger blur save on datum field
      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 500)));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      final saved = await tester.runAsync<GeodeticSystem?>(
        () => adapter.fetchGeodeticSystem('Location'),
      );
      expect(saved, isNotNull);
      expect(saved!.geodeticDatum, 'wgs-1984');
    });

    testWidgets(
        'Coord Accuracy and Height Accuracy fields appear in Location view',
        (WidgetTester tester) async {
      await setUpWidget(tester, activeView: 'Location');

      expect(find.text('Coord Accuracy'), findsOneWidget);
      expect(find.text('Height Accuracy'), findsOneWidget);
    });
  });
}
