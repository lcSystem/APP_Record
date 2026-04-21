import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import '../models/product_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

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
      final db = await databaseFactory.openDatabase('app_record.db',
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
          ));
      await _seedData(db);
      return db;
    } else {
      // Móvil/Desktop
      String path = join(await getDatabasesPath(), 'app_record.db');
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      await _seedData(db);
      return db;
    }
  }

  Future<void> _seedData(Database db) async {
    // Verificar si ya hay usuarios
    final List<Map<String, dynamic>> users = await db.query('users');
    if (users.isEmpty) {
      await db.insert('users', {
        'name': 'Usuario Admin',
        'email': 'admin@app.com',
        'password': '123456',
      });
      print('✅ Usuario admin por defecto creado en BD Local.');
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
    
    // Tabla de Usuarios
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Tabla de Productos
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');
  }

  // ============== MÉTODOS CRUD INTERNOS ==============

  // Usuarios
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> authenticateUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Productos
  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    return await db.insert('products', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Transacciones
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
