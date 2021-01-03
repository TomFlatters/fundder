import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_interface.dart';
import 'package:fundder/shared/constants.dart';

class MoneyInputField extends InputField {
  String _targetAmount = "0.00";

  bool get isInputValid {
    return double.parse(_targetAmount) >= 2.00;
  }

  StatefulWidget buildWidget() {
    return MoneyInputBox(
      onMoneyChanged: this.onMoneyChanged,
    );
  }

  void onMoneyChanged(String newAmount) {
    this._targetAmount = newAmount;
    print("The validity status of money input field is: $isInputValid");
  }
}

class MoneyInputBox extends StatefulWidget {
  Function onMoneyChanged;
  MoneyInputBox({@required this.onMoneyChanged});
  @override
  _MoneyInputBoxState createState() => _MoneyInputBoxState();
}

class _MoneyInputBoxState extends State<MoneyInputBox> {
  MoneyMaskedTextController moneyController;

  @override
  void initState() {
    super.initState();
    moneyController = MoneyMaskedTextController(
        decimalSeparator: '.', thousandSeparator: ',');

    moneyController.afterChange = (String masked, double raw) {
      widget.onMoneyChanged(masked);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text('My target amount: ',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Founders Grotesk',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
        ),
        Row(children: [
          Text(
            '£',
            style: TextStyle(
                fontWeight: FontWeight.w100,
                fontFamily: 'Founders Grotesk',
                fontSize: 35,
                color: HexColor('ff6b6c')),
          ),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontWeight: FontWeight.w100,
                fontFamily: 'Founders Grotesk',
                fontSize: 35,
                color: Colors.black,
              ),
              controller: moneyController,
              decoration: textInputDecoration.copyWith(hintText: 'Amount in £'),
            ),
          )
        ])
      ],
    );
  }
}
