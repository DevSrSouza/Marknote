import 'package:flutter/foundation.dart';

class NoteEditingProvider with ChangeNotifier {
  bool _isEditing = false;

  bool get isEditing => _isEditing;

  void updateIsEditing(bool isEditing) {
    _isEditing = isEditing;
    notifyListeners();
  }
}