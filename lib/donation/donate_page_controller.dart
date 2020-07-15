import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/donation/money_input_text_widget.dart';
import 'package:fundder/donation/payment_methods.dart';
import 'package:fundder/main.dart';
import 'package:fundder/services/payment_service.dart';
import '../helper_classes.dart';

class DonatePage extends StatefulWidget {
  @override
  final String postData;
  DonatePage({this.postData});

  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  payViaNewCard() async {
    var response =
        await StripeService.payWithNewCard(amount: '777', currency: 'gbp');
    response.success == true
        ? print('twas a success')
        : print('twas not a success');
  }

  Widget moneyInput = moneyInputWidget(
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ','));

  @override
  Widget build(BuildContext context) {
    print('building donate widget');
    final moneyController = MoneyMaskedTextController(
        decimalSeparator: '.', thousandSeparator: ',');
    ThemeData theme = Theme.of(context);
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
        leading: new Container(),
      ),
      body: ListView(
        children: <Widget>[
          Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Thank you for your genorisity. \nPlease enter your donation amount.',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    moneyInputWidget(moneyController)
                  ])),
          ListTile(
              leading: Icon(Icons.add_circle, color: Colors.black),
              title: Text("Pay via new card"),
              onTap: () {
                payViaNewCard();
              }),
          ListTile(
            leading: Icon(Icons.credit_card, color: Colors.black),
            title: Text("Pay via existing cards"),
          )
        ],
      ),
    );
  }
}
