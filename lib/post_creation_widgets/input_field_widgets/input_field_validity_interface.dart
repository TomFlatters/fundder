import 'package:flutter/cupertino.dart';

abstract class InputFieldValidityChecker {
  /**Returns true if user has inputted a valid entry into this field, otherwise
   * returns false.
   */

  bool get isInputValid;

/**Creates an error dialog if the input isn't valid */
  void createErrorDialog(context);
}
