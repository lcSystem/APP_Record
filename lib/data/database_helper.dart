import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Usar sqlite FFI en WEB
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase('app_record.db',
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
          ));
    } else {
      // Móvil/Desktop
      String path = join(await getDatabasesPath(), 'app_record.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de Transacciones locales
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        synced INTEGER DEFAULT 0 
      )
    ''');
    
    // Tabla para ajustes/metas también puede ir aquí después
  }

  // ============== MÉTODOS CRUD INTERNOS ==============

  Future<int> insertTransaction(Map<String, dynamic> transactionMap) async {
    final db = await database;
    // Forzar status no sincronizado si acaba de crearse offline
    transactionMap['synced'] = 0;
    return await db.insert('transactions', transactionMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTransactions() async {
    final db = await database;
    return await db.query('transactions', where: 'synced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(String id) async {
    final db = await database;
    return await db.update('transactions', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }
}
