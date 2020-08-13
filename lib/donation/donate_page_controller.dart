import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/donation/money_input_text_widget.dart';
import 'package:fundder/donation/payment_methods.dart';
import 'package:fundder/main.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/payment_controllers/existingCards.dart';
import 'package:fundder/services/payment_service.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';
import '../helper_classes.dart';

class DonatePage extends StatefulWidget {
  @override
  final String postId;
  DonatePage({this.postId});

  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final moneyController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  Widget moneyInput = moneyInputWidget(
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ','));

  @override
  Widget build(BuildContext context) {
    print('building donate widget');
    final user = Provider.of<User>(context);

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
              onTap: () async {
                print(moneyController.text);
                double amount = double.parse(moneyController.text);
                int amountInPence = (amount * 100).toInt();

                var paymentIntent =
                    await StripeService.initialisePaymentWithNewCard(
                        amount: amountInPence);
                //create a screen to ask user to confirm once again they wish to proceed
                await showConfirmationDialog(paymentIntent, context,
                    amountInPence, user.uid, widget.postId);
              }),
          ListTile(
            leading: Icon(Icons.credit_card, color: Colors.black),
            title: Text("Pay via existing cards"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ExistingCards()));
            },
          )
        ],
      ),
    );
  }
}

//confirmation dialog
Future<void> showConfirmationDialog(
    PaymentIntent paymentIntent, context, amountInPence, uid, postId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      //bool donateClicked = false;
      double amount = amountInPence / 100;
      return AlertDialog(
        title: Text('Confirmation'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("I'd like to donate £" + amount.toString()),
              //List just in case we wish to add more things in the future
            ],
          ),
        ),
        actions: <Widget>[
          ConfirmDonation(paymentIntent, uid, postId, amount),
          FlatButton(
            child: Text('Exit'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//a stateful donate button that confirms payment
class ConfirmDonation extends StatefulWidget {
  final PaymentIntent paymentIntent;
  final String uid;
  final String postId;
  final double amount;
  ConfirmDonation(this.paymentIntent, this.uid, this.postId, this.amount);
  @override
  _ConfirmDonationState createState() => _ConfirmDonationState();
}

class _ConfirmDonationState extends State<ConfirmDonation> {
  bool hasClicked = false;
  @override
  Widget build(BuildContext context) {
    if (!hasClicked) {
      return FlatButton(
        child: Text("Donate"),
        onPressed: () {
          print("Stateful donate button clicked");
          setState(() {
            hasClicked = true;
          });
        },
      );
    } else {
      return FutureBuilder(
        future: StripeService.confirmPayment(widget.paymentIntent),
        builder: (context, confirmingPayment) {
          if (confirmingPayment.connectionState == ConnectionState.done) {
            var response = confirmingPayment.data;
            if (response.success) {
              print("twas a success");
              PaymentBookKeepingService.userDonatedToPost(
                  widget.uid, widget.postId, widget.amount);
              return Text("Success");
            } else {
              print("twas not a success");
              return Text("Payment failed");
            }
          } else {
            return Text("Loading");
          }
        },
      );
    }
  }
}
