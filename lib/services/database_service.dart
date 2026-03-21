import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

// Conditional import: on web uses dart:html localStorage, on others is a stub
import 'web_storage_stub.dart'
    if (dart.library.html) 'web_storage.dart';

import '../models/receipt_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  static const _webKey = 'resiboscan_receipts';
  sqflite.Database? _db;

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<List<Receipt>> getAllReceipts() async {
    if (kIsWeb) return _webGetAll();
    return _mobileGetAll();
  }

  Future<void> insertReceipt(Receipt r) async {
    if (kIsWeb) { _webInsert(r); return; }
    await _mobileInsert(r);
  }

  Future<void> updateReceipt(Receipt r) async {
    if (kIsWeb) { _webUpdate(r); return; }
    await _mobileUpdate(r);
  }

  Future<void> deleteReceipt(int id) async {
    if (kIsWeb) { _webDelete(id); return; }
    await _mobileDelete(id);
  }

  // ─── Web: localStorage ────────────────────────────────────────────────────

  List<Map<String, dynamic>> _webReadRaw() {
    try {
      final raw = localStorageGet(_webKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  void _webWriteRaw(List<Map<String, dynamic>> list) {
    try {
      localStorageSet(_webKey, jsonEncode(list));
    } catch (_) {}
  }

  List<Receipt> _webGetAll() {
    var raw = _webReadRaw();
    if (raw.isEmpty) {
      final seeds = buildSeedReceipts(Uint8List(0));
      raw = seeds.map(_seedToStorable).toList();
      _webWriteRaw(raw);
    }
    final receipts = raw.map(_storableToReceipt).toList();
    receipts.sort((a, b) => b.date.compareTo(a.date));
    return receipts;
  }

  void _webInsert(Receipt r) {
    final raw = _webReadRaw();
    raw.removeWhere((m) => m['id'] == r.id);
    raw.add(_receiptToStorable(r));
    _webWriteRaw(raw);
  }

  void _webUpdate(Receipt r) {
    final raw = _webReadRaw();
    final idx = raw.indexWhere((m) => m['id'] == r.id);
    if (idx != -1) {
      raw[idx] = _receiptToStorable(r);
    } else {
      raw.add(_receiptToStorable(r));
    }
    _webWriteRaw(raw);
  }

  void _webDelete(int id) {
    final raw = _webReadRaw();
    raw.removeWhere((m) => m['id'] == id);
    _webWriteRaw(raw);
  }

  // ─── Serialization helpers ─────────────────────────────────────────────────

  Map<String, dynamic> _receiptToStorable(Receipt r) => {
    'id'      : r.id,
    'store'   : r.store,
    'amount'  : r.amount,
    'date'    : r.date,
    'category': r.category,
    'warranty': r.warranty,
    'image'   : r.image,
    'folder'  : r.folder,
    'notes'   : r.notes,
    'img_b64' : (r.imageBytes != null && r.imageBytes!.isNotEmpty)
                  ? base64Encode(r.imageBytes!)
                  : null,
  };

  Map<String, dynamic> _seedToStorable(Map<String, dynamic> m) => {
    'id'      : m['id'],
    'store'   : m['store'],
    'amount'  : m['amount'],
    'date'    : m['date'],
    'category': m['category'],
    'warranty': m['warranty'],
    'image'   : m['image'],
    'folder'  : m['folder'],
    'notes'   : m['notes'],
    'img_b64' : (m['imageBytes'] as Uint8List?)?.isNotEmpty == true
                  ? base64Encode(m['imageBytes'] as Uint8List)
                  : null,
  };

  Receipt _storableToReceipt(Map<String, dynamic> m) {
    Uint8List? bytes;
    try {
      final b64 = m['img_b64'] as String?;
      if (b64 != null && b64.isNotEmpty) bytes = base64Decode(b64);
    } catch (_) {}
    return Receipt(
      id        : m['id'] as int,
      store     : m['store'] as String,
      amount    : (m['amount'] as num).toDouble(),
      date      : m['date'] as String,
      category  : m['category'] as String,
      warranty  : m['warranty'] as String?,
      image     : m['image'] as String,
      folder    : m['folder'] as String,
      notes     : m['notes'] as String? ?? '',
      imageBytes: bytes,
    );
  }

  // ─── Mobile: sqflite ──────────────────────────────────────────────────────

  Future<sqflite.Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<sqflite.Database> _initDB() async {
    final dbPath = await sqflite.getDatabasesPath();
    final path   = p.join(dbPath, 'resiboscan.db');
    return sqflite.openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE receipts (
            id INTEGER PRIMARY KEY, store TEXT NOT NULL,
            amount REAL NOT NULL, date TEXT NOT NULL,
            category TEXT NOT NULL, warranty TEXT,
            image TEXT NOT NULL, folder TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT '', image_bytes BLOB
          )
        ''');
        final imgBytes = await loadReceiptSvgBytes();
        for (final r in buildSeedReceipts(imgBytes)) {
          await db.insert('receipts', {
            'id': r['id'], 'store': r['store'], 'amount': r['amount'],
            'date': r['date'], 'category': r['category'],
            'warranty': r['warranty'], 'image': r['image'],
            'folder': r['folder'], 'notes': r['notes'],
            'image_bytes': r['imageBytes'],
          });
        }
      },
    );
  }

  Future<List<Receipt>> _mobileGetAll() async {
    final db = await _database;
    final result = await db.query('receipts', orderBy: 'date DESC');
    return result.map((json) => Receipt.fromMap({
      ...json, 'imageBytes': json['image_bytes'],
    })).toList();
  }

  Future<void> _mobileInsert(Receipt r) async {
    final db = await _database;
    await db.insert('receipts', {
      'id': r.id, 'store': r.store, 'amount': r.amount,
      'date': r.date, 'category': r.category, 'warranty': r.warranty,
      'image': r.image, 'folder': r.folder, 'notes': r.notes,
      'image_bytes': r.imageBytes,
    }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<void> _mobileUpdate(Receipt r) async {
    final db = await _database;
    await db.update('receipts', {
      'store': r.store, 'amount': r.amount, 'date': r.date,
      'category': r.category, 'warranty': r.warranty,
      'image': r.image, 'folder': r.folder, 'notes': r.notes,
      'image_bytes': r.imageBytes,
    }, where: 'id = ?', whereArgs: [r.id]);
  }

  Future<void> _mobileDelete(int id) async {
    final db = await _database;
    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }
}
