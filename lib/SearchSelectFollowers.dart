import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/post_preview.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/services/privacyService.dart';
import 'package:provider/provider.dart';

/**Scaffold to hold search bar for followers, with the list of followers preloaded */
class SearchSelectFollowers extends StatefulWidget {
  List alreadySelectedFollowers = [];
  final postId;
  SearchSelectFollowers(this.postId, {this.alreadySelectedFollowers});
  @override
  _SearchSelectFollowersState createState() => _SearchSelectFollowersState();
}

class _SearchSelectFollowersState extends State<SearchSelectFollowers> {
  List<String> followersSelected = [];

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    return Container(
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
            future: GeneralFollowerServices.unamesFollowingUser(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(
                    "Building Search Bar. Have loaded the usernames follwing the user. \n");
                print("They are " + snapshot.data.toString());
                List<Map> myFollowers = snapshot.data;
                return FollowersSearchSelect(
                  myFollowers,
                  widget.postId,
                  alreadySelectedFollowers: widget.alreadySelectedFollowers,
                );
              } else {
                return Container(
                  child: Center(
                    child: Text("Loading..."),
                  ),
                );
              }
            }));
  }
}

/**Custom search bar for followers. */
class FollowersSearchSelect extends StatefulWidget {
  final List<Map> myFollowers;
  final String postId;

  List alreadySelectedFollowers = [];
  FollowersSearchSelect(this.myFollowers, this.postId,
      {this.alreadySelectedFollowers});
  @override
  _FollowersSearchSelectState createState() => _FollowersSearchSelectState();
}

class _FollowersSearchSelectState extends State<FollowersSearchSelect> {
  List selectedFollowers;
  List<Map> searchedFollowers;
  TextEditingController _textController = TextEditingController();
  PostPrivacyToggle postPrivacyToggle;
  @override
  void initState() {
    postPrivacyToggle = PostPrivacyToggle(widget.postId);
    searchedFollowers = widget.myFollowers;
    selectedFollowers = (widget.alreadySelectedFollowers == null)
        ? []
        : widget.alreadySelectedFollowers;
    _textController.addListener(() {
      if (_textController.text.isEmpty) {
        setState(() {
          searchedFollowers = widget.myFollowers;
        });
      } else {
        onTextChanged(_textController.text);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  onTextChanged(String searchTxt) {
    print("text field changed");
    setState(() {
      print("searching text is: ${searchTxt}");
      var searchLowerCase = searchTxt.toLowerCase();
      var filterFunc = (Map followerMap) =>
          followerMap["username"].toLowerCase().contains(searchLowerCase) ==
          true;
      var res = widget.myFollowers.where(filterFunc).toList();
      searchedFollowers = res;
      print("printing results of followers search " + res.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    return Column(
      children: <Widget>[
        Container(
          //this is the title container
          child: Row(
            children: [
              IconButton(
                icon: Icon(AntDesign.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  "Choose People",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 40,
                child: (selectedFollowers.length > 0)
                    ? IconButton(
                        icon: Icon(AntDesign.check),
                        onPressed: () async {
                          var uidPlusMe = selectedFollowers;
                          if (!selectedFollowers.contains(user.uid)) {
                            uidPlusMe.add(user.uid);
                          }
                          await postPrivacyToggle
                              .makeAvailableToSpecificPeople(uidPlusMe);
                          Navigator.of(context).pop();
                        },
                      )
                    : Container(),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 15),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    /*fillColor: Colors.grey[200],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    gapPadding: 4.0,
                    //borderSide: BorderSide(color: HexColor("ff6b6c"), width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    gapPadding: 4.0,
                    //borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),*/
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    focusColor: Colors.grey,
                    fillColor: Colors.grey,
                    hoverColor: Colors.grey,
                    hintText: 'Search followers...'),
              ),
            ),
          ),
        ),
        (selectedFollowers.length > 0)
            ? Container(
                child: SelectedFollowersRow(selectedFollowers),
                height: 50,
              )
            : Container(
                height: 0,
              ),
        Expanded(
          child: ListView.builder(
              itemCount: searchedFollowers.length,
              padding: EdgeInsets.all(12.0),
              itemBuilder: (context, index) {
                var data = searchedFollowers[index];
                var followerId = data["uid"] as String;
                followerSelected(bool newVal) {
                  if (newVal) {
                    //i.e. this follower has been selected
                    setState(() {
                      selectedFollowers.add(followerId);
                      print(
                          "The followers selected so far are: ${selectedFollowers.toString()}");
                    });
                  } else {
                    setState(() {
                      selectedFollowers.remove(data["uid"]);
                      print(
                          "The followers selected so far are: ${selectedFollowers.toString()}");
                    });
                  }
                }

                return FollowerListTile(
                  data,
                  followerSelected,
                  currentlySelected: selectedFollowers.contains(data['uid']),
                  key: UniqueKey(),
                );
              }),
        )
      ],
    );
  }
}

class SelectedFollowersRow extends StatelessWidget {
  final List selectedFollowersIds;
  SelectedFollowersRow(this.selectedFollowersIds);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: selectedFollowersIds.map((id) => ProfilePic(id, 40)).toList(),
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class FollowerListTile extends StatelessWidget {
  final bool currentlySelected;
  final Map follower;
  final Function selectProfilePic;
  FollowerListTile(this.follower, this.selectProfilePic,
      {@required this.currentlySelected, Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    String followerId = follower["uid"];
    String followerUserName = follower["username"];
    return CheckboxListTile(
      secondary: ProfilePic(followerId, 40),
      value: currentlySelected,
      title: Text(
        followerUserName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      activeColor: HexColor("ff6b6c"),
      onChanged: (val) {
        selectProfilePic(val);
        // isSelected = val;
      },
    );
  }
}
