import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:marknote/ui/widgets/notecard.dart';

class HomePage extends StatefulWidget {

  final Icon themeIndicator;
  final VoidCallback switchTheme;

  const HomePage(this.themeIndicator, this.switchTheme, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum _CardListStatus { loaded, not_loaded, fail_load }

class _HomePageState extends State<HomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  var _cardStatus = _CardListStatus.not_loaded;

  List<Note> _cards = [];

  @override
  void initState() {
    super.initState();

    _loadCardList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if(_selectedNoteIndex != null) {
          _unselectNote();
          return Future.value(false);
        } else return Future.value(true);
      },
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("MarkNote"),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: widget.themeIndicator,
                onPressed: widget.switchTheme,
              )
            ],
          ),
          floatingActionButton: _selectedNoteIndex == null
              && _cardStatus == _CardListStatus.loaded
              && _cards.isNotEmpty ? _newNoteButton() : null,
          bottomSheet: _selectedNoteIndex != null ? _bottomSheet(context) : null,
          body: _body(),
      ),
    );
  }

  Widget _newNoteButton() => FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: _createNewNote,
  );

  void _createNewNote() {
    NoteHelper().newNote("# Write here!").then((note) {
      setState(() {
        _cards.add(note);
      });

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
    });
  }

  int _selectedNoteIndex = null;

  void _unselectNote() {
    _selectedNoteIndex = null;
  }

  Widget _body() {
    switch(_cardStatus) {
      case _CardListStatus.loaded:
        return _cardsListView();
      case _CardListStatus.not_loaded:
        return _waitingCards();
      case _CardListStatus.fail_load:
        return _failLoad();
    }
  }

  Widget _cardsListView() => _cards.isNotEmpty ? ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.fromLTRB(30, 30, 30, 18),
    itemCount: _cards.length,
    shrinkWrap: true,
    reverse: true,
    itemBuilder: (context, index) {
      return GestureDetector(
        onLongPress: () {
          _showOptions(context, index);
        },
        onTap: () {
          if(_selectedNoteIndex != null && _selectedNoteIndex != index)
            setState(_unselectNote);
        },
        child: NoteCard(
            _cards[index],
            key: Key(index.toString() + DateTime.now().millisecondsSinceEpoch.toString()),
            onScaleFullscreen: _unselectNote,
            side: _selectedNoteIndex == index ? BorderSide(
              color: Colors.grey.shade500,
              width: 4
            ) : BorderSide.none,
        ),
      );
    },
  ) : Center(
    child: _newNoteButton(),
  );

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

  Widget _failLoad() => Center(
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
          setState(() {
            _cardStatus = _CardListStatus.not_loaded;
          });
          _loadCardList();
        },
      ),
    ),
  );

  Widget _loadCardList() {
    NoteHelper().getAllNotes().then((notes) {
      setState(() {
        _cards = notes;
        _cardStatus = _CardListStatus.loaded;
      });
    }).catchError((e) {
      setState(() {
        _cardStatus = _CardListStatus.fail_load;
      });
    });
  }

  void _showOptions(BuildContext context, int index) {
    setState(() {
      _selectedNoteIndex = index;
    });
  }

  Widget _bottomSheet(BuildContext context) => BottomSheet(
    elevation: 8,
    onClosing: () => setState(_unselectNote), // not working: https://github.com/flutter/flutter/issues/27600
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
              onPressed: () => setState(_unselectNote),
            ),
            Text(
              "Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                _copyNote(_selectedNoteIndex);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteNote(_selectedNoteIndex);
              },
            ),
          ],
        ),
      );
    },
  );

  Note _lastRemovedNote;
  int _lastRemovedIndex;

  void _deleteNote(int index) {
    _lastRemovedNote = _cards[index];
    _lastRemovedIndex = index;

    setState(() {
      _unselectNote();
      _cards.removeAt(index);
    });

    final snack = SnackBar(
      content: Text("Note deleted"),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              _cards.insert(_lastRemovedIndex, _lastRemovedNote);
            });
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

  void _copyNote(int index) {
    final note = _cards[index];

    NoteHelper().newNote(note.source, color: note.color).then((note) {
      setState(() {
        _unselectNote();
        _cards.add(note);
      });
    });
  }
}
