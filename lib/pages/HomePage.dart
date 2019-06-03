import 'package:flutter/material.dart';
import 'package:marknote/note.dart';
import 'package:marknote/widgets/NoteCard.dart';
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

  final List<Note> _cards = [
    Note("# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n"),
    Note("# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n"),
    Note("# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n"),
    Note("# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n# Test\n**arroz**\n"),
  ];
  
  void _createNewCard() {
    setState(() {
      _cards.insert(0, Note("# Write here!"));
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _createNewCard,
        ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 18),
        child: Column(
          children: _cards.map((e) => NoteCard(e)).toList(),
        ),
      )
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
}
