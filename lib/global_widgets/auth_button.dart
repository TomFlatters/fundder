import 'package:flutter/material.dart';

class AuthFundderButton extends StatelessWidget {
  AuthFundderButton(
      {@required this.onPressed,
      @required this.backgroundColor,
      @required this.borderColor,
      @required this.textColor,
      @required this.text,
      @required this.buttonIconData,
      @required this.iconColor});
  final GestureTapCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;
  final IconData buttonIconData;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: GestureDetector(
            child: Container(
                decoration: BoxDecoration(
                  color: this.backgroundColor,
                  border: Border.all(color: this.borderColor, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    child: Icon(
                      this.buttonIconData,
                      color: this.iconColor,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        this.text,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: this.textColor),
                      ),
                    ),
                  ),
                ])),
            onTap: this.onPressed));
  }
}
