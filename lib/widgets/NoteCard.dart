import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:marknote/note.dart';
import 'package:marknote/pages/FullscreenNotePage.dart';
import 'package:marknote/widgets/NoteWidget.dart';
import 'package:marknote/widgets/SmallIcon.dart';

class NoteCard extends StatefulWidget {

  final Note note;

  const NoteCard(this.note, {Key key}) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {

  void _switchColor(MaterialColor color) {
    if(widget.note.color == color) return; // not rebuild widget if same color
    setState(() {
      widget.note.color = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 20),
        child: Hero(
          tag: widget.note,
          child: Card(
            color: widget.note.color?.shade300 ?? Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 29),
              child: NoteWidget(
                  widget.note,
                  onSwitchColor: _switchColor,
                  actions: <Widget>[
                    SmallIcon(
                      Icon(Icons.fullscreen),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenNotePage(widget.note)));
                      },
                    )
                  ],
              ),
            ),
          ),
        )
    );
  }
}
