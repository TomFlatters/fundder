import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'package:universal_html/prefer_universal/js.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'models/post.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_share/social_share.dart';

class SharePost extends StatelessWidget {
  final Post post;
  SharePost({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF737373),
      height: 350,
      child: Container(
        child: _buildBottomNavigationMenu(context),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
          ),
        ),
      ),
    );
  }

  ListView _buildBottomNavigationMenu(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              'Share to:',
              style: TextStyle(
                fontFamily: 'Founders Grotesk',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          onTap: () {},
        ),
        ListTile(
          leading:
              Container(width: 30, height: 30, child: Icon(FontAwesome.link)),
          title: Text('Copy Link'),
          onTap: () async {
            Uri shortUrl = await _createDynamicLinkFromPost(this.post);
            print(shortUrl.toString());
            Clipboard.setData(new ClipboardData(text: shortUrl.toString()));
            final snackBar = SnackBar(content: Text('Link Copied'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
            Scaffold.of(context).showSnackBar(snackBar);
          },
        ),
        ListTile(
          leading: Container(
            width: 30,
            height: 30,
            child: Icon(FontAwesome5Brands.instagram),
          ),
          title: Text('Share to Instagram Story'),
          onTap: () async {
            File imageFile = await _fileFromImageUrl(post.imageUrl);
            Uri shortUrl = await _createDynamicLinkFromPost(this.post);
            SocialShare.shareInstagramStory(
                imageFile.path, "#ff6b6c", "#ffffff", shortUrl.toString());
          },
        ),
        ListTile(
          leading: Container(
              width: 30, height: 30, child: Icon(FontAwesome5Brands.instagram)),
          title: Text('Share to Instagram'),
          onTap: () async {},
        ),
        ListTile(
          leading: Container(
              width: 30, height: 30, child: Icon(FontAwesome5Brands.facebook)),
          title: Text('Share to Facebook Story'),
          onTap: () async {},
        ),
        ListTile(
          leading: Container(
              width: 30, height: 30, child: Icon(FontAwesome5Brands.facebook)),
          title: Text('Share to Facebook'),
          onTap: () async {},
        ),
        ListTile(
          leading: Container(
            width: 30,
            height: 30,
            child: Icon(FontAwesome5Brands.facebook_messenger),
          ),
          title: Text('Share to Facebook messenger'),
          onTap: () async {},
        ),
        ListTile(
          leading: Container(
              width: 30, height: 30, child: Icon(FontAwesome5Brands.whatsapp)),
          title: Text('Share to Whatsapp'),
          onTap: () async {},
        ),
        ListTile(
          leading: Container(
              width: 30, height: 30, child: Icon(FontAwesome5Brands.twitter)),
          title: Text('Share to Twitter'),
          onTap: () async {},
        ),
      ],
    );
  }

  Future<File> _fileFromImageUrl(url) async {
    var response = await http.get(url);
    final documentDirectory = await getApplicationDocumentsDirectory();

    File file = File(join(documentDirectory.path, 'imagetest.png'));

    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  Future<Uri> _createDynamicLinkFromPost(post) async {
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
      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl;
  }
}
