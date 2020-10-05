import 'package:flutter/material.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/choose_visibility.dart';
import 'package:fundder/privacyIcon.dart';

class PrivacySelection extends StatelessWidget {
  final Function onPrivacySettingChanged;
  final Function limitVisibility;
  final bool isPrivate;
  final List selectedFollowers;

  PrivacySelection(
      {@required this.isPrivate,
      @required this.limitVisibility,
      @required this.onPrivacySettingChanged,
      @required this.selectedFollowers});
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          color: Colors.grey[200],
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.white,
            ),
            margin: EdgeInsets.only(top: 10),
          ),
        ),
        Container(
            child: Column(
          children: [
            PrivacyIcon(
                isPrivate: this.isPrivate,
                onPrivacySettingChanged: (newVal) =>
                    this.onPrivacySettingChanged(newVal),
                description:
                    "Posts in Private Mode will only available to followers. This is default for profiles already in Private Mode."),
            ChooseVisibilityAddPost(selectedFollowers, limitVisibility),
          ],
        ))
      ],
    );
  }
}
