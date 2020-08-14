import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import 'package:flutter/widgets.dart';

import '../helper_classes.dart';

class FundderThemeBackgrounds {
  FundderThemeBackgrounds._();

  static Widget black = new Container(
    width: double.maxFinite,
    height: double.maxFinite,
    color: Color(0xff0B0B0F),
  );

  static Widget white = new Container(
    width: double.maxFinite,
    height: double.maxFinite,
    color: Color(0xffF9F9FA),
  );
  static Widget fundderRed = new Container(
    width: double.maxFinite,
    height: double.maxFinite,
    color: HexColor('ff6b6c'),
  );
}

class ExistingCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CreditCard(
      cardNumber: "5450 7879 4864 7854",
      cardExpiry: "10/25",
      cardHolderName: "Card Holder",
      cvv: "456",
      bankName: "Axis Bank",
      cardType:
          CardType.masterCard, // Optional if you want to override Card Type
      showBackSide: false,
      frontBackground: CardBackgrounds.black,
      backBackground: CardBackgrounds.white,
      showShadow: true,
    );
  }
}
