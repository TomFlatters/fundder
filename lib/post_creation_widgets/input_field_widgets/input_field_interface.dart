import 'package:flutter/cupertino.dart';

abstract class InputField {
  /**Returns true if user has inputted a valid entry into this field, otherwise
   * returns false.
   */

  bool get isInputValid;

/**Create the stateful widget ui */
  StatefulWidget buildWidget();
}
