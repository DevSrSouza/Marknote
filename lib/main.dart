import 'package:flutter/material.dart';
import 'package:marknote/helpers/note_helper.dart';
import 'package:marknote/provider/notes_provider.dart';
import 'package:marknote/ui/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MarkNote()
);

class MarkNote extends StatefulWidget {

  static final purple = Color(0xFF512DA8);

  final ThemeData dark = ThemeData.dark().copyWith(
      primaryColor: purple,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: purple,
        foregroundColor: Colors.white
      ),
      cardColor: Colors.grey.shade800,
      iconTheme: IconThemeData(
        color: Colors.grey
      )
  );
  final ThemeData light = ThemeData.light().copyWith(
      primaryColor: purple,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: purple
      ),
      iconTheme: IconThemeData(
          color: Colors.grey
      )
  );

  @override
  _MarkNoteState createState() => _MarkNoteState();
}

class _MarkNoteState extends State<MarkNote> {

  var _isDark = true;
  var _theme;
  var _indicator = Icons.brightness_5;

  @override
  void initState() {
    super.initState();

    if(_theme == null) _theme = widget.dark;
  }

  void _switchTheme() {
    setState(() {
      if (_isDark) {
        _theme = widget.light;
        _indicator = Icons.brightness_3;
      } else {
        _theme = widget.dark;
        _indicator = Icons.brightness_5;
      }
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MarkNote",
      home: ChangeNotifierProvider<NotesProvider>(
          builder: (_) => NotesProvider(),
          child: HomePage(Icon(_indicator), _switchTheme)
      ),
      theme: _theme,
      darkTheme: widget.dark,
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void dispose() {
    NoteHelper().close();
    super.dispose();
  }
}


