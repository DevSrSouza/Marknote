import 'package:flutter/material.dart';
import 'package:marknote/note.dart';
import 'package:marknote/widgets/NoteWidget.dart';
import 'package:marknote/widgets/SmallIcon.dart';

class FullscreenNotePage extends StatefulWidget {

  final Note note;

  const FullscreenNotePage(this.note, {Key key}) : super(key: key);

  @override
  _FullscreenNotePageState createState() => _FullscreenNotePageState();
}

class _FullscreenNotePageState extends State<FullscreenNotePage> {

  void _switchColor(MaterialColor color) {
    if(widget.note.color == color) return; // not rebuild widget if same color
    setState(() {
      widget.note.color = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.note,
      child: Material(
        color: widget.note.color?.shade300 ?? Theme.of(context).cardColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 25),
          child: Container(
            child: NoteWidget(
              widget.note,
              actions: <Widget>[
                SmallIcon(
                  Icon(Icons.fullscreen_exit),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              onSwitchColor: _switchColor,
            ),
          ),
        ),
      ),
    );
  }
}