import 'package:flutter/material.dart';
import 'package:fundder/extensions/hover_extensions.dart';

class MenuItem extends StatelessWidget {
  final Widget title;
  final Function press;
  const MenuItem({
    Key key,
    this.title,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: title,
      ),
    ).showCursorOnHover;
  }
}
