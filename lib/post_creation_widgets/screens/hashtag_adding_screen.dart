import 'package:flutter/cupertino.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/hashtag_input_field.dart';
import 'package:fundder/post_creation_widgets/screens/screen_interface.dart';

class HashtaggingScreen extends A_CreationScreen {
  bool get allFieldsValid {
    //TODO: implement this
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return HashtagsInput();
  }
}
