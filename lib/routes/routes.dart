import 'package:fluro/fluro.dart';
import 'package:fluro/src/router.dart' as Router;
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:fundder/comment_view_controller.dart';
import 'package:fundder/donation/donate_page_controller.dart';
import 'package:fundder/post_creation_widgets/add_post_controller.dart';
import 'package:fundder/do_challenge_detail.dart';
import 'package:fundder/challenge_steps_view.dart';
import 'package:fundder/profile_screens/view_followers_controller.dart';
import 'package:fundder/profile_screens/edit_profile_controller.dart';
import 'package:fundder/post_creation_widgets/upload_proof_controller.dart';
import 'package:fundder/welcome_pages/profilepic_setter.dart';
import 'package:fundder/welcome_pages/tutorial.dart';
import 'package:provider/provider.dart';
import 'package:fundder/auth_screens/check_verified.dart';
import 'package:fundder/search/hashtag_feed.dart';
import 'package:fundder/charity_view_controller.dart';

import 'package:fundder/post_widgets/view_likers_controller.dart';

import 'package:fundder/messaging/chat_room.dart';
import 'package:fundder/profile_screens/user_loader.dart';

class FluroRouter {
  static Router.Router router = Router.Router();
  // static Handler _postHandler = Handler(
  //     handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
  //         ViewPost(postData: params['id'][0]));

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
    var databaseServices = DatabaseService(uid: "123");
    if (user != null) {
      databaseServices = DatabaseService(uid: user.uid);
    }
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
  static Handler _chatRoomHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ChatRoom(params['uid'][0], params['username'][0]));
  static Handler _commentHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CommentPage(pid: params['id'][0]));

  static Handler _charityHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CharityView(charityId: params['id'][0]));

  static Handler _donateHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DonatePage(postId: params['id'][0]));
  static Handler _viewOtherProfileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          UserLoader(
            uid: params['id'][0],
          ));
  static Handler _followersHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewFollowers(
            uid: params['id'][0],
            startIndex: 0,
            username: params['username'][0],
          ));
  static Handler _followingHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewFollowers(
            uid: params['id'][0],
            startIndex: 1,
            username: params['username'][0],
          ));
  static Handler _likersHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ViewLikers(
            postId: params['id'][0],
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
  static Handler _checkVerifiedHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CheckVerified());

  static void setupRouter() {
    router.define(
      '/post/:id/likers',
      handler: _likersHandler,
    );
    router.define(
      '/chatroom/:uid/:username',
      handler: _chatRoomHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/charity/:id',
      handler: _charityHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/post/:id',
      handler: _postHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/?post=:id',
      handler: _postHandler,
      transitionType: TransitionType.material,
    );

    router.define(
      '/post/:id/comments',
      handler: _commentHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/post/:id/donate',
      handler: _donateHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/user/:id',
      handler: _viewOtherProfileHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/user/:id/:username/followers',
      handler: _followersHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/user/:id/:username/following',
      handler: _followingHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/account/edit',
      handler: _editProfileHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/addpost',
      handler: _addPostHandler,
    );
    router.define(
      '/challenge/:id',
      handler: _challengeDetailHandler,
      transitionType: TransitionType.material,
    );
    router.define(
      '/challenge/:id/steps',
      handler: _challengeStepsHandler,
      transitionType: TransitionType.material,
    );

    router.define(
      '/post/:id/uploadProof',
      handler: _uploadProofHandler,
      transitionType: TransitionType.material,
    );

    router.define(
      '/:id/addProfilePic',
      handler: _profilePicHandler,
      transitionType: TransitionType.material,
    );

    router.define(
      '/:id/tutorial',
      handler: _tutorialHandler,
      transitionType: TransitionType.material,
    );

    router.define(
      '/:id/verification',
      handler: _checkVerifiedHandler,
      transitionType: TransitionType.material,
    );

    router.define(
      'hashtag/:id/:id2',
      handler: _hashtagHandler1,
      transitionType: TransitionType.material,
    );

    router.define(
      'hashtag/:id',
      handler: _hashtagHandler2,
      transitionType: TransitionType.material,
    );
  }
}
