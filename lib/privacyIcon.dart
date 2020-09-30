import 'package:flutter/material.dart';
import 'package:fundder/SearchSelectFollowers.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/services/privacyService.dart';

class PrivacyIcon extends StatefulWidget {
  final bool isPrivate;
  final Function onPrivacySettingChanged;
  final String description;
  PrivacyIcon(
      {@required this.isPrivate,
      @required this.onPrivacySettingChanged,
      @required this.description});
  @override
  _PrivacyIconState createState() => _PrivacyIconState();
}

class _PrivacyIconState extends State<PrivacyIcon> {
  bool _isPrivate;
  @override
  void initState() {
    this._isPrivate = widget.isPrivate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("_isPrivate = " + _isPrivate.toString());
    return SwitchListTile(
      activeColor: HexColor('ff6b6c'),
      value: _isPrivate,
      onChanged: (newValue) => {
        setState(() {
          _isPrivate = newValue;
          widget.onPrivacySettingChanged(newValue);
        })
      },
      secondary: Icon(Icons.lock_outline),
      title: Text('Private Mode'),
      subtitle: Text(widget.description),
    );
  }
}

class SelectedFollowersOnlyPrivacyToggle extends StatelessWidget {
  final description =
      "Choose specific people from your followers that you'd like to allow to see this post";
  final String postId;

  SelectedFollowersOnlyPrivacyToggle(this.postId);
  @override
  Widget build(BuildContext context) {
    var postPrivacyToggle = PostPrivacyToggle(postId);
    Function onPrivacySettingChanged = (newVal) {
      if (newVal) {
        Navigator.of(context).pop();
        print("SelectedFollowersOnlyPrivacyToggle selected");
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              var height = MediaQuery.of(context).size.height;
              return Container(
                height: 0.75 * height,
                color: Color(0xFF737373),
                child: Container(
                  child: SearchSelectFollowers(),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                    ),
                  ),
                ),
              );
            });
      } else {
        //code to make post not private
      }
    };
    return FutureBuilder(
      future: postPrivacyToggle.isPrivate(),
      builder: (context, isPrivate) {
        if (isPrivate.hasData) {
          return PrivacyIcon(
            description: description,
            isPrivate: isPrivate.data,
            onPrivacySettingChanged: onPrivacySettingChanged,
          );
        } else {
          return ListTile(
            title: Text('Private Mode'),
            subtitle: Text(description),
            leading: Icon(Icons.lock_outline),
          );
        }
      },
    );
  }
}
