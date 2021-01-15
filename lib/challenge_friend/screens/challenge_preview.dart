import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/post_preview.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/image_view.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/description_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/hashtag_input_field.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/isPrivate_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/media_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/money_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/title_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/which_charity_input.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';

class ViewChallenge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final descriptionState =
        Provider.of<DescriptionInputStateManager>(context, listen: false);
    final titleState =
        Provider.of<TitleInputStateManager>(context, listen: false);
    final targetAmountState =
        Provider.of<MoneyInputStateManager>(context, listen: false);
    final mediaState = Provider.of<MediaStateManager>(context, listen: false);
    final charityState =
        Provider.of<CharitySelectionStateManager>(context, listen: false);
    final hashtagState =
        Provider.of<HashtagsStateManager>(context, listen: false);
    final privateStatusState =
        Provider.of<PrivateStatusStateManager>(context, listen: false);
    User _user = Provider.of<User>(context);
    final height = (MediaQuery.of(context).size.height) * 2 / 5;
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future:
            Firestore.instance.collection('users').document(_user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var value = snapshot.data;
            bool isPrivate = false;
            //this state really has no business holding username
            //easter egg to save time soz :(
            privateStatusState.setUsername(value.data['username']);
            User user = User(
                isPrivate: isPrivate,
                uid: _user.uid,
                name: value.data["name"],
                username: value.data['username'],
                email: value.data['email'],
                profilePic: value.data["profilePic"]);
            return PostPreview(
                isPreviewForChallenges: true,
                charity: charityState.charityList[charityState.currentValue],
                authorUid: user != null ? user.uid : '',
                authorUsername: user != null ? user.username : '',
                imageView: ImageView(
                  imageFile: mediaState.imageFile,
                  height: height,
                  width: width,
                ),
                title: titleState.currentValue,
                subtitle: descriptionState.currentValue,
                selected: 0, //to make compatible with legacy code
                targetAmount: targetAmountState.currentValue,
                hashtags: hashtagState.currentValue);
          } else {
            return Loading();
          }
        });
  }
}
