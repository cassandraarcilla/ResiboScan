import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('resiboscan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE receipts (
        id          INTEGER PRIMARY KEY,
        store       TEXT NOT NULL,
        amount      REAL NOT NULL,
        date        TEXT NOT NULL,
        category    TEXT NOT NULL,
        warranty    TEXT,
        image       TEXT NOT NULL,
        folder      TEXT NOT NULL,
        notes       TEXT NOT NULL DEFAULT '',
        image_bytes BLOB
      )
    ''');
    
    // Seed dummy receipts
    final imgBytes = await loadReceiptSvgBytes();
    final seedReceipts = buildSeedReceipts(imgBytes);
    
    for (var r in seedReceipts) {
      await db.insert(
        'receipts',
        {
          'id': r['id'],
          'store': r['store'],
          'amount': r['amount'],
          'date': r['date'],
          'category': r['category'],
          'warranty': r['warranty'],
          'image': r['image'],
          'folder': r['folder'],
          'notes': r['notes'],
          'image_bytes': r['imageBytes'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<Receipt>> getAllReceipts() async {
    final db = await instance.database;
    final result = await db.query('receipts', orderBy: 'date DESC');

    return result.map((json) {
      // Map database columns to Receipt.fromMap expected keys
      return Receipt.fromMap({
        ...json,
        'imageBytes': json['image_bytes'],
      });
    }).toList();
  }

  Future<void> insertReceipt(Receipt r) async {
    final db = await instance.database;
    await db.insert(
      'receipts',
      {
        'id': r.id,
        'store': r.store,
        'amount': r.amount,
        'date': r.date,
        'category': r.category,
        'warranty': r.warranty,
        'image': r.image,
        'folder': r.folder,
        'notes': r.notes,
        'image_bytes': r.imageBytes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateReceipt(Receipt r) async {
    final db = await instance.database;
    await db.update(
      'receipts',
      {
        'store': r.store,
        'amount': r.amount,
        'date': r.date,
        'category': r.category,
        'warranty': r.warranty,
        'image': r.image,
        'folder': r.folder,
        'notes': r.notes,
        'image_bytes': r.imageBytes,
      },
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  Future<void> deleteReceipt(int id) async {
    final db = await instance.database;
    await db.delete(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
