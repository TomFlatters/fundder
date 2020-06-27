import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fundder/test_controller.dart';

class FluroRouter {
  static Router router = Router();
  static Handler _storyhandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewPost(postData: params['id'][0]));
  static void setupRouter() {
    router.define(
      '/story/:id',
      handler: _storyhandler,
    );
  }
}
