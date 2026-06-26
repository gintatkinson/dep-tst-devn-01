import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';

abstract class IEllipsoidalCoordinatesRepository {
  Future<EllipsoidalCoordinates?> fetchEllipsoidalCoordinates(String nodeId);
  Future<void> saveEllipsoidalCoordinates(String nodeId, EllipsoidalCoordinates coords);
}

class SqliteEllipsoidalCoordinatesAdapter implements IEllipsoidalCoordinatesRepository {
  final Database _db;
  static const _table = 'ellipsoidal_coords';

  SqliteEllipsoidalCoordinatesAdapter(this._db);

  Future<void> init() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        node_id TEXT PRIMARY KEY,
        latitude REAL,
        longitude REAL,
        height REAL
      )
    ''');
  }

  @override
  Future<EllipsoidalCoordinates?> fetchEllipsoidalCoordinates(String nodeId) async {
    final rows = await _db.query(
      _table,
      where: 'node_id = ?',
      whereArgs: [nodeId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return EllipsoidalCoordinates(
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      height: (row['height'] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> saveEllipsoidalCoordinates(String nodeId, EllipsoidalCoordinates coords) async {
    await _db.insert(
      _table,
      {
        'node_id': nodeId,
        'latitude': coords.latitude,
        'longitude': coords.longitude,
        'height': coords.height,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
