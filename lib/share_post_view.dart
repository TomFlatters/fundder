import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'package:universal_html/prefer_universal/js.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';

class SharePost extends StatelessWidget {
  final String postId;
  final String postTitle;
  SharePost({@required this.postId, @required this.postTitle});

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
        /*ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.facebook_messenger)),
          title: Text('Messenger'),
          onTap: (){},
        ), */
        ListTile(
          leading:
              Container(width: 30, height: 30, child: Icon(FontAwesome.link)),
          title: Text('Copy Link'),
          onTap: () async {
            final DynamicLinkParameters parameters = DynamicLinkParameters(
              uriPrefix: 'https://fundder.page.link',
              link: Uri.parse('https://app.fundder.co/post/${this.postId}'),
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
              itunesConnectAnalyticsParameters:
                  ItunesConnectAnalyticsParameters(
                providerToken: '123456',
                campaignToken: 'example-promo',
              ),
              socialMetaTagParameters: SocialMetaTagParameters(
                title: this.postTitle,
                description: 'Help support this fundraiser!',
              ),
            );

            final ShortDynamicLink shortDynamicLink =
                await parameters.buildShortLink();
            final Uri shortUrl = shortDynamicLink.shortUrl;
            print(shortUrl.toString());
            Clipboard.setData(new ClipboardData(text: shortUrl.toString()));
            final snackBar = SnackBar(content: Text('Link Copied'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
            Scaffold.of(context).showSnackBar(snackBar);
          },
        ), /*ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.snapchat_ghost)),
          title: Text('Snapchat'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.whatsapp)),
          title: Text('Whatsapp'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.whatsapp)),
          title: Text('Whatsapp status'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.instagram)),
          title: Text('Instagram'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.instagram)),
          title: Text('Instagram Stories'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(AntDesign.message1)),
          title: Text('SMS'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.facebook_square)),
          title: Text('Facebook'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.twitter)),
          title: Text('Twitter'),
          onTap: (){},
        ),*/
      ],
    );
  }
}
