import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/components/property_grid.dart';

import 'shared/coordinate_fixtures.dart';

class _FakeRepository implements AbstractRepository {
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    return {
      'x': kTestCartesianX,
      'y': kTestCartesianY,
      'z': kTestCartesianZ,
    };
  }

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield {};
  }
}

class _EmptyRepository implements AbstractRepository {
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}
  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield {};
  }
}

class _FakeStore implements AbstractRepository {
  Map<String, dynamic> storedData = {};
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    return Map<String, dynamic>.from(storedData);
  }

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {
    storedData = Map<String, dynamic>.from(data);
    _controller.add(data);
  }

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield await fetchProperties(nodeId);
    await for (final event in _controller.stream) {
      yield event;
    }
  }
}

class _FakeRepositoryNoCartesian implements AbstractRepository {
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    return {
      'latitude': 37.7749,
      'longitude': -122.4194,
      'altitude': 10,
    };
  }

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield {};
  }
}

class _CartesianFakeRepo implements AbstractRepository {
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    return {
      'x': kTestCartesianX,
      'y': kTestCartesianY,
      'z': kTestCartesianZ,
    };
  }

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield {};
  }
}

/// Helper finder to locate a TextField by its preceding label text.
Finder findTextFieldByLabel(String labelText) {
  final Finder columnFinder = find.byWidgetPredicate((Widget widget) {
    if (widget is Column) {
      final List<Widget> children = widget.children;
      if (children.isNotEmpty && children.first is Text) {
        final Text textWidget = children.first as Text;
        if (textWidget.data == labelText) {
          return true;
        }
      }
    }
    return false;
  });
  return find.descendant(
    of: columnFinder,
    matching: find.byType(TextField),
  );
}

