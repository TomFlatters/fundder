import 'package:flutter/cupertino.dart';

abstract class A_CreationScreen extends StatelessWidget {
  /**If all fields shown on this screen are valid, return true otherwise return 
   * false.
   */
  bool get allFieldsValid;
}
