import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_validity_interface.dart';
import 'package:fundder/shared/constants.dart';
import 'package:provider/provider.dart';

/**Holds the state for DescriptionInputBox */
class DescriptionInputStateManager with InputFieldValidityChecker {
  String _description = "";

  /**Returns the current description entered by the user */
  String get currentValue {
    return _description;
  }

  /**Updates the description value to the new description */
  void updateValue(String newValue) {
    _description = newValue;
  }

  bool get isInputValid {
    return _description.length > 0;
  }

  void createErrorDialog(context) {
    DialogManager().createDialog(
      'Error',
      'You have not written a description for the challenge',
      context,
    );
  }
}

/**UI for inputting the description of the post. A Provider providing 'DescriptionInputStateManager' 
 * must be above this in the widget tree
  */
class DescriptionInputBox extends StatefulWidget {
  @override
  _DescriptionInputBoxState createState() => _DescriptionInputBoxState();
}

class _DescriptionInputBoxState extends State<DescriptionInputBox> {
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DescriptionInputStateManager>(builder: (_, state, __) {
      descriptionController.text = state.currentValue;
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                'Description',
                style: TextStyle(
                  fontFamily: 'Founders Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: textInputDecoration.copyWith(
                  hintText: 'As it says on the tin... '),
              onChanged: (newDescription) {
                state.updateValue(newDescription);
              },
            ),
          ]);
    });
  }
}
