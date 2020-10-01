import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

class MiniEditFundderButton extends StatelessWidget {
  MiniEditFundderButton({@required this.onPressed, this.text});
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return MiniFundderButton(
        onPressed: this.onPressed,
        backgroundColor: Colors.white,
        borderColor: Colors.grey,
        textColor: Colors.grey[800],
        text: this.text);
  }
}

class MiniPrimaryFundderButton extends StatelessWidget {
  MiniPrimaryFundderButton({@required this.onPressed, this.text});
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return MiniFundderButton(
        onPressed: this.onPressed,
        backgroundColor: HexColor('ff6b6c'),
        borderColor: HexColor('ff6b6c'),
        textColor: Colors.white,
        text: this.text);
  }
}

class MiniSecondaryFundderButton extends StatelessWidget {
  MiniSecondaryFundderButton({@required this.onPressed, this.text});
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return MiniFundderButton(
        onPressed: this.onPressed,
        backgroundColor: Colors.white,
        borderColor: Colors.grey,
        textColor: Colors.grey,
        text: this.text);
  }
}

class MiniFundderButton extends StatelessWidget {
  MiniFundderButton(
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
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(top: 5, bottom: 2, left: 5, right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: this.borderColor, width: 1),
            color: this.backgroundColor),
        child: Center(
          child: Text(
            this.text,
            style: TextStyle(color: this.textColor, fontSize: 14),
          ),
        ),
      ),
      onTap: this.onPressed,
    );
  }
}
