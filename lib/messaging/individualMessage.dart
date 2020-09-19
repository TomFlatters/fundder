import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

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
              elevation: 0,
              shape: StadiumBorder(),
              color: fromMe ? HexColor('ff6b6c') : Colors.grey[200],
              child: ListTile(
                  title: Text(
                    msg,
                    style:
                        TextStyle(color: fromMe ? Colors.white : Colors.black),
                  ),
                  trailing: Text(
                    latestMessageTimestamp,
                    style:
                        TextStyle(color: fromMe ? Colors.white : Colors.black),
                  ))),
        ));
  }
}
