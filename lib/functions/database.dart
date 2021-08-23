import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "MyRunners.db";
  static final _databaseVersion = 1;

  static final table = 'trackers';
  static final tableRunners = 'runners';

  static final columnId = '_id';
  static final columnLatitud = 'latitud';
  static final columnLongitud = 'longitud';
  static final columnDistancia = 'distancia';
  static final columnVelocidad = 'velocidad';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the functions
  static Database? _database;
  Future <Database> get database async{
    return _database ??= await _initDatabase();
  }

  // this opens the functions (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnLatitud TEXT NOT NULL,
            $columnLongitud TEXT NOT NULL,
            $columnDistancia TEXT NOT NULL,
            $columnVelocidad TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableRunners (
            idRunner INTEGER PRIMARY KEY,
            idUser INTEGER NOT NULL,
            titulo TEXT NOT NULL,
            velocidad TEXT NOT NULL,
            distancia TEXT NOT NULL,
            inicio_coordenadas TEXT NOT NULL,
            fin_coordenadas TEXT NOT NULL
          )
          ''');
  }
  // Helper methods

  // Inserts a row in the functions where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String tabla) async {
    Database db = await instance.database;
    return await db.query(tabla);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future deleteAllRows(String tabla) async {
    Database db = await instance.database;
      await db.execute('''DELETE FROM $tabla''');
  }
  
}