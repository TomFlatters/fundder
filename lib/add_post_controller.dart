import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'view_post_controller.dart';
import 'home_widget.dart' as main;

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {

  final List<String> whoDoes = <String>["A specific person",'Myself','Anyone'];
  final List<String> charities = <String>["Cancer Research",'British Heart Foundation','Oxfam'];
  int selected = -1;
  int charity = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close), 
            onPressed: () => Navigator.of(context).pop(null),
            )
        ],
        leading: new Container(),
      ),
      body:
        ListView(
          children: <Widget>[
            Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('What is the challenge:',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a title'
                    )
                  )
                ])
            ), Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('Who do I want to do it',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shrinkWrap: true,
                    itemCount: whoDoes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: (){
                          selected=index;
                          setState(() {
                            
                          });
                          },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 15,
                              margin: EdgeInsets.symmetric(horizontal:10),
                              child: Builder(
                                builder: (context) {if(selected==index){
                                return Image.asset('assets/images/bullet_full.png');
                              }else{
                                return Image.asset('assets/images/bullet_outline.png');
                              }
                                }),
                            ), Text(
                              '${whoDoes[index]}'
                            )
                          ],
                          )
                      );
                    },
                    separatorBuilder: (BuildContext context, int index){
                      return SizedBox(
                        height: 10,
                      );
                    },
                  )
                ],)
            ), Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('What is the target amount:',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Amount in £'
                    )
                  )
                ])
            ), Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('Who do I want to do it',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shrinkWrap: true,
                    itemCount: charities.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: (){
                          charity=index;
                          setState(() {
                            
                          });
                          },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 15,
                              margin: EdgeInsets.symmetric(horizontal:10),
                              child: Builder(
                                builder: (context) {if(charity==index){
                                return Image.asset('assets/images/bullet_full.png');
                              }else{
                                return Image.asset('assets/images/bullet_outline.png');
                              }
                                }),
                            ), Text(
                              '${charities[index]}'
                            )
                          ],
                          )
                      );
                    },
                    separatorBuilder: (BuildContext context, int index){
                      return SizedBox(
                        height: 10,
                      );
                    },
                  )
                ],)
            ),Container(
              height: 50,
                child: FlatButton(child: Text('Submit', style: TextStyle(color: Colors.white),), 
                onPressed: (){
                  Navigator.of(context).pushReplacement(_viewPost());}),
                color: HexColor("EB8258"),
                width: MediaQuery.of(context).size.width,
              ),
          ], 
          ),
    );
  }
}


Route _viewPost() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewPost(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}