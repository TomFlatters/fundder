import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'view_post_controller.dart';
import 'share_post_controller.dart';

class FeedController extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
  final Color color;
  FeedController(this.color);
}

class _FeedState extends State<FeedController> {
  
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];



 @override
 Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feed'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Do'),
              Tab(text: 'Fund'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: Container(
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60,
                      child: Row(
                        children: <Widget>[Align(
                          alignment: Alignment.centerLeft,
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
                          )
                        ), Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Profile ${entries[index]}'
                          )
                        ), Expanded(
                          child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            child: Text(
                            'For Charity ${entries[index]}'
                            )
                          )
                          )
                        ),
                        ],
                      ),
                    ), Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.all(10),
                      child: Text(
                        'I want somebody to do xyzlkklsadfljsdfl jsadfsadf; dsfdfjsladfsljfdsa;dfsa'
                      )
                    ), Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.all(10),
                      child: Text(
                        '£${(index+15)/4} raised of £${index+10} target',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ), Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: LinearPercentIndicator(
                        
                        lineHeight: 7,
                        percent: ((index+15)/4)/(index+10),
                        backgroundColor: HexColor('CCCCCC'),
                        progressColor: HexColor("A3D165"),
                      ),
                      ), Container(
                      height: 30,
                      child: Row(children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            child: Row(
                              children:[
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(0.0), child: Image.asset('assets/images/like.png'),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text('$index',textAlign: TextAlign.left,)
                                  )
                                )
                              ]
                            ),
                            onPressed: (){
                              final snackBar = SnackBar(content: Text("Tap"));
                              Scaffold.of(context).showSnackBar(snackBar);
                            },
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Row(
                              children:[
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(0.0), child: Image.asset('assets/images/comment.png'),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text('$index',textAlign: TextAlign.left,)
                                  )
                                )
                              ]
                            ),
                            onPressed: (){
                              final snackBar = SnackBar(content: Text("Tap"));
                              Scaffold.of(context).showSnackBar(snackBar);
                            },
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Row(
                              children:[
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(0.0), child: Image.asset('assets/images/share.png'),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text('Share',textAlign: TextAlign.left,)
                                  )
                                )
                              ]
                            ),
                            onPressed: () {Navigator.of(context).push(_openShare());},
                          ),
                        )
                      ]
                      ),
                    )
                  ],
                )
              )
            ),
            onTap: () {Navigator.of(context).push(_createRoute());}
            ,);
          },
          separatorBuilder: (BuildContext context, int index){
            return SizedBox(
              height: 10,
            );
          },
        ),
      ),
    );
 }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewPost(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}

Route _openShare() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => SharePost(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}