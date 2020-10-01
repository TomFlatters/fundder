import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/SearchSelectFollowers.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/services/followers.dart';
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
  final String postId;

  SelectedFollowersOnlyPrivacyToggle(this.postId);
  @override
  Widget build(BuildContext context) {
    var postPrivacyToggle = PostPrivacyToggle(postId);

    return FutureBuilder(
      future: postPrivacyToggle.isPrivate(),
      builder: (context, isPrivate) {
        if (isPrivate.hasData) {
          Function onPrivacySettingChanged = () {
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
                      child: SearchSelectFollowers(postId),
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
          };
          var map = isPrivate.data;
          var selectedFollowers = map["selectedViewers"];
          bool hasSelectedFollowers = (selectedFollowers != null)
              ? (selectedFollowers.length > 0)
              : false;

          return (hasSelectedFollowers && map["isPrivate"])
              ? (VisibilityChosenIcon(selectedFollowers, postId))
              : ListTile(
                  title: Text("Choose Visibility"),
                  subtitle: Text(
                      "Tap to choose specific people who can view this post"),
                  leading: Icon(Icons.people),
                  onTap: onPrivacySettingChanged,
                );
        } else {
          return ListTile(
            title: Text('Choose Visibility'),
            subtitle:
                Text("Tap to choose specific people who can view this post"),
            leading: Icon(Icons.people),
          );
        }
      },
    );
  }
}

class VisibilityChosenIcon extends StatelessWidget {
  final List ids;
  final String postId;
  VisibilityChosenIcon(this.ids, this.postId);
  Future<List<Map>> _unames() async {
    List<Map> res = await Future.wait(ids.map((id) async {
      var map = {};
      map['username'] = await GeneralFollowerServices.mapIDtoName(id);
      map['uid'] = id;
      print("in map and this is the username ${map['username']}");
      return map;
    }));
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _unames(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var unames = snapshot.data;
          return ListTile(
            leading: Icon(Icons.people),
            title: Text('Choose Visibility'),
            subtitle: Text(
                "This post is only viewable to certain people. Tap to see who can view this post."),
            onTap: () {
              //code to see screen of users
              //pass list of uname maps
              Navigator.of(context).pop();
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    var height = MediaQuery.of(context).size.height;
                    return Container(
                        height: 0.6 * height,
                        color: Color(0xFF737373),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                              ),
                            ),
                            child: SearchSelectFollowers(postId)));
                  });
            },
          );
        } else {
          return ListTile(
            title: Text('Choose Visibility'),
            subtitle: Text(
                'You\'ve already selected the private audience for this post'),
            leading: Icon(Icons.people),
          );
        }
      },
    );
  }
}

/*

widget to display a list of followers given a list of user maps with 'username' and 'uid' as keys per map 
Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                height: 30,
                                child: Text(
                                  "Selected Viewers",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: unames.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return (unames[index] != null)
                                        ? ListTile(
                                            leading: ProfilePic(
                                                unames[index]['uid'], 40),
                                            title: Text(unames[index]
                                                    ['username']
                                                .toString()),
                                            onTap: () => Navigator.pushNamed(
                                                context,
                                                '/user/' +
                                                    unames[index]['uid']),
                                          )
                                        : Text("Could not load user...");
                                  },
                                ),
                              )
                            ],
                          ),

*/
