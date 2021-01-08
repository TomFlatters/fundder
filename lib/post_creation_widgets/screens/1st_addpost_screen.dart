import 'package:flutter/material.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/description_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_interface.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/media_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/money_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/title_input.dart';
import 'package:fundder/post_creation_widgets/screens/screen_interface.dart';
import 'package:fundder/post_creation_widgets/screens/top_curved_grey_rounded_decor.dart';

class FirstAddPostScreen extends A_CreationScreen {
  bool get allFieldsValid {
    //TODO: to be implemented by logical conjunction of the validity of all input fields.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        GreyGapRounded(),
        MediaUploadBox(),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: TitleInputBox(),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: DescriptionInputBox(),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: MoneyInputField().buildWidget(),
        ),
      ],
    );
  }
}
