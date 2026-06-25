import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/geodetic_system.dart';

abstract class IGeodeticSystemRepository {
  Future<GeodeticSystem?> fetchGeodeticSystem(String nodeId);

  Future<void> saveGeodeticSystem(String nodeId, GeodeticSystem system);
}

class SqliteGeodeticSystemAdapter implements IGeodeticSystemRepository {
  final Database _db;

  static const _table = 'geodetic_system';

  SqliteGeodeticSystemAdapter(this._db);

  Future<void> init() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        node_id TEXT PRIMARY KEY,
        geodetic_datum TEXT NOT NULL,
        coord_accuracy REAL,
        height_accuracy REAL
      )
    ''');
  }

  @override
  Future<GeodeticSystem?> fetchGeodeticSystem(String nodeId) async {
    final rows = await _db.query(
      _table,
      where: 'node_id = ?',
      whereArgs: [nodeId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return GeodeticSystem(
      geodeticDatum: row['geodetic_datum'] as String,
      coordAccuracy: (row['coord_accuracy'] as num?)?.toDouble(),
      heightAccuracy: (row['height_accuracy'] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> saveGeodeticSystem(String nodeId, GeodeticSystem system) async {
    await _db.insert(
      _table,
      {
        'node_id': nodeId,
        'geodetic_datum': system.geodeticDatum,
        'coord_accuracy': system.coordAccuracy,
        'height_accuracy': system.heightAccuracy,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
