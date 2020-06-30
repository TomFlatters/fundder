import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fundder/other_user_profile.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:fundder/comment_view_controller.dart';
import 'package:fundder/donate_page_controller.dart';
import 'package:fundder/add_post_controller.dart';
import 'package:fundder/do_challenge_detail.dart';
import 'package:fundder/challenge_steps_view.dart';
import 'package:fundder/view_followers_controller.dart';
import 'package:fundder/profile_controller.dart';
import 'package:fundder/edit_profile_controller.dart';

class FluroRouter {
  static Router router = Router();
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
          ViewUser(
            uid: 'hkKCaiUeWUYhKwRLA0zDOoEuKxW2',
          ));
  static Handler _followersHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewFollowers());
  static Handler _editProfileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          EditProfile());
  static Handler _addPostHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddPost());
  static Handler _challengeDetailHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ChallengeDetail(challengeId: params['id'][0]));
  static Handler _challengeStepsHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          StepsPage(challengeId: params['id'][0]));

  static void setupRouter() {
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
      '/username/followers',
      handler: _followersHandler,
    );
    router.define(
      '/account/edit',
      handler: _editProfileHandler,
    );
    router.define(
      '/addpost',
      handler: _addPostHandler,
    );
    router.define(
      '/challenge/:id',
      handler: _challengeDetailHandler,
    );
    router.define(
      '/challenge/:id/steps',
      handler: _challengeStepsHandler,
    );
  }
}
