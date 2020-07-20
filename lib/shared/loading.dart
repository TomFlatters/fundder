import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/animation.dart';

class Loading extends StatefulWidget {
  Loading({Key key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController _controller;
  int phase = 1;
  List sizeList = [50.0, 75.0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 750), vsync: this);
    animation = Tween<double>(begin: 50, end: 100).animate(_controller)
      ..addListener(() {
        setState(() {
          /*if (status == AnimationStatus.completed) {            
          _controller.reverse();            
        } else if (status == AnimationStatus.dismissed) {            
          _controller.forward();            
        }*/
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                // Use the properties stored in the State class.
                width: animation.value,
                height: animation.value,
                child: Image.asset('assets/images/fundder_loading.png'),
              ),
              // Define how long the animation should take.
              // Provide an optional curve to make the animation feel smoother.
            )), /*SpinKitChasingDots(
                color: Color(0xffA3D165),
                size: 50.0,
            ),*/
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
