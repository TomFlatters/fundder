import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final DateTime when;
  final bool fromMe;
  final String msg;
  Message({
    @required this.when,
    @required this.fromMe,
    @required this.msg,
  });
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
