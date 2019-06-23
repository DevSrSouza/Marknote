import 'package:flutter/material.dart';
import 'package:marknote/provider/note_editing_provider.dart';
import 'package:marknote/ui/widgets/create_note_button.dart';
import 'package:marknote/utils.dart';
import 'package:provider/provider.dart';
import 'package:after_layout/after_layout.dart';
import 'package:marknote/enums/note_list_status.dart';
import 'package:marknote/provider/notes_provider.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:marknote/ui/widgets/notecard.dart';

typedef LongPressNoteCallback = void Function(int index, Note note);

class NoteList extends StatefulWidget {
  final ScrollController scrollController;
  final LongPressNoteCallback onLongPressNote;
  final NoteEditingProvider editingProvider;

  const NoteList({Key key, this.scrollController, this.onLongPressNote, @required this.editingProvider}) : super(key: key);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> with AfterLayoutMixin<NoteList> {

  @override
  void afterFirstLayout(BuildContext context) {
    _loadCardList(Provider.of<NotesProvider>(context));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotesProvider>(context);
    switch(provider.status) {
      case NoteListStatus.loaded:
        return _cardsListView(provider);
      case NoteListStatus.not_loaded:
        return _waitingCards();
      case NoteListStatus.fail_load:
        return _failLoad(provider);
    }
  }

  Widget _loadCardList(NotesProvider provider) {
    NoteHelper().getAllNotes().then((notes) {
      provider.addAllAndUpdateStatus(notes, NoteListStatus.loaded);
    }).catchError((e) {
      provider.updateStatus(NoteListStatus.fail_load);
    });
  }

  Widget _newNoteButton() => CreateNoteButton(canHide: false);

  void onJoinEditMode(NotesProvider provider, Note note) {
    if(provider.editing != null) provider.editing.edit = false;
    provider.updateEditingNote(note);
  }

  void onLeaveEditMode(NotesProvider notesProvider, Note note) {
    notesProvider.updateEditingNote(null);
    widget.editingProvider.updateIsEditing(false);
  }

  void onStartEditNote(NotesProvider notesProvider, Note note) {
    print(note == notesProvider.editing);
    if(note == notesProvider.editing)
      widget.editingProvider.updateIsEditing(true);
  }

  void onStopEditNote(NotesProvider notesProvider, Note note) {
    if(note == notesProvider.editing)
      widget.editingProvider.updateIsEditing(false);
  }

  void _unselectNote(NotesProvider provider) {
    provider.updateSelectedNote(null);
  }

  Widget _cardsListView(NotesProvider provider) {
    final notes = provider.notes;
    return provider.notes.isNotEmpty ? ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 18),
      itemCount: notes.length,
      shrinkWrap: true,
      itemBuilder: (context, i) {
        final index = (notes.length -1) - i;
        final note = notes[index];
        return GestureDetector(
          onLongPress: () {
            if(widget.onLongPressNote != null) widget.onLongPressNote(index, note);
          },
          onTap: () {
            if (provider.selectedNoteIndex != null && provider.selectedNoteIndex != index)
              _unselectNote(provider);
            if(widget.editingProvider.isEditing && provider.editing != note)
              removeFocus(context);
          },
          child: NoteCard(
            note,
            key: Key(index.toString() + DateTime.now().millisecondsSinceEpoch.toString()),
            onScaleFullscreen: () => _unselectNote(provider),
            onJoinEditMode: () => onJoinEditMode(provider, note),
            onLeaveEditMode: () => onLeaveEditMode(provider, note),
            onEditFieldFocusChange: (focus) {
              if (focus) onStartEditNote(provider, note);
              else onStopEditNote(provider, note);
            },
            side: provider.selectedNoteIndex == index ? BorderSide(
                color: Colors.grey.shade500,
                width: 4
            ) : BorderSide.none,
          ),
        );
      },
    ) : Center(
      child: _newNoteButton(),
    );
  }

  Widget _waitingCards() => Center(
    child: Container(
      width: 200,
      height: 200,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 5,
      ),
    ),
  );

  Widget _failLoad(NotesProvider provider) => Center(
    child: Container(
      alignment: Alignment.center,
      height: 100,
      width: 150,
      child: RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Reload"), Icon(Icons.refresh)
          ],
        ),
        onPressed: () {
          provider.updateStatus(NoteListStatus.not_loaded);
          _loadCardList(provider);
        },
      ),
    ),
  );
}
