import 'package:flutter/material.dart';

class MyselfTile extends StatelessWidget {
  final Color listColor;

  MyselfTile(this.listColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          child: Row(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(
                          color: this.listColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          )),
                      margin: EdgeInsets.all(10.0),
                    )),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                color: listColor,
                height: 10,
                width: 100,
              )
            ],
          ),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            color: listColor,
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 20,
              ),
              Text('Raise money for your own challenge.',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(
                height: 10,
              ),
              Text(
                'This will start raising money in the fund feed immediately after creation.',
                style: TextStyle(
                  fontFamily: 'Founders Grotesk',
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 10,
              )
            ]))
      ],
    );
  }
}

class OthersTile extends StatelessWidget {
  final Color listColor;

  final List<String> titles = ['A challenge for someone else', '', ''];
  final List<String> subtitles = [
    'Create a challenge for someone else to do.',
    'This will be public in the do feed and anyone will be able to accept the challenge.',
    'You can also invite your friends to accept this challenge.'
  ];

  OthersTile(this.listColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: (c, i) => _templateListView(i),
        itemCount: 3,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: 20),
    );
  }

  Widget _templateListView(int index) {
    return Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: index == 0
              ? BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                )
              : index == 2
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    )
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                    ),
        ),
        child: Container(
            margin: EdgeInsets.only(left: 0, right: 0, top: 0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 65,
                  margin:
                      EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 0),
                  child: Row(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            margin: EdgeInsets.only(
                                left: 10, right: 15, top: 0, bottom: 0),
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: ClipRRect(
                                  borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn,
                                    color: this.listColor,
                                  )),
                            )),
                      ),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              titles[index] != ''
                                  ? Row(children: [
                                      Expanded(
                                          child: Text(
                                        titles[index],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Founders Grotesk',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      )),
                                    ])
                                  : Container(),
                              Padding(padding: EdgeInsets.all(1.5)),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Text(
                                      subtitles[index],
                                      style: TextStyle(
                                        fontFamily: 'Founders Grotesk',
                                        fontSize: 14,
                                      ),
                                    ),
                                  )),
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
