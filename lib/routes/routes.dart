import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fundder/other_user_profile.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:fundder/web_pages/test_controller.dart';
import 'package:fundder/comment_view_controller.dart';
import 'package:fundder/donate_page_controller.dart';
import 'package:fundder/add_post_controller.dart';
import 'package:fundder/profile_controller.dart';
import 'package:fundder/edit_profile_controller.dart';

class FluroRouter {
  static Router router = Router();
  static Handler _testHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TestPost(postData: params['id'][0]));
  static Handler _postHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewPost(postData: params['id'][0]));
  static Handler _commentHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CommentPage(postData: params['id'][0]));
  static Handler _donateHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DonatePage(postData: params['id'][0]));
  static Handler _viewOtherProfileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewUser());
  static Handler _editProfileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewPost(postData: params['id'][0]));
  static Handler _addPostHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddPost());

  static void setupRouter() {
    router.define(
      '/share/:id',
      handler: _testHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/post/:id',
      handler: _postHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/post/:id/comments',
      handler: _commentHandler,
    );
    router.define(
      '/post/:id/donate',
      handler: _donateHandler,
    );
    router.define(
      '/username',
      handler: _viewOtherProfileHandler,
    );
    router.define(
      '/account/edit',
      handler: _editProfileHandler,
    );
    router.define(
      '/addpost',
      handler: _addPostHandler,
    );
  }
}
