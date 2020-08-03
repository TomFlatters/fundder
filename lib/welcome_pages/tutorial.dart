import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();

  final String uid;
  Tutorial({this.uid});
}

class _TutorialState extends State<Tutorial> {
  int _current = 0;
  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(''),
          actions: <Widget>[
            new IconButton(
                icon: new Text('Next'),
                onPressed: _current == 3
                    ? () {
                        Firestore.instance
                            .collection('users')
                            .document(widget.uid)
                            .updateData({
                          'seenTutorial': true,
                        });
                        Navigator.of(context).pop(setState(() {}));
                      }
                    : () {
                        _carouselController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear);
                      })
          ],
          leading: new Container(),
        ),
        body: CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
            enableInfiniteScroll: false,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            height: MediaQuery.of(context).size.height,
            // autoPlay: false,
          ),
          items: [
            _buildDescription(
                title: 'Welcome',
                subtitle: 'Fundder is a new way of fundraising',
                slideNumber: 1),
            _buildDescription(
                title: 'Do',
                subtitle:
                    'Find ideas for your own fundraisers or challenge friends in the "Do" feed',
                slideNumber: 2),
            _buildDescription(
                title: 'Welcome',
                subtitle:
                    'Donate to active fundraisers or raise money for your own in the "Fund" feed. Help the challeges come to life',
                slideNumber: 3),
            _buildDescription(
                title: 'Done',
                subtitle: 'View completed challenges in the "Done" feed',
                slideNumber: 4),
          ],
        ));
  }

  Widget _buildDescription({String title, String subtitle, int slideNumber}) {
    return Center(
        child: Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: Container(
            margin: EdgeInsets.all(20),
            child: Image.asset('assets/images/tutorial_screens-0' +
                slideNumber.toString() +
                '.png'),
          ),
        ),
        Expanded(
            child: Center(
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 25),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Muli', fontSize: 15),
                  ))
            ],
          ),
        ))
      ],
    ));
  }
}
