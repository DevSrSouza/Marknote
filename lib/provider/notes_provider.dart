
import 'package:flutter/foundation.dart';
import 'package:marknote/enums/note_list_status.dart';
import 'package:marknote/note.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  var _status = NoteListStatus.not_loaded;
  Note _editing;
  int _selectedNoteIndex = null;

  List<Note> get notes => List.unmodifiable(_notes);
  NoteListStatus get status => _status;
  Note get editing => _editing;
  int get selectedNoteIndex => _selectedNoteIndex;

  void updateStatus(NoteListStatus status) {
    _status = status;
    notifyListeners();
  }

  void updateEditingNote(Note note) {
    _editing = note;
    notifyListeners();
  }

  void updateSelectedNote(int index) {
    _selectedNoteIndex = index;
    notifyListeners();
  }


  void addAll(List<Note> notes) {
    _notes.addAll(notes);
    notifyListeners();
  }

  void addAllAndUpdateStatus(List<Note> notes, NoteListStatus status) {
    _notes.addAll(notes);
    _status = status;
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void insertNote(int index, Note note) {
    _notes.insert(index, note);
    notifyListeners();
  }

  void removeNote(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }

  void removeAndUpdateSelectedNote(int index, int selectedNote) {
    _notes.removeAt(index);
    _selectedNoteIndex = selectedNote;
    notifyListeners();
  }
}