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
    String latestMessageTimestamp;

    zeroFy(n) => (n < 10) ? ("0${n}") : n.toString();

    latestMessageTimestamp = (zeroFy(when.hour) + ":" + zeroFy(when.minute));

    return Container(
        alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width / 3 * 2,
          child: Card(
              shape: StadiumBorder(),
              child: ListTile(
                  title: Text(msg), trailing: Text(latestMessageTimestamp))),
        ));
  }
}
