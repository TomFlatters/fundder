import 'package:flutter/material.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/description_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/media_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/money_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/title_input.dart';
import 'package:fundder/post_creation_widgets/screens/screen_interface.dart';
import 'package:fundder/post_creation_widgets/screens/top_curved_grey_rounded_decor.dart';

class FirstAddPostScreen extends A_CreationScreen {
  bool get allFieldsValid {
    //to be implemented by ligical conjunction of the validity of all screens
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        GreyGapRounded(),
        MediaInputField().buildWidget(),
        SizedBox(height: 25),
        TitleInputField().buildWidget(),
        SizedBox(
          height: 25,
        ),
        DescriptionInputField().buildWidget(),
        SizedBox(height: 25),
        MoneyInputField().buildWidget(),
      ],
    );
  }
}
