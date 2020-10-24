import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SearchBar<DocumentSnapshot>(
              searchBarPadding: EdgeInsets.symmetric(horizontal: 20),
              searchBarStyle: SearchBarStyle(
                  backgroundColor: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(10))),
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
              listPadding: EdgeInsets.only(top: 10),
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
                    title: Text(
                      doc.data['username'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/user/' + doc.documentID);
                    },
                  );
                  // if they are searching for posts
                } else {
                  return ListTile(
                    //leading: ProfilePic(doc.data['author'], 40),
                    title: Text("#" + doc.documentID.toString(),
                        style: TextStyle(color: Colors.blueGrey)),
                    subtitle: Text(
                      doc.data['count'].toString() + " challenges",
                    ),
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
