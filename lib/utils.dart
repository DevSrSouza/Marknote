import 'package:flutter/material.dart';

void removeFocus(BuildContext context) {
  FocusScope.of(context).requestFocus(new FocusNode());
}