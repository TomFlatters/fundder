import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Fund/fund_1.dart';
import 'Fund/fund_2.dart';
import 'package:fundder/global_widgets/buttons.dart';

class TutorialScreenController extends StatefulWidget {
  @override
  _TutorialScreenControllerState createState() =>
      _TutorialScreenControllerState();
}

class _TutorialScreenControllerState extends State<TutorialScreenController> {
  int _current = 0;
  CarouselController _carouselController = CarouselController();
  List<Widget> _fundScreens = [Fund1(), Fund2()];
  List<Widget> _doScreens = [Fund1()];

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
            padding: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
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
                  items: _fundScreens),
              SecondaryFundderButton(
                onPressed: () {
                  if (_current == _fundScreens.length - 1) {
                    Navigator.pop(context);
                  } else {
                    _carouselController.nextPage();
                  }
                },
                text: 'Next',
              ),
            ])));
  }

  void _changePage() {
    FocusScope.of(context).unfocus();
  }
}
