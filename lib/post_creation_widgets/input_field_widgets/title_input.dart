import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_validity_interface.dart';
import 'package:fundder/shared/constants.dart';
import 'package:provider/provider.dart';

/**Holds the state for TitleInputBox */
class TitleInputStateManager with InputFieldValidityChecker {
  String _title = "";

  /**Returns the current title entered by the user */
  String get currentValue {
    return _title;
  }

  /**Updates the title value to the new description */
  void updateValue(String newValue) {
    _title = newValue;
  }

  bool get isInputValid {
    return _title.length > 0;
  }

  void createErrorDialog(context) {
    DialogManager().createDialog(
      'Error',
      'You have not written a title for this challenge',
      context,
    );
  }
}

/**UI for inputting the title of a post. A Provider providing 'TitleInputStateManager' 
 * must be above this in the widget tree.
 */
class TitleInputBox extends StatefulWidget {
  @override
  _TitleInputBoxState createState() => _TitleInputBoxState();
}

class _TitleInputBoxState extends State<TitleInputBox> {
  final titleController = TextEditingController();
  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TitleInputStateManager>(builder: (_, state, __) {
      titleController.text = state.currentValue;
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontFamily: 'Founders Grotesk',
                      ),
                      children: [
                    TextSpan(
                        text: 'Title of Challenge ',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    TextSpan(
                        text: 'maximum 80 characters',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontSize: 12,
                        ))
                  ])),
            ),
            TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(80),
              ],
              controller: titleController,
              decoration: textInputDecoration.copyWith(
                hintText:
                    'I will shop with just my underwear at Sainsbury\'s *for charity* :))',
              ),
              onChanged: (newTitle) {
                state.updateValue(newTitle);
              },
            ),
          ]);
    });
  }
}
