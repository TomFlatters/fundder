import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/donation/money_input_text_widget.dart';
import 'package:fundder/main.dart';
import '../helper_classes.dart';

class DonatePage extends StatefulWidget {
  @override
  final String postData;
  DonatePage({this.postData});

  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  Widget moneyInput = moneyInputWidget(
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ','));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Donate"),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(null),
            )
          ],
        ),
        body: Column(
          children: <Widget>[moneyInput],
        ));
  }
}
