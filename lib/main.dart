import 'package:flutter/material.dart';
import 'package:marknote/ui/pages/home_page.dart';

void main() => runApp(
  MarkNote()
);

class MarkNote extends StatefulWidget {

  final ThemeData dark = ThemeData.dark().copyWith(
      primaryColor: Colors.deepPurple,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple
      ),
      cardColor: Colors.grey.shade800
  );
  final ThemeData light = ThemeData.light().copyWith(
      primaryColor: Colors.deepPurple,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple
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
      home: HomePage(Icon(_indicator), _switchTheme),
      theme: _theme,
      darkTheme: ThemeData.dark(),
    );
  }
}


