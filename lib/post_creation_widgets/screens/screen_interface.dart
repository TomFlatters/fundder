abstract class A_CreationScreen {
  bool _isValidScreen = false;

  /**If all fields shown on this screen are valid, return true otherwise return 
   * false.
   */
  bool get allFieldsValid {
    return _isValidScreen;
  }
}
