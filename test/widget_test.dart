import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/main.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/domain/geodetic_system.dart';
import 'package:app_flutter/bloc/geodetic_system_bloc.dart';
import 'package:app_flutter/persistence/geodetic_system_adapter.dart';
import 'package:app_flutter/bloc/ellipsoidal_coordinates_bloc.dart';
import 'package:app_flutter/persistence/ellipsoidal_coordinates_adapter.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';

class MockGeodeticRepo implements IGeodeticSystemRepository {
  @override
  Future<GeodeticSystem?> fetchGeodeticSystem(String nodeId) async => null;
  @override
  Future<void> saveGeodeticSystem(String nodeId, GeodeticSystem system) async {}
}

class MockEllipsoidalRepo implements IEllipsoidalCoordinatesRepository {
  @override
  Future<EllipsoidalCoordinates?> fetchEllipsoidalCoordinates(String nodeId) async => null;
  @override
  Future<void> saveEllipsoidalCoordinates(String nodeId, EllipsoidalCoordinates coords) async {}
}

class MockRepository implements AbstractRepository {
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}
  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) => Stream.empty();
}

void main() {
  testWidgets('Dashboard console boots and renders main widgets successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      repository: MockRepository(),
      geodeticSystemBloc: GeodeticSystemBloc(repository: MockGeodeticRepo()),
      ellipsoidalCoordinatesBloc: EllipsoidalCoordinatesBloc(repository: MockEllipsoidalRepo()),
    ));

    // Allow FutureBuilder to resolve the asset loading future
    await tester.pumpAndSettle();

    // Verify that the console boots successfully and there are no crash loops
    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(DashboardPage), findsOneWidget);

    // Verify the 'Antigravity Console' header exists (it's present in the tree navigation area)
    expect(find.text('Antigravity Console'), findsAtLeast(1));

    // Verify the active view text exists and starts at 'Ingestion'
    expect(find.text('Active View: Ingestion'), findsOneWidget);
  });
}
