import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../web_pages/web_menu.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../helper_classes.dart';
import '../search/search_descriptor.dart';

class SearchController extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
  SearchController();
}

class _SearchState extends State<SearchController>
    with SingleTickerProviderStateMixin {
  String uid = '123';
  TabController _tabController;
  final SearchBarController<DocumentSnapshot> _searchBarController =
      SearchBarController();
  final List searchType = ["#", "users: "];
  SearchBar searchBar;
  final List trending = ['trending 1', 'trending 2', 'trending 3'];

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    //setState(() {});
    if (_tabController.indexIsChanging) {
      _searchBarController.replayLastSearch();
    }
    //print("called");
  }

  // Call search function here. search is the term to be searched.
  Future<List<DocumentSnapshot>> search(String search) async {
    search = search.toLowerCase();
    if (_tabController.index == 0) {
      return DatabaseService(uid: uid).usersContainingString(search);
    } else {
      return DatabaseService(uid: uid).hashtagsContainingString(search);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null && kIsWeb == true) {
      Future.microtask(() => Navigator.pushNamed(context, '/web/login'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Neue Haas Unica',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
      return Scaffold(
        body: SafeArea(
          child: Column(children: [
            kIsWeb == true ? WebMenu(2) : Container(),
            Expanded(
              child: SearchBar<DocumentSnapshot>(
                searchBarPadding: EdgeInsets.symmetric(horizontal: 20),
                searchBarController: _searchBarController,
                header: DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: TabBar(
                    tabs: [Tab(text: 'Users'), Tab(text: 'Hashtags')],
                    controller: _tabController,
                  ),
                ),
                onCancelled: () {
                  FocusScope.of(context).unfocus();
                },
                hintText: _tabController.index == 0
                    ? 'search accounts'
                    : 'search hashtags',
                onSearch: search,
                emptyWidget: SearchDescriptor(),
                minimumChars: 0,
                onItemFound: (DocumentSnapshot doc, int index) {
                  // if they are searching for users
                  if (_tabController.index == 0) {
                    return ListTile(
                      leading: ProfilePicFromUrl(doc.data['profilePic'], 40),
                      title: Text(doc.data['username']),
                      onTap: () {
                        Navigator.pushNamed(context, '/user/' + doc.documentID);
                      },
                    );
                    // if they are searching for posts
                  } else {
                    return ListTile(
                      //leading: ProfilePic(doc.data['author'], 40),
                      title: Text("#" + doc.documentID.toString()),
                      subtitle:
                          Text(doc.data['count'].toString() + " challenges"),
                      onTap: () {
                        Navigator.pushNamed(
                            context,
                            '/hashtag/' +
                                doc.documentID.toString() +
                                '/' +
                                doc.data['count'].toString());
                      },
                    );
                  }
                },
              ),
            ),
          ]),
        ),
      );
    }
  }
}
