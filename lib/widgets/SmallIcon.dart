import 'package:flutter/material.dart';

class SmallIcon extends StatelessWidget {

  final Icon icon;
  final VoidCallback onPressed;

  const SmallIcon(this.icon, {Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: CircleBorder(),
      child: icon,
      onTap: onPressed,
    );
  }
}
