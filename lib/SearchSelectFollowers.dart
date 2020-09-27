import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/followers.dart';
import 'package:provider/provider.dart';

class SearchSelectFollowers extends StatefulWidget {
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
                return FollowersSearchSelect(myFollowers);
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

class SelectedProfileRow extends StatelessWidget {
  final List<String> followersSelected;
  SelectedProfileRow(this.followersSelected);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [],
    );
  }
}

class FollowersSearchSelect extends StatefulWidget {
  final List<Map> myFollowers;
  FollowersSearchSelect(this.myFollowers);
  @override
  _FollowersSearchSelectState createState() => _FollowersSearchSelectState();
}

class _FollowersSearchSelectState extends State<FollowersSearchSelect> {
  List<Map> searchedFollowers;
  TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    searchedFollowers = widget.myFollowers;
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gapPadding: 4.0,
                  borderSide: BorderSide(color: HexColor("ff6b6c"), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gapPadding: 4.0,
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                prefixIcon: Icon(Icons.search),
                hintText: 'Search followers...'),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: searchedFollowers.length,
              padding: EdgeInsets.all(12.0),
              itemBuilder: (context, index) {
                var data = searchedFollowers[index];
                return ListTile(
                  title: Text(data.toString()),
                  onTap: () => print(data),
                );
              }),
        )
      ],
    );
  }
}
