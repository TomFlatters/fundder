import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:fundder/web_pages/test_controller.dart';

class FluroRouter {
  static Router router = Router();
  static Handler _testhandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TestPost(postData: params['id'][0]));
  static Handler _posthandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewPost(postData: params['id'][0]));
  static void setupRouter() {
    router.define(
      '/share/:id',
      handler: _testhandler,
    );
    router.define(
      '/post/:id',
      handler: _posthandler,
    );
  }
}
