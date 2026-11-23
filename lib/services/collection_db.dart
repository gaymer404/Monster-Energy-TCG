import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class OwnedCard {
  const OwnedCard(this.flavorId, this.copies);
  final String flavorId;
  final int copies;
}

class CollectionDb {
  CollectionDb._(this._db);
  final Database _db;

  static Future<CollectionDb> open() async {
    final db = await openDatabase(
      p.join(await getDatabasesPath(), 'collection.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE cards ('
            'flavor_id TEXT PRIMARY KEY, copies INTEGER NOT NULL, '
            'first_scanned INTEGER NOT NULL)');
        await db.execute('CREATE TABLE barcodes ('
            'barcode TEXT PRIMARY KEY, flavor_id TEXT NOT NULL)');
      },
    );
    return CollectionDb._(db);
  }

  Future<String?> flavorForBarcode(String barcode) async {
    final rows = await _db.query('barcodes', where: 'barcode = ?', whereArgs: [barcode]);
    return rows.isEmpty ? null : rows.first['flavor_id'] as String;
  }

  Future<void> linkBarcode(String barcode, String flavorId) => _db.insert(
        'barcodes',
        {'barcode': barcode, 'flavor_id': flavorId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  /// Adds a copy and returns the new copy count (1 means a brand-new card).
  Future<int> addCard(String flavorId) {
    return _db.transaction((txn) async {
      final rows = await txn.query('cards', where: 'flavor_id = ?', whereArgs: [flavorId]);
      if (rows.isEmpty) {
        await txn.insert('cards', {
          'flavor_id': flavorId,
          'copies': 1,
          'first_scanned': DateTime.now().millisecondsSinceEpoch,
        });
        return 1;
      }
      final copies = (rows.first['copies'] as int) + 1;
      await txn.update('cards', {'copies': copies}, where: 'flavor_id = ?', whereArgs: [flavorId]);
      return copies;
    });
  }

  Future<List<OwnedCard>> collection() async {
    final rows = await _db.query('cards', orderBy: 'first_scanned DESC');
    return [for (final r in rows) OwnedCard(r['flavor_id'] as String, r['copies'] as int)];
  }
}
