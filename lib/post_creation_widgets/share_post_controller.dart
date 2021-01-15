import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/helper_classes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'dart:io';
import 'package:fundder/models/post.dart';
import 'package:fundder/services/database.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SharePostController extends StatefulWidget {
  final String postId;
  SharePostController({this.postId});
  @override
  _SharePostControllerState createState() => _SharePostControllerState();
}

class _SharePostControllerState extends State<SharePostController> {
  double opacity = 0.0;
  Post post;

  @override
  void initState() {
    super.initState();
    changeOpacity();
    _getPost();
  }

  void _getPost() async {
    post = await DatabaseService().getPostById(widget.postId);
  }

  changeOpacity() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        changeOpacity();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Post Created'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/post/' + widget.postId);
              })
        ],
        leading: new Container(),
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration(seconds: 1),
                  child: Icon(
                    MdiIcons.partyPopper,
                    size: 130,
                    color: HexColor('ff6b6c'),
                  ),
                ),
                SizedBox(height: 60),
                Text(
                    'Congratulations! Your Fundder has been created. Share it now to help it get more donations',
                    textAlign: TextAlign.center),
                SizedBox(height: 40),
                PrimaryFundderButton(
                  onPressed: () async {
                    if (post != null) {
                      _showShare(context);
                    }
                  },
                  text: 'Share Fundder',
                ),
                SizedBox(height: 100),
              ],
            )),
      ),
    );
  }

  void _showShare(context) async {
    //File imageFile = await _fileFromImageUrl(post.imageUrl);
    Uri shortUrl = await _createDynamicLinkFromPost(this.post);
    Share.share(
        'Check out this charity fundraiser on Fundder! ' + shortUrl.toString(),
        subject: post.title);
    /*Share.shareFiles([imageFile.path],
        text: 'Check out this charity fundraiser on Fundder! ' +
            shortUrl.toString());*/
    /*showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 350,
            child: Scaffold(
              appBar: null,
              body: SharePost(
                post: this.post,
              ),
            ),
          );
        });*/
  }

  Future<Uri> _createDynamicLinkFromPost(Post post) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://fundder.page.link',
      link: Uri.parse('https://app.fundder.co/post/${post.id}'),
      androidParameters: AndroidParameters(
        packageName: 'com.fundder',
        minimumVersion: 0,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.fundder',
        minimumVersion: '1.0.0',
        appStoreId: '1529120882',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'example-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: post.title,
          description: 'Help support this fundraiser!',
          imageUrl: post.videoThumbnail != null
              ? Uri.parse(post.videoThumbnail)
              : post.imageUrl != null
                  ? Uri.parse(post.imageUrl)
                  : null),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl;
  }
}
