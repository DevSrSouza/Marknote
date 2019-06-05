import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:marknote/ui/pages/fullscreen_note_page.dart';
import 'package:marknote/ui/widgets/note_widget.dart';
import 'package:marknote/ui/widgets/small_icon.dart';

class NoteCard extends StatefulWidget {

  final Note note;

  const NoteCard(this.note, {Key key}) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {

  void _switchColor(NoteColor color) {
    if(widget.note.color == color) return; // not rebuild widget if same color
    setState(() {
      widget.note.color = color;

      NoteHelper().updateColor(widget.note);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        if(details.horizontalScale > 1.1 && details.verticalScale > 1.1)
          _moveToFullscreen();
      },
      child: Container(
          padding: EdgeInsets.only(bottom: 20),
          child: Hero(
            tag: widget.note,
            child: Card(
              color: NoteColorHelper.getMaterialColor(widget.note.color)?.shade300 ?? Theme.of(context).cardColor,
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
                        onPressed: _moveToFullscreen,
                      )
                    ],
                ),
              ),
            ),
          )
      ),
    );
  }

  void _moveToFullscreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenNotePage(widget.note)));
  }
}
