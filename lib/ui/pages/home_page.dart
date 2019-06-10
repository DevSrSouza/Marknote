import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:marknote/ui/widgets/notecard.dart';
import 'package:dragable_flutter_list/dragable_flutter_list.dart';

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
  var _cardsloaded = false;

  List<Note> _cards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        floatingActionButton: _selectedNoteIndex == null && _cardsloaded && _cards.isNotEmpty ? FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _createNewCard,
        ) : null,
        bottomSheet: _selectedNoteIndex != null ? _bottomSheet(context) : null,
      body: _cardsList()
        /*child: DragAndDropList(
            _cards.length,
            scrollController: _scrollController,
            onDragFinish: (before, after) {
              var aux = _cards[after];
              _cards[after] = _cards[before];
              _cards[before] = aux;
            },
            canDrag: (index) {
              return !_cards[index].edit;
            },
            canBeDraggedTo: (one, two) => true,
            dragElevation: 5.0,
            itemBuilder: (context, index) => NoteCard(_cards[index], key: Key(index.toString() + DateTime.now().millisecondsSinceEpoch.toString()))
        )*/,
        //onReorder: (int actual, int next) {},
        //children: _cards.map((e) => NoteCard(e, key: Key(DateTime.now().millisecondsSinceEpoch.toString()))).toList(),
        //scrollDirection: Axis.vertical,
      //),
    );
  }

  void _createNewCard() {
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
            setState(() {
              _selectedNoteIndex = null;
            });
        },
        child: NoteCard(
            _cards[index],
            key: Key(index.toString() + DateTime.now().millisecondsSinceEpoch.toString()),
            onScaleFullscreen: () { _selectedNoteIndex = null; },
            side: _selectedNoteIndex == index ? BorderSide(
              color: Colors.grey.shade500,
              width: 4
            ) : BorderSide.none,
        ),
      );
    },
  ) : Center(
    child: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        _createNewCard();
      },
    ),
  );

  Widget _cardsList() {
    if(_cardsloaded) {
      return _cardsListView();
    } else {
      return FutureBuilder<List<Note>>(
        future: NoteHelper().getAllNotes(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
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
            default:
              if(snapshot.hasError) return Center(
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

                      });
                    },
                  ),
                ),
              );
              else {
                _cards = snapshot.data;
                _cardsloaded = true;
                return _cardsListView();
              }
          }
        },
      );
    }
  }

  void _showOptions(BuildContext context, int index) {
    setState(() {
      _selectedNoteIndex = index;
    });
  }

  Widget _bottomSheet(BuildContext context) => BottomSheet(
    elevation: 4,
    onClosing: () { // not working: https://github.com/flutter/flutter/issues/27600
      setState(() {
        _selectedNoteIndex = null;
      });
    },
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                Navigator.pop(context);
                _copyNote(_selectedNoteIndex);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Navigator.pop(context);
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
      _cards.removeAt(index);

      NoteHelper().deleteNote(_lastRemovedNote.id);
    });

    final snack = SnackBar(
      content: Text("Note deleted"),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              _cards.insert(_lastRemovedIndex, _lastRemovedNote);

              NoteHelper().newNote(
                  _lastRemovedNote.source,
                  color: _lastRemovedNote.color,
                  createTime: _lastRemovedNote.createTime
              );
            });
          }
      )
    );

    _scaffoldKey.currentState.showSnackBar(snack);
  }

  void _copyNote(int index) {
    final note = _cards[index];

    NoteHelper().newNote(note.source, color: note.color).then((note) {
      setState(() {
        _cards.add(note);
      });
    });
  }
}
