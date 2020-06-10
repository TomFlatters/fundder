import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'other_user_profile.dart';

class ViewFollowers extends StatefulWidget {
  @override
  _ViewFollowersState createState() => _ViewFollowersState();
}

class _ViewFollowersState extends State<ViewFollowers> with SingleTickerProviderStateMixin {

  final List<String> entries = <String>['username_abcd', 'username_ultra_long', 'username_uotra_ultra_long'];
  final List<String> buttons = <String>['Follow back', 'Following', 'Following'];
  int selected = -1;
  int charity = -1;

  TabController _tabController;
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
      setState(() {});
      print("called");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("View Followers"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close), 
            onPressed: () => Navigator.of(context).pop(null),
            )
        ],
        leading: new Container(),
      ),
      body: Column(
        children: [Container(height: 50, 
        child:TabBar(
            tabs: [Tab(text: 'Followers'), Tab(text: 'Following')],
            controller: _tabController,
          )
          ), Expanded(child:ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal:10),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[Align(
                        alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            child: AspectRatio(
                            aspectRatio: 1/1,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      "https://i.imgur.com/BoN9kdC.png")
                                )
                              ),
                              margin: EdgeInsets.all(10.0),            
                            )
                          ),
                        onTap: (){
                          Navigator.of(context).push(_viewUser());
                        },
                        )
                      ), Expanded(child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${entries[index%3]}'
                        )
                      )
                      ), Container(
                        width: 110,
                        child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          child: Container(
                            width: 110,
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Text(
                              "${buttons[index%3]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            onTap: () {final snackBar = SnackBar(content: Text("Follow thing pressed"));
                          Scaffold.of(context).showSnackBar(snackBar);},
                        )
                        )
                      ),
                      ],
                    ),
                  ),
                ],
              )
            )
          );
        },
        separatorBuilder: (BuildContext context, int index){
          return SizedBox(
            height: 10,
          );
        },
          )
      ),]
    )
  );
 }
}

Route _viewUser() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewUser(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}