import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/my_item.dart';
import 'models/my_list.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database? _database;
  final int _databaseVersion = 2;
  final String _databaseName = "database.db";

  Future<Database?> get database async {
    // print("Getting database");
    if (_database != null) return _database;
    // print("Database is null, trying to create new.");
    _database = await initDB();
    return _database;
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static _onCreate(Database db, int version) async {
    String createList = '''
      CREATE TABLE list(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT
      );
    ''';
    await db.execute(createList);
    print("Creating list table");
    String createItem = '''
      CREATE TABLE item(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          quantity INTEGER,
          checked INTEGER,
          listId INTEGER,
          value DEC(10, 2),
          FOREIGN KEY (listId) REFERENCES list (id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''';
    await db.execute(createItem);
    print("Creating item table");
    print("Database created");
  }

  static _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      print("Updating database from $oldVersion to $newVersion");
      // you can execute drop table and create table
      db.execute("ALTER TABLE item ADD COLUMN value DEC(10, 2);");
    } else {
      print("No update, everything up to date!");
    }
  }

  initDB() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), _databaseName),
      // When the database is first created, create a table to store dogs.
      onCreate: _onCreate,
      // Call on configure database to enable foreign key.
      onConfigure: _onConfigure,
      // Call on upgrade database
      onUpgrade: _onUpgrade,
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: _databaseVersion,
    );
  }

  /// List databases actions, insert, update, delete and get all

  Future<MyList?> getLatestList() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        'list',
        orderBy: "id DESC",
        limit: 1,
      );
      List<MyList> list = List.generate(maps.length, (i) {
        return MyList(
          id: maps[i]['id'],
          title: maps[i]['title'],
          description: maps[i]['description'],
        );
      });
      return list.first;
    }
    return null;
  }

  Future<void> insertList(MyList list) async {
    final db = await database;
    if (db != null) {
      await db.insert(
        'list',
        list.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateList(MyList list) async {
    final db = await database;
    if (db != null) {
      await db.update(
        'list',
        list.toMap(),
        where: 'id = ?',
        whereArgs: [list.id],
      );
    }
  }

  Future<void> deleteList(int id) async {
    final db = await database;
    if (db != null) {
      await db.delete(
        'list',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<MyList>> getAllLists() async {
    final db = await database;
    // print("Database: $db");
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query('list');

      return List.generate(maps.length, (i) {
        return MyList(
          id: maps[i]['id'],
          title: maps[i]['title'],
          description: maps[i]['description'],
        );
      });
    }
    return [];
  }

  /// Item databases actions, insert, update, delete and get items from a list

  Future<void> insertItem(MyItem item) async {
    final db = await database;
    if (db != null) {
      await db.insert(
        'item',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateItem(MyItem item) async {
    final db = await database;
    if (db != null) {
      await db.update(
        'item',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    if (db != null) {
      await db.delete(
        'item',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<MyItem>> getAllItems(int listId) async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        'item',
        where: 'listId = ?',
        whereArgs: [listId],
      );

      return List.generate(maps.length, (i) {
        return MyItem(
          id: maps[i]['id'],
          listId: maps[i]['listId'],
          name: maps[i]['name'],
          quantity: maps[i]['quantity'],
          checked: maps[i]['checked'],
          value: maps[i]['value'] != null ? maps[i]['value'].toDouble() : 0.00,
        );
      });
    }
    return [];
  }
}
