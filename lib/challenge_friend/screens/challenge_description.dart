import 'package:flutter/material.dart';
import 'package:fundder/challenge_friend/screen_widgets/challenge_photo_uplaod.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/description_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/money_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/title_input.dart';
import 'package:fundder/post_creation_widgets/screens/top_curved_grey_rounded_decor.dart';

/**UI for inputting title, description, target amount and photo 
 * associated with the challenge.
 */
class ChallengeDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        GreyGapRounded(),
        ChallengePhotoUploadBox(),
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
          child: MoneyInputBox(),
        ),
      ],
    );
  }
}
