import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/helper_classes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'dart:io';
import 'package:fundder/models/post.dart';
import 'package:fundder/services/database.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

class ShareLinkController extends StatefulWidget {
  final Uri link;
  final String challengeId;
  final String username;
  ShareLinkController({this.link, this.challengeId, this.username});
  @override
  _ShareLinkControllerState createState() => _ShareLinkControllerState();
}

class _ShareLinkControllerState extends State<ShareLinkController> {
  double opacity = 0.0;
  Post post;

  @override
  void initState() {
    super.initState();
    changeOpacity();
  }

  changeOpacity() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Challenge Created'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/challenge/' + widget.challengeId);
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
                    'Congratulations! Your challenge has been created. Share this link for your friends to accept',
                    textAlign: TextAlign.center),
                SizedBox(height: 40),
                PrimaryFundderButton(
                  onPressed: () {
                    if (widget.link != null) {
                      _showShare(context);
                    }
                  },
                  text: 'Share Challenge',
                ),
                SizedBox(height: 100),
              ],
            )),
      ),
    );
  }

  void _showShare(context) {
    //File imageFile = await _fileFromImageUrl(post.imageUrl);
    Share.share('${widget.username} challenged you!\n' + widget.link.toString(),
        subject: 'Challenge is created');
  }
}
