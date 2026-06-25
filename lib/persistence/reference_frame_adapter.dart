import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/reference_frame.dart';

/// @realizes UML::IReferenceFrameRepository
///
/// Abstract repository interface for [ReferenceFrame] persistence.
/// UI widgets depend only on this interface, never on the concrete adapter.
abstract class IReferenceFrameRepository {
  /// Fetches the stored [ReferenceFrame] for [nodeId], or null if absent.
  Future<ReferenceFrame?> fetchReferenceFrame(String nodeId);

  /// Persists [frame] for [nodeId], overwriting any existing value.
  Future<void> saveReferenceFrame(String nodeId, ReferenceFrame frame);
}

/// @realizes UML::SqliteReferenceFrameAdapter
///
/// Concrete SQLite-backed implementation of [IReferenceFrameRepository].
/// Uses sqflite_common_ffi for Desktop/Linux/macOS/Windows compatibility.
/// Zero-mocking: uses a real database instance injected at construction.
class SqliteReferenceFrameAdapter implements IReferenceFrameRepository {
  final Database _db;

  static const _table = 'reference_frame';

  SqliteReferenceFrameAdapter(this._db);

  /// Creates the persistence table if it does not already exist.
  Future<void> init() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        node_id TEXT PRIMARY KEY,
        astronomical_body TEXT NOT NULL,
        alternate_system TEXT
      )
    ''');
  }

  @override
  Future<ReferenceFrame?> fetchReferenceFrame(String nodeId) async {
    final rows = await _db.query(
      _table,
      where: 'node_id = ?',
      whereArgs: [nodeId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return ReferenceFrame(
      astronomicalBody: row['astronomical_body'] as String,
      alternateSystem: row['alternate_system'] as String?,
    );
  }

  @override
  Future<void> saveReferenceFrame(String nodeId, ReferenceFrame frame) async {
    await _db.insert(
      _table,
      {
        'node_id': nodeId,
        'astronomical_body': frame.astronomicalBody,
        'alternate_system': frame.alternateSystem,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
