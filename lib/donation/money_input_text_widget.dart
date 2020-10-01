import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/shared/constants.dart';

Widget moneyInputWidget(MoneyMaskedTextController moneyController) {
  return Row(children: [
    Text(
      '£',
      style: TextStyle(
        fontWeight: FontWeight.w100,
        fontFamily: 'Founders Grotesk',
        fontSize: 45,
      ),
    ),
    Expanded(
        child: TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontWeight: FontWeight.w100,
              fontFamily: 'Founders Grotesk',
              fontSize: 45,
            ),
            controller: moneyController,
            decoration: textInputDecoration.copyWith(hintText: 'Amount in £'))),
  ]);
}
