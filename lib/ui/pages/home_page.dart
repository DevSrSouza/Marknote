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

  final _scrollController = ScrollController();
  var _cardsloaded = false;

  List<Note> _cards = [];

  void _createNewCard() {
    NoteHelper().newNote("# Write here!").then((note) {
      setState(() {
        _cards.insert(0, note);
      });

      Future.delayed(Duration(milliseconds: 100)).then((value) {
        var scrollPosition = _scrollController.position;
        if(scrollPosition.viewportDimension > scrollPosition.minScrollExtent) {
          _scrollController.animateTo(
              scrollPosition.minScrollExtent,
              duration: new Duration(milliseconds: 300),
              curve: Curves.easeOut
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        floatingActionButton: _cardsloaded && _cards.isNotEmpty ? FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _createNewCard,
        ) : null,
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

  Widget _cardsListView() => _cards.isNotEmpty ? ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.fromLTRB(30, 30, 30, 18),
    itemCount: _cards.length,
    shrinkWrap: true,
    itemBuilder: (context, index) {
      return NoteCard(
          _cards[index],
          key: Key(index.toString() + DateTime.now().millisecondsSinceEpoch.toString())
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
}
