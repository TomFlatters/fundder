import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_interface.dart';
import 'package:fundder/shared/constants.dart';
import 'package:provider/provider.dart';

// class MoneyInputField extends InputField {
//   String _targetAmount = "0.00";

//   bool get isInputValid {
//     return double.parse(_targetAmount) >= 2.00;
//   }

//   StatefulWidget buildWidget() {
//     return MoneyInputBox(
//       onMoneyChanged: this.onMoneyChanged,
//     );
//   }

//   void onMoneyChanged(String newAmount) {
//     this._targetAmount = newAmount;
//     print("The validity status of money input field is: $isInputValid");
//   }
// }

class MoneyInputStateManager {
  String _targetAmount = "0.00";

  /**Returns the current amount entered by the user or 0.00 if nothing
   * entered */
  String get currentValue {
    return _targetAmount;
  }

  /**Updates the target amount to 'newValue' */
  void updateValue(String newValue) {
    _targetAmount = newValue;
  }
}

/**UI for entering the target amount of money. A Provider providing 
 * 'MoneyInputStateManager' must be above the widget tree.
 */
class MoneyInputBox extends StatefulWidget {
  @override
  _MoneyInputBoxState createState() => _MoneyInputBoxState();
}

class _MoneyInputBoxState extends State<MoneyInputBox> {
  MoneyMaskedTextController moneyController;

  @override
  void dispose() {
    moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyInputStateManager>(
      builder: (_, state, __) {
        moneyController = MoneyMaskedTextController(
            decimalSeparator: '.', thousandSeparator: ',');

        moneyController.afterChange = (String masked, double raw) {
          state.updateValue(masked);
        };

        moneyController.text = state.currentValue;
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
                  decoration:
                      textInputDecoration.copyWith(hintText: 'Amount in £'),
                ),
              )
            ])
          ],
        );
      },
    );
  }
}
