import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:marknote/note.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteCard extends StatefulWidget {

  final Note note;

  NoteCard(this.note, {Key key}) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {

  final _editController = TextEditingController();
  var _edit = false;

  void _switchToEditMode() {
    setState(() {
      widget.note.edit = !_edit;
      _edit = !_edit;

      widget.note.source = _editController.text;
    });
  }

  void _switchColor(Color color) {
    if(widget.note.color == color) return; // not rebuild widget if same color
    setState(() {
      widget.note.color = color;
    });
  }

  @override
  void initState() {
    super.initState();
    _editController.text = widget.note.source;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 20),
        child: Card(
          color: widget.note.color ?? Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 29),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            _defaultColor(context),
                            _colorSwitcher(Colors.red.shade300),
                            _colorSwitcher(Colors.green.shade300),
                            _colorSwitcher( Colors.blue.shade300),
                            _colorSwitcher(Colors.deepOrange.shade300),
                            _colorSwitcher(Colors.deepPurple.shade300),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: _edit ? Colors.blueAccent : Colors.grey,
                      ),
                      onPressed: _switchToEditMode,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 22, right: 22),
                  child: _edit ? TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: _editController,
                    style: TextStyle(fontSize: 19),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ) : MarkdownBody(
                    data: widget.note.source,
                    styleSheet: MarkdownStyleSheet(
                      blockquoteDecoration: new BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: new BorderRadius.circular(18.0)
                      ),
                      codeblockDecoration: new BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: new BorderRadius.circular(18.0)
                      ),
                    ),
                    onTapLink: (link) async {
                      if (await canLaunch(link)) {
                        await launch(link);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _smallIconButton(
      IconData icon,
      Color color,
      VoidCallback onTap
      ) => GestureDetector(
    child: Icon(icon, color: color, size: 25),
    onTap: onTap,
  );

  Widget _colorSwitcher(Color color) => _smallIconButton(
      Icons.invert_colors,
      color,
          () {
        _switchColor(color);
      }
  );

  Widget _defaultColor(BuildContext context) {
    final theme = Theme.of(context);
    return _smallIconButton(
      Icons.invert_colors_off,
      theme.iconTheme.color,
      () {_switchColor(theme.cardColor);},
    );
  }
}
