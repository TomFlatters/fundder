import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/share_post_view.dart';
import 'package:fundder/models/post.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_share/social_share.dart';
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ShareBar extends StatelessWidget {
  final Post post;

  ShareBar({@required this.post});

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

  Future<File> _fileFromImageUrl(url) async {
    File file;

    if (url.contains('video')) {
      file = await DefaultCacheManager().getSingleFile(url);
    } else {
      file = await DefaultCacheManager().getSingleFile(url);
    }
    return file;
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
          imageUrl: Uri.parse(post.imageUrl)),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: 45,
        height: 45,
        child: Image.asset('assets/images/share.png'),
      ),
      /*Expanded(
            child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  'Share',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, color: Colors.grey[850]),
                )))*/
      onTap: () {
        _showShare(context);
      },
    );
  }
}
