import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:fundder/comment_view_controller.dart';
import 'package:fundder/donation/donate_page_controller.dart';
import 'package:fundder/add_post_controller.dart';
import 'package:fundder/do_challenge_detail.dart';
import 'package:fundder/challenge_steps_view.dart';
import 'package:fundder/view_followers_controller.dart';
import 'package:fundder/profile_controller.dart';
import 'package:fundder/edit_profile_controller.dart';
import 'package:fundder/view_template_controller.dart';
import 'package:fundder/feed_controller.dart';
import 'package:fundder/web_pages/feed_web.dart';
import 'package:fundder/web_pages/about_page.dart';
import 'package:fundder/web_pages/login_web.dart';
import 'package:fundder/web_pages/logging_out.dart';
import 'package:fundder/search_controller.dart';
import 'package:fundder/liked_controller.dart';
import 'package:fundder/profile_controller.dart';
import 'package:fundder/web_pages/temparary_upload_page.dart';
import 'package:fundder/upload_proof_controller.dart';

class FluroRouter {
  static Router router = Router();
  static Handler _postHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewPost(postData: params['id'][0]));
  static Handler _templateHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewTemplate(templateData: params['id'][0]));
  static Handler _commentHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CommentPage(postData: params['id'][0]));
  static Handler _donateHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DonatePage(postData: params['id'][0]));
  static Handler _viewOtherProfileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ProfileController(
            uid: params['id'][0],
          ));
  static Handler _followersHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewFollowers(
            uid: params['id'][0],
          ));
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
  static Handler _uploadProofHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          UploadProofScreen(postId: params['id'][0]));

  // Web handlers

  static Handler _feedHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          WebFeed());
  static Handler _aboutHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AboutPage());
  static Handler _webLoginHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginWeb());
  static Handler _loggingOutHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginWeb());
  static Handler _searchHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SearchController());
  static Handler _activityHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LikedController());
  static Handler _profileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ProfileController());
  static Handler _tempAddPostHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TemporaryUpload());

  static void setupRouter() {
    router.define(
      '/template/:id',
      handler: _templateHandler,
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
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/post/:id/donate',
      handler: _donateHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/user/:id',
      handler: _viewOtherProfileHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/user/:id/followers',
      handler: _followersHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/account/edit',
      handler: _editProfileHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/addpost',
      handler: _addPostHandler,
    );
    router.define(
      '/challenge/:id',
      handler: _challengeDetailHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/challenge/:id/steps',
      handler: _challengeStepsHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/post/:id/uploadProof',
      handler: _uploadProofHandler,
      transitionType: TransitionType.fadeIn,
    );

    // Web routes
    router.define(
      '/web/feed',
      handler: _feedHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/about',
      handler: _aboutHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/web/search',
      handler: _searchHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/web/activity',
      handler: _activityHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/web/profile',
      handler: _profileHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/web/login',
      handler: _webLoginHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/web/logging_out',
      handler: _loggingOutHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/web/addpost',
      handler: _tempAddPostHandler,
      transitionType: TransitionType.fadeIn,
    );
  }
}
