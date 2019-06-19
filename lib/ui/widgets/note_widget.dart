import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/note.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:marknote/ui/widgets/small_icon.dart';

typedef ColorSwitchCallback = void Function(NoteColor color);
typedef FocusChangeCallback = void Function(bool hasFocus);

class NoteWidget extends StatefulWidget {

  final Note note;
  final List<Widget> actions;
  final ColorSwitchCallback onSwitchColor;
  final VoidCallback onJoinEditMode;
  final VoidCallback onLeaveEditMode;
  final FocusChangeCallback onEditFieldFocusChange;
  final int editMinLines;

  const NoteWidget(
      this.note,
      {
        Key key,
        this.actions = const [],
        this.onSwitchColor,
        this.onJoinEditMode,
        this.onLeaveEditMode,
        this.onEditFieldFocusChange,
        this.editMinLines = 1
      }
  ) : super(key: key);

  @override
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {

  final _editController = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.note.source;

    _focus.addListener(() {
      if(widget.onEditFieldFocusChange != null)
        widget.onEditFieldFocusChange(_focus.hasFocus);
    });
  }

  void _switchToEditMode() {
    setState(() {
      final note = widget.note;
      note.edit = !note.edit;
      
      if(note.edit == false) {
        note.source = _editController.text;
        NoteHelper().updateSource(note);
        if(widget.onLeaveEditMode != null) widget.onLeaveEditMode();
      } else if(widget.onJoinEditMode != null) widget.onJoinEditMode();
    });
  }
  
  void _removeColor() {
    _switchColor(null);
  }

  void _switchColor(NoteColor color) {
    if(widget.note.color == color) return; // not rebuild widget if same color

    if(widget.onSwitchColor != null)
      widget.onSwitchColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.fromLTRB(2, 4, widget.note.edit ? 0 : 6, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Column(
                children: <Widget>[
                  Row(children: widget.actions,),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                    child: widget.note.edit ? _editField() : MarkdownBody(
                      data: widget.note.source,
                      styleSheet: _style(context),
                      onTapLink: (link) async {
                        if (await canLaunch(link)) {
                          await launch(link);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SmallIcon(
                  Icon(
                    Icons.edit,
                    color: widget.note.edit ? Colors.blueAccent : Theme.of(context).iconTheme.color,
                  ),
                  onPressed: _switchToEditMode,
                ),
                if(widget.note.edit) Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                    child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _defaultColor(context),
                            for(NoteColor color in NoteColor.values)
                              _colorSwitcher(color)
                          ],
                        )
                    )
                )
              ],
            )
          ],
        )
    );
  }

  Widget _editField() => TextField(
    maxLines: null,
    minLines: widget.editMinLines,
    keyboardType: TextInputType.multiline,
    controller: _editController,
    focusNode: _focus,
    style: TextStyle(
        fontSize: 18,
        fontFamily: "SourceCodePro"
    ),
    decoration: InputDecoration(
      border: InputBorder.none,
    ),
    onChanged: (source) {
      widget.note.source = source;
    },
  );

  Widget _smallIconButton(
      IconData icon,
      Color color,
      VoidCallback onTap
  ) => SmallIcon(
    Icon(icon, color: color, size: 25),
    onPressed: onTap,
  );

  Widget _colorSwitcher(NoteColor color) => _smallIconButton(
      Icons.invert_colors,
      NoteColorHelper.getMaterialColor(color),
      () {_switchColor(color);}
  );

  Widget _defaultColor(BuildContext context) {
    final theme = Theme.of(context);
    return _smallIconButton(
      Icons.invert_colors_off,
      theme.iconTheme.color,
      () {_removeColor();},
    );
  }

  MarkdownStyleSheet _style(BuildContext context) {
    final theme = MarkdownStyleSheet.fromTheme(Theme.of(context));
    return theme.copyWith(
      blockquoteDecoration: BoxDecoration(
        color: NoteColorHelper.getMaterialColor(widget.note.color)?.shade400
            ?? Theme.of(context).cardColor,
        borderRadius: new BorderRadius.circular(4.0),
      ),
      code: theme.code.copyWith(
          fontFamily: "SourceCodePro"
      ),
      codeblockDecoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: new BorderRadius.circular(4.0)
      ),
    );
  }
}
