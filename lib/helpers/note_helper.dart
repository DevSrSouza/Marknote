import 'dart:io';

import 'package:marknote/note.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final databaseFile = "marknote_notes.db";

final noteTable = "notes";

final idColumn = "_id";
final sourceColumn = "source";
final colorColumn = "color";

class NoteHelper {
  static final NoteHelper _instance = NoteHelper.internal();
  factory NoteHelper() => _instance;
  NoteHelper.internal();

  Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory docs = await getApplicationDocumentsDirectory();
    String path = join(docs.path, databaseFile);
    return await openDatabase(path, version: 1, onOpen: (db) {
      // TODO load all ?
    }, onCreate: (Database db, int version) async {

      String createTable = "CREATE TABLE $noteTable ("
          "$idColumn INTEGER  primary key autoincrement not null, "
          "$sourceColumn TEXT not null, "
          "$colorColumn INT"
          ")";

      await db.execute(createTable);
    });
  }

  Note fromMap(Map<String, dynamic> map) {
    int colorId = map[colorColumn];
    return Note(
      map[idColumn],
      map[sourceColumn],
      colorId != null ? NoteColor.values[colorId] : null
    );
  }

  Future<Note> newNote(String source) async {
    Database con = await database;

    int id = await con.insert(noteTable, {
      sourceColumn: source ?? ""
    });

    return Note(id, source ?? "", null);
  }

  Future<void> updateSource(Note note) async {
    Database con = await database;

    await con.update(noteTable, {
      sourceColumn: note.source ?? ""
    }, where: "$idColumn = ?", whereArgs: [note.id]);
  }

  Future<void> updateColor(Note note) async {
    Database con = await database;

    await con.update(noteTable, {
      colorColumn: note.color?.index
    }, where: "$idColumn = ?", whereArgs: [note.id]);
  }

  Future<void> deleteNote(int id) async {
    Database con = await database;

    await con.delete(noteTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<List<Note>> getAllNotes() async {
    Database con = await database;

    List<Map<String, dynamic>> lines = await con.rawQuery("SELECT * FROM $noteTable");
    return lines.map((m) => fromMap(m)).toList();
  }

  Future<void> close() async {
    Database con = await database;

    await con.close();
  }
}