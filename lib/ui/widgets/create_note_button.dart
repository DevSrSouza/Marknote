import 'package:flutter/material.dart';
import 'package:marknote/enums/note_list_status.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:marknote/provider/note_editing_provider.dart';
import 'package:marknote/provider/notes_provider.dart';
import 'package:provider/provider.dart';

typedef CreateNoteCallback = void Function(Note note);

class CreateNoteButton extends StatefulWidget {
  final VoidCallback onCreateNote;
  final bool canHide;

  const CreateNoteButton({
    Key key,
    this.onCreateNote,
    this.canHide = true
  }) : super(key: key);

  @override
  _CreateNoteButtonState createState() => _CreateNoteButtonState();
}

class _CreateNoteButtonState extends State<CreateNoteButton> {
  @override
  Widget build(BuildContext context) {
    final cards = Provider.of<NotesProvider>(context);
    NoteEditingProvider editing;
    try {
      editing = Provider.of<NoteEditingProvider>(context);
    }catch(e) {print(e);}

    return !widget.canHide || (
        editing?.isEditing == false && cards.selectedNoteIndex == null
            && cards.status == NoteListStatus.loaded
            && cards.notes.isNotEmpty
    ) ? _newNoteButton(cards) : Container();
  }

  Widget _newNoteButton(NotesProvider provider) => FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () => _createNewNote(provider),
  );

  void _createNewNote(NotesProvider provider) {
    NoteHelper().newNote("## Edit in pencil above.").then((note) {
      provider.addNote(note);
      if(widget.onCreateNote != null) widget.onCreateNote();
    });
  }
}
