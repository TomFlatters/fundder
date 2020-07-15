import 'package:flutter/material.dart';

class UploadProofScreen extends StatefulWidget {
  final String postId;
  UploadProofScreen({this.postId});

  @override
  _UploadProofState createState() => _UploadProofState();
}

class _UploadProofState extends State<UploadProofScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Upload Proof"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          )
        ],
        leading: new Container(),
      ),
      body: ListView(
        children: <Widget>[
          Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Upload proof of completing the challenge. Once proof is uploaded and approved by a moderator, the raised money will be sent to charity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ])),
        ],
      ),
    );
  }
}