void main() {
  testWidgets('PropertyGrid loads Cartesian values from repository and displays them', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: _FakeRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('X (m)'), findsOneWidget);
    expect(find.text('Y (m)'), findsOneWidget);
    expect(find.text('Z (m)'), findsOneWidget);
    expect(find.text('$kTestCartesianX'), findsOneWidget);
    expect(find.text('$kTestCartesianY'), findsOneWidget);
    expect(find.text('$kTestCartesianZ'), findsOneWidget);
  });

  testWidgets('PropertyGrid shows empty Cartesian fields when repository returns no Cartesian data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: _FakeRepositoryNoCartesian(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('X (m)'), findsOneWidget);
    expect(find.text('Y (m)'), findsOneWidget);
    expect(find.text('Z (m)'), findsOneWidget);
  });

  testWidgets('PropertyGrid clears height-accuracy when Cartesian data is loaded from repository', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: _FakeRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder heightAccuracyField = findTextFieldByLabel('Height Accuracy');
    expect(heightAccuracyField, findsOneWidget);
    final TextField textField = tester.widget<TextField>(heightAccuracyField);
    expect(textField.controller?.text, '');
  });

  testWidgets('PropertyGrid does NOT show stale default lat/lon when repository returns empty for Location', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: _EmptyRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder latField = findTextFieldByLabel('Latitude');
    expect(latField, findsOneWidget);
    final TextField latTextField = tester.widget<TextField>(latField);
    expect(latTextField.controller?.text, isEmpty);

    final Finder lonField = findTextFieldByLabel('Longitude');
    expect(lonField, findsOneWidget);
    final TextField lonTextField = tester.widget<TextField>(lonField);
    expect(lonTextField.controller?.text, isEmpty);
  });

  testWidgets('Blurring ellipsoidal field must NOT destroy Cartesian data in repository', (tester) async {
    final repo = _FakeStore();
    repo.storedData = {
      'x': kTestCartesianX,
      'y': kTestCartesianY,
      'z': kTestCartesianZ,
      'roomName': 'Main-Data-Room',
      'gridRow': 12,
      'gridColumn': 4,
      'maxVoltage': 240.0,
      'maxAllocatedPower': 15000.0,
      'countryCode': 'US',
      'locationType': 'room',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: repo,
            initialValues: const {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Cartesian values are loaded correctly from repo
    final xField = findTextFieldByLabel('X (m)');
    expect(xField, findsOneWidget);
    TextField xTextField = tester.widget<TextField>(xField);
    expect(xTextField.controller?.text, '$kTestCartesianX');

    // Verify latitude field is empty (Cartesian was loaded, no ellipsoidal data)
    final latField = findTextFieldByLabel('Latitude');
    expect(latField, findsOneWidget);
    TextField latTextField = tester.widget<TextField>(latField);
    expect(latTextField.controller?.text, isEmpty);

    // Focus the latitude field and enter a value, then blur to trigger save
    await tester.enterText(latField, '40.0');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // The Cartesian data must still be in the repository
    // (before the fix, blurring latitude removed x/y/z from committedData before saving)
    final storedData = repo.storedData;
    expect(storedData['x'], kTestCartesianX,
        reason: 'Cartesian X must survive ellipsoidal field blur');
    expect(storedData['y'], kTestCartesianY,
        reason: 'Cartesian Y must survive ellipsoidal field blur');
    expect(storedData['z'], kTestCartesianZ,
        reason: 'Cartesian Z must survive ellipsoidal field blur');
    expect(storedData['latitude'], 40.0,
        reason: 'Latitude value must be saved');
  });

  testWidgets('Blurring Cartesian field must NOT destroy ellipsoidal data in repository', (tester) async {
    final repo = _FakeStore();
    repo.storedData = {
      'latitude': 37.7749,
      'longitude': -122.4194,
      'height': 10.0,
      'roomName': 'Main-Data-Room',
      'gridRow': 12,
      'gridColumn': 4,
      'maxVoltage': 240.0,
      'maxAllocatedPower': 15000.0,
      'countryCode': 'US',
      'locationType': 'room',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: repo,
            initialValues: const {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify ellipsoidal values
    final latField = findTextFieldByLabel('Latitude');
    expect(latField, findsOneWidget);
    TextField latTextField = tester.widget<TextField>(latField);
    expect(latTextField.controller?.text, '37.7749');

    // Verify Cartesian fields are empty
    final xField = findTextFieldByLabel('X (m)');
    expect(xField, findsOneWidget);
    TextField xTextField = tester.widget<TextField>(xField);
    expect(xTextField.controller?.text, isEmpty);

    // Focus the X field and enter a value, then blur to trigger save
    await tester.enterText(xField, '$kTestCartesianX');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // The ellipsoidal data must still be in the repository
    final storedData = repo.storedData;
    expect(storedData['latitude'], 37.7749,
        reason: 'Ellipsoidal latitude must survive Cartesian field blur');
    expect(storedData['longitude'], -122.4194,
        reason: 'Ellipsoidal longitude must survive Cartesian field blur');
    expect(storedData['height'], 10.0,
        reason: 'Ellipsoidal height must survive Cartesian field blur');
    expect(storedData['x'], kTestCartesianX,
        reason: 'Cartesian X value must be saved');
  });

  testWidgets('PropertyGrid preserves all controller values through didUpdateWidget with empty initialValues', (tester) async {
    final repo = _FakeRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: repo,
            initialValues: const {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Cartesian values
    final xField = findTextFieldByLabel('X (m)');
    expect(xField, findsOneWidget);
    TextField xTextField = tester.widget<TextField>(xField);
    expect(xTextField.controller?.text, '$kTestCartesianX');

    // Simulate didUpdateWidget with same view/attrs but empty initialValues
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            repository: repo,
            initialValues: const {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Cartesian values should still be preserved via committedData
    xTextField = tester.widget<TextField>(xField);
    expect(xTextField.controller?.text, '$kTestCartesianX',
        reason: 'Cartesian X must survive didUpdateWidget with empty initialValues');

    final yField = findTextFieldByLabel('Y (m)');
    final TextField yTextField = tester.widget<TextField>(yField);
    expect(yTextField.controller?.text, '$kTestCartesianY',
        reason: 'Cartesian Y must survive didUpdateWidget with empty initialValues');

    final zField = findTextFieldByLabel('Z (m)');
    final TextField zTextField = tester.widget<TextField>(zField);
    expect(zTextField.controller?.text, '$kTestCartesianZ',
        reason: 'Cartesian Z must survive didUpdateWidget with empty initialValues');
  });

  testWidgets('PropertyGrid with custom non-Cartesian attributes still resolves Cartesian section group and labels', (tester) async {
    final customAttrs = [
      AttributeDefinition(
        key: 'interfaces/interface/name',
        label: 'Interface Name',
        type: 'string',
        sectionGroup: 'interface',
        isRequired: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyGrid(
            activeView: 'Location',
            attributes: customAttrs,
            repository: _FakeRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('X (m)'), findsOneWidget);
    expect(find.text('Y (m)'), findsOneWidget);
    expect(find.text('Z (m)'), findsOneWidget);
    expect(find.text('$kTestCartesianX'), findsOneWidget);
    expect(find.text('$kTestCartesianY'), findsOneWidget);
    expect(find.text('$kTestCartesianZ'), findsOneWidget);
  });

  group('Fake repository: committedData overrides stale initialValues', () {
    testWidgets('committedData takes precedence over stale initialValues from Layout contamination',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyGrid(
              activeView: 'Location',
              repository: _CartesianFakeRepo(),
              initialValues: <String, dynamic>{
                'latitude': 37.7749,
                'longitude': -122.4194,
                'height': 10.0,
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cartesian fields must show repo values, NOT stale initialValues
      final xField = findTextFieldByLabel('X (m)');
      expect(xField, findsOneWidget);
      TextField xTextField = tester.widget<TextField>(xField);
      expect(xTextField.controller?.text, '$kTestCartesianX',
          reason: 'X must come from committedData (repo), not stale initialValues');

      final yField = findTextFieldByLabel('Y (m)');
      expect(yField, findsOneWidget);
      final TextField yTextField = tester.widget<TextField>(yField);
      expect(yTextField.controller?.text, '$kTestCartesianY',
          reason: 'Y must come from committedData (repo), not stale initialValues');

      final zField = findTextFieldByLabel('Z (m)');
      expect(zField, findsOneWidget);
      final TextField zTextField = tester.widget<TextField>(zField);
      expect(zTextField.controller?.text, '$kTestCartesianZ',
          reason: 'Z must come from committedData (repo), not stale initialValues');

      // Ellipsoidal fields should be empty: initialValues only apply in didUpdateWidget, not initial load
      final latField = findTextFieldByLabel('Latitude');
      expect(latField, findsOneWidget);
      final TextField latTextField = tester.widget<TextField>(latField);
      expect(latTextField.controller?.text, isEmpty,
          reason: 'Latitude should be empty on initial load; initialValues only used in didUpdateWidget');
    });

    testWidgets('committedData override survives didUpdateWidget with stale initialValues',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyGrid(
              activeView: 'Location',
              repository: _CartesianFakeRepo(),
              initialValues: const {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Cartesian values loaded from repo
      final xField = findTextFieldByLabel('X (m)');
      expect(xField, findsOneWidget);
      TextField xTextField = tester.widget<TextField>(xField);
      expect(xTextField.controller?.text, '$kTestCartesianX');

      // Rebuild with stale initialValues (simulating Layout didUpdateWidget)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyGrid(
              activeView: 'Location',
              repository: _CartesianFakeRepo(),
              initialValues: <String, dynamic>{
                'x': 0.0, // stale — should NOT override DB value
                'y': 0.0,
                'z': 0.0,
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cartesian values must still reflect repo values, not the stale initialValues
      xTextField = tester.widget<TextField>(xField);
      expect(xTextField.controller?.text, '$kTestCartesianX',
          reason: 'X must survive didUpdateWidget with stale initialValues');

      final yField = findTextFieldByLabel('Y (m)');
      final TextField yTextField = tester.widget<TextField>(yField);
      expect(yTextField.controller?.text, '$kTestCartesianY',
          reason: 'Y must survive didUpdateWidget with stale initialValues');

      final zField = findTextFieldByLabel('Z (m)');
      final TextField zTextField = tester.widget<TextField>(zField);
      expect(zTextField.controller?.text, '$kTestCartesianZ',
          reason: 'Z must survive didUpdateWidget with stale initialValues');
    });
  });

  group('Real SqliteRepositoryAdapter: in-memory SQLite integration', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('SqliteRepositoryAdapter fetchProperties returns seeded Cartesian data', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);',
            );
          },
        ),
      );
      await db.insert(
        'properties',
        {
          'node_id': 'Location',
          'data_json': jsonEncode({
            'x': kTestCartesianX,
            'y': kTestCartesianY,
            'z': kTestCartesianZ,
          }),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final repo = SqliteRepositoryAdapter(db);
      final data = await repo.fetchProperties('Location');

      expect(data['x'], kTestCartesianX);
      expect(data['y'], kTestCartesianY);
      expect(data['z'], kTestCartesianZ);
    });

    test('SqliteRepositoryAdapter saveProperties roundtrip', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);',
            );
          },
        ),
      );

      final repo = SqliteRepositoryAdapter(db);
      await repo.saveProperties('Location', {
        'x': 100.0,
        'y': 200.0,
        'z': 300.0,
      });
      final data = await repo.fetchProperties('Location');
      expect(data['x'], 100.0);
      expect(data['y'], 200.0);
      expect(data['z'], 300.0);
    });

    test('SqliteRepositoryAdapter returns empty map for missing node', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);',
            );
          },
        ),
      );

      final repo = SqliteRepositoryAdapter(db);
      final data = await repo.fetchProperties('NoSuchNode');
      expect(data, isEmpty);
    });
  });
}
