import 'package:flutter/material.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:marknote/provider/note_editing_provider.dart';
import 'package:marknote/provider/notes_provider.dart';
import 'package:marknote/ui/widgets/create_note_button.dart';
import 'package:marknote/ui/widgets/note_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  final Icon themeIndicator;
  final VoidCallback switchTheme;

  const HomePage(this.themeIndicator, this.switchTheme, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final editingProvider = NoteEditingProvider();
    return WillPopScope(
      onWillPop: () {
        if(notesProvider.selectedNoteIndex != null) {
          _unselectNote(notesProvider);
          return Future.value(false);
        } else return Future.value(true);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Marknote"),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: widget.themeIndicator,
                  onPressed: widget.switchTheme,
                )
              ],
            ),
            floatingActionButton: ChangeNotifierProvider<NoteEditingProvider>.value(
                value: editingProvider,
                child: _newNoteButton()
            ),
            bottomSheet: notesProvider.selectedNoteIndex != null ? _bottomSheet(context, notesProvider) : null,
            body: NoteList(
              editingProvider: editingProvider,
              scrollController: _scrollController,
              onLongPressNote: (index, note) => _showOptions(notesProvider, index),
            )
        ),
      ),
    );
  }

  Widget _newNoteButton() => CreateNoteButton(onCreateNote: _onCreateNote);

  void _onCreateNote() {
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      var scrollPosition = _scrollController.position;
      if(scrollPosition.viewportDimension > scrollPosition.minScrollExtent) {
        _scrollController.animateTo(
            scrollPosition.maxScrollExtent,
            duration: new Duration(milliseconds: 300),
            curve: Curves.easeOut
        );
      }
    });
  }

  void _unselectNote(NotesProvider provider) {
    provider.updateSelectedNote(null);
  }

  void _showOptions(NotesProvider provider, int index) {
    provider.updateSelectedNote(index);
  }

  Widget _bottomSheet(BuildContext context, NotesProvider provider) => BottomSheet(
    elevation: 8,
    onClosing: () => _unselectNote(provider), // not working: https://github.com/flutter/flutter/issues/27600
    builder: (context) {
      return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _unselectNote(provider),
            ),
            Text(
              "Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                _copyNote(provider);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteNote(provider);
              },
            ),
          ],
        ),
      );
    },
  );

  Note _lastRemovedNote;
  int _lastRemovedIndex;

  void _deleteNote(NotesProvider provider) {
    final index = provider.selectedNoteIndex;
    _lastRemovedNote = provider.notes[index];
    _lastRemovedIndex = index;

    provider.removeAndUpdateSelectedNote(index, null);

    final snack = SnackBar(
      content: Text("Note deleted"),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            provider.insertNote(_lastRemovedIndex, _lastRemovedNote);
          }
      )
    );

    var result = _scaffoldKey.currentState.showSnackBar(snack);
    result.closed.then((reason) {
      if(reason != SnackBarClosedReason.action) {
        NoteHelper().deleteNote(_lastRemovedNote.id);
      }
    });
  }

  void _copyNote(NotesProvider provider) {
    final note = provider.notes[provider.selectedNoteIndex];

    NoteHelper().newNote(note.source, color: note.color).then((note) {
      setState(() {
        provider.addAndUpdateSelectedNote(note, null);
      });
    });
  }
}
