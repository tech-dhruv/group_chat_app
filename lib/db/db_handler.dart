import 'package:chat_app_socket/group/msg_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'chatData.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    // await db.execute(
    //   '''CREATE TABLE chatinfo (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, age INTEGER NOT NULL, description TEXT NOT NULL, email TEXT)''',
    // );
  }

  Future<void> createTable(String tblName) async {
    var dbClient = await db;
    await dbClient!.execute(
      '''CREATE TABLE $tblName (id TEXT, type TEXT NOT NULL, msg TEXT NOT NULL, sender TEXT NOT NULL)''',
    );
    print("***************Create table: $tblName successfully *********");
  }

  Future<List<String>> getTables() async {
    var dbClient = await db;
    final List<Map<String, dynamic>> tables = await dbClient!.rawQuery(
        'SELECT name FROM sqlite_master WHERE type = "table" AND name != "android_metadata"');
    return tables.map((table) => table['name'] as String).toList();
  }

  Future<void> insertChat(
      {required List<MsgModel> msgModel, required String tblName}) async {
    var dbClient = await db;
    for (MsgModel data in msgModel) {
      await dbClient!.insert(tblName, data.toMap());
    }
    // await dbClient!.insert('chatinfo', msgModel.toMap());
    // return msgModel;
  }

  Future<List<MsgModel>> getChatList({required String tblName}) async {
    print("----------------------------------------------");
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query(tblName);

    return queryResult.map((e) => MsgModel.fromMap(e)).toList();
  }

  Future<int> deleteNotes(int id) async {
    var dbClient = await db;
    return await dbClient!.delete(
      'chatinfo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateNotes(MsgModel msgModel) async {
    var dbClient = await db;
    return await dbClient!.update(
      'chatinfo',
      msgModel.toMap(),
      where: 'id = ?',
      whereArgs: [msgModel.id],
    );
  }

  Future deleteTableContent({required String tblName}) async {
    var dbClient = await db;
    return await dbClient!.delete(tblName);
  }

  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }
}
