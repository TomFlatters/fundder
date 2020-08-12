import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:fundder/comment_view_controller.dart';
import 'package:fundder/donation/donate_page_controller.dart';
import 'package:fundder/add_post_controller.dart';
import 'package:fundder/do_challenge_detail.dart';
import 'package:fundder/challenge_steps_view.dart';
import 'package:fundder/view_followers_controller.dart';
import 'package:fundder/profile_controller.dart';
import 'package:fundder/edit_profile_controller.dart';
import 'package:fundder/feed_controller.dart';
import 'package:fundder/web_pages/feed_web.dart';
import 'package:fundder/web_pages/about_page.dart';
import 'package:fundder/web_pages/login_web.dart';
import 'package:fundder/web_pages/logging_out.dart';
import 'package:fundder/search/search_controller.dart';
import 'package:fundder/liked_controller.dart';
import 'package:fundder/profile_controller.dart';
import 'package:fundder/web_pages/temparary_upload_page.dart';
import 'package:fundder/upload_proof_controller.dart';
import 'package:fundder/welcome_pages/profilepic_setter.dart';
import 'package:fundder/welcome_pages/tutorial.dart';
import 'package:provider/provider.dart';
import 'package:fundder/auth_screens/check_verified.dart';
import 'package:fundder/search/hashtag_feed.dart';

class FluroRouter {
  static Router router = Router();

  static Handler _postHandler =
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    String pid = params['id'][0];
    print(pid);
    //   String noLikes = params['noLikes'][0];
    //   String isLiked = params['isLiked'][0];
    //   String uid = params['uid'][0];
    //   print('/post/{$pid}/{$noLikes}/{$isLiked}/{$uid}' + "LOLLLLL");
    //   LikesModel likesModel = LikesModel(
    //       (isLiked == 'true') ? true : false, int.parse(noLikes),
    //       uid: uid, postId: pid);
    var user = Provider.of<User>(context);
    var databaseServices = DatabaseService(uid: user.uid);
    return FutureBuilder(
      future: databaseServices.getPostById(pid),
      builder: (context, post) {
        if (post.connectionState == ConnectionState.done) {
          var postData = post.data;
          /*if (postData == null) {
            return Container(
                child: Text(
                    "Error retrieving post: either the post does not exist, or your internet is not connected"));
          } else {*/
          return ViewPost(postData);
          //}
        } else {
          return Container();
        }
      },
    );
  });
  static Handler _commentHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CommentPage(pid: params['id'][0]));

  static Handler _donateHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DonatePage(postId: params['id'][0]));
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
  static Handler _profilePicHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ProfilePicSetter(uid: params['id'][0]));
  static Handler _tutorialHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Tutorial(uid: params['id'][0]));
  static Handler _hashtagHandler1 = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          HashtagFeed(params['id'][0], params['id2'][0]));
  static Handler _hashtagHandler2 = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          HashtagFeed(params['id'][0], null));

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
  static Handler _checkVerifiedHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CheckVerified());

  static void setupRouter() {
    router.define(
      '/post/:id', // /:noLikes/:isLiked/:uid',
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

    router.define(
      '/:id/addProfilePic',
      handler: _profilePicHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/:id/tutorial',
      handler: _tutorialHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/:id/verification',
      handler: _checkVerifiedHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      'hashtag/:id/:id2',
      handler: _hashtagHandler1,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      'hashtag/:id',
      handler: _hashtagHandler2,
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
