import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = 'piremote.db';
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE querystats (
          _id INTEGER PRIMARY KEY,
          totalQueries TEXT NOT NULL,
          queriesBlocked TEXT NOT NULL,
          percentBlocked TEXT NOT NULL,
          blocklist TEXT NOT NULL,
          status TEXT NOT NULL,
          clientsEverSeen TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE devices (
          _id INTEGER PRIMARY KEY,
          protocol TEXT NOT NULL,
          name TEXT NOT NULL,
          ip TEXT NOT NULL,
          apitoken TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE clients (
          _id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          ip TEXT NOT NULL,
          requests TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE logs (
          _id INTEGER PRIMARY KEY,
          client TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          requestType TEXT NOT NULL,
          domain TEXT NOT NULL,
          type TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE topQueries (
          _id INTEGER PRIMARY KEY,
          url TEXT NOT NULL,
          requests TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE topAds (
          _id INTEGER PRIMARY KEY,
          url TEXT NOT NULL,
          requests TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE services (
          _id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          status TEXT NOT NULL,
          regex TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE logsHistory (
          _id INTEGER PRIMARY KEY,
          domain TEXT NOT NULL,
          status TEXT NOT NULL,
          client TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
        ''');
  }

  Future<int> insert(Map<String, dynamic> row, mytable) async {
    Database? db = await instance.database;
    return await db!.insert(mytable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(mytable) async {
    Database? db = await instance.database;
    return await db!.query(mytable, orderBy: "_id DESC");
  }

  Future<int?> queryRowCount(mytable) async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $mytable'));
  }

  Future<int> update(Map<String, dynamic> row, mytable) async {
    Database? db = await instance.database;
    int id = row['_id'];
    return await db!
        .update(mytable, row, where: '_id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id, mytable) async {
    Database? db = await instance.database;
    return await db!.delete(mytable, where: '_id = ?', whereArgs: [id]);
  }

  Future<int> deleteTable(mytable) async {
    Database? db = await instance.database;
    return await db!.delete(mytable);
  }
}
