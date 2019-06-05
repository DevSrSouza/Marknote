import 'package:flutter/material.dart';

enum NoteColor { red, green, blue, orange, purple }

class NoteColorHelper {
  static MaterialColor getMaterialColor(NoteColor color) {
    if(color == null) return null;
    switch(color) {
      case NoteColor.red:
        return Colors.red;
      case NoteColor.green:
        return Colors.green;
      case NoteColor.blue:
        return Colors.blue;
      case NoteColor.orange:
        return Colors.deepOrange;
      case NoteColor.purple:
        return Colors.deepPurple;
    }
  }
}

class Note {
  final int id;
  String source;
  NoteColor color;

  var edit = false;

  Note(this.id, this.source, this.color);
}