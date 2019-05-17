import 'package:flutter/material.dart';
import 'package:marknote/note.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'SmallIcon.dart';

typedef ColorSwitchCallback = void Function(MaterialColor color);

class NoteWidget extends StatefulWidget {

  final Note note;
  final List<Widget> actions;
  final ColorSwitchCallback onSwitchColor;

  const NoteWidget(this.note, {Key key, this.actions = const [], this.onSwitchColor}) : super(key: key);

  @override
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {

  final _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.note.source;
  }

  void _switchToEditMode() {
    setState(() {
      widget.note.edit = !widget.note.edit;

      widget.note.source = _editController.text;
    });
  }

  void _switchColor(MaterialColor color) {
    if(widget.note.color == color) return; // not rebuild widget if same color

    if(widget.onSwitchColor != null)
      widget.onSwitchColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    _colorSwitcher(Colors.red),
                    _colorSwitcher(Colors.green),
                    _colorSwitcher(Colors.blue),
                    _colorSwitcher(Colors.deepOrange),
                    _colorSwitcher(Colors.deepPurple),
                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: <Widget>[
                  ...widget.actions,
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SmallIcon(
                      Icon(
                        Icons.remove_red_eye,
                        color: widget.note.edit ? Colors.blueAccent : Colors.grey,
                      ),
                      onPressed: _switchToEditMode,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 22, right: 22),
          child: widget.note.edit ? TextField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: _editController,
            style: TextStyle(fontSize: 19),
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
          ) : MarkdownBody(
            data: widget.note.source,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              blockquoteDecoration: new BoxDecoration(
                  color: widget.note.color?.shade400 ?? Theme.of(context).cardColor,
                  borderRadius: new BorderRadius.circular(13.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                    )
                  ]
              ),
              code: TextStyle(
                  fontFamily: "Source Code Pro"
              ),
              codeblockDecoration: new BoxDecoration(
                  color: Theme.of(context).cardColor,
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
    );
  }

  Widget _smallIconButton(
      IconData icon,
      Color color,
      VoidCallback onTap
  ) => SmallIcon(
    Icon(icon, color: color, size: 25),
    onPressed: onTap,
  );

  Widget _colorSwitcher(MaterialColor color) => _smallIconButton(
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
