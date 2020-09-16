import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Do/do_1.dart';
import 'Do/do_2.dart';
import 'Done/done_1.dart';
import 'Profile/profile_1.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/helper_classes.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorialScreenController extends StatefulWidget {
  final List<Widget> screens;
  final String boolVariable;
  @override
  _TutorialScreenControllerState createState() =>
      _TutorialScreenControllerState();
  TutorialScreenController(this.screens, this.boolVariable);
}

class _TutorialScreenControllerState extends State<TutorialScreenController> {
  int _current = 0;
  CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetAnimationDuration: const Duration(milliseconds: 500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Container(
            height: 400,
            width: 300,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            //margin: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            padding: EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
            child: Column(children: [
              SizedBox(height: 20),
              CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 286,
                    //aspectRatio: 1,
                    onPageChanged: (index, reason) {
                      _changePage();
                      if (mounted) {
                        setState(() {
                          _current = index;
                        });
                      }
                    },
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    // autoPlay: false,
                  ),
                  items: widget.screens),
              Row(
                children: [
                  Expanded(
                    child: _current == 0
                        ? Container()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 28,
                                  color: HexColor('ff6b6c'),
                                ),
                                onPressed: () {
                                  _carouselController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.linear);
                                }),
                          ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                          child: Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                                _current != widget.screens.length - 1
                                    ? 'Next'
                                    : 'Complete',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: HexColor('ff6b6c'))),
                          ),
                          onPressed: _current != widget.screens.length - 1
                              ? () {
                                  _carouselController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.linear);
                                }
                              : () async {
                                  if (widget.boolVariable ==
                                      'allTutorialSeen') {
                                    Navigator.pop(context);
                                  } else {
                                    _tutorialCompleted();
                                    Navigator.pop(context);
                                  }
                                }),
                    ),
                  )
                ],
              )
            ])));
  }

  void _changePage() {
    FocusScope.of(context).unfocus();
  }

  Future _tutorialCompleted() async {
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .updateData({widget.boolVariable: true});
  }
}
