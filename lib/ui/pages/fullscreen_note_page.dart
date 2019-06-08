import 'package:flutter/material.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:marknote/ui/widgets/note_widget.dart';
import 'package:marknote/ui/widgets/small_icon.dart';

class FullscreenNotePage extends StatefulWidget {

  final Note note;

  const FullscreenNotePage(this.note, {Key key}) : super(key: key);

  @override
  _FullscreenNotePageState createState() => _FullscreenNotePageState();
}

class _FullscreenNotePageState extends State<FullscreenNotePage> {

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
        if(details.horizontalScale < 0.9 && details.verticalScale < 0.9) {
          Navigator.pop(context);
        }
      },
      child: Hero(
        tag: widget.note,
        child: Scaffold(
          backgroundColor: NoteColorHelper.getMaterialColor(widget.note.color)?.shade300 ?? Theme.of(context).cardColor,
          body: SafeArea(
            child: SingleChildScrollView(
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
        ),
      ),
    );
  }
}