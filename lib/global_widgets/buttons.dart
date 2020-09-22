import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

class EditFundderButton extends StatelessWidget {
  EditFundderButton({@required this.onPressed, this.text});
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FundderButton(
        onPressed: this.onPressed,
        backgroundColor: Colors.white,
        borderColor: Colors.grey,
        textColor: Colors.black,
        text: this.text);
  }
}

class PrimaryFundderButton extends StatelessWidget {
  PrimaryFundderButton({@required this.onPressed, this.text});
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FundderButton(
        onPressed: this.onPressed,
        backgroundColor: HexColor('ff6b6c'),
        borderColor: HexColor('ff6b6c'),
        textColor: Colors.white,
        text: this.text);
  }
}

class SecondaryFundderButton extends StatelessWidget {
  SecondaryFundderButton({@required this.onPressed, this.text});
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FundderButton(
        onPressed: this.onPressed,
        backgroundColor: Colors.white,
        borderColor: HexColor('ff6b6c'),
        textColor: HexColor('ff6b6c'),
        text: this.text);
  }
}

class FundderButton extends StatelessWidget {
  FundderButton(
      {@required this.onPressed,
      @required this.backgroundColor,
      @required this.borderColor,
      @required this.textColor,
      this.text});
  final GestureTapCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: EdgeInsets.only(left: 70, right: 70, bottom: 20),
              decoration: BoxDecoration(
                color: this.backgroundColor,
                border: Border.all(color: this.borderColor, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                this.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: this.textColor),
              ),
            ),
            onTap: this.onPressed));
  }
}
