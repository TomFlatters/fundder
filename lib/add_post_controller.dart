import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'view_post_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/models/post.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  int _current = 0;
  CarouselController _carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create Fundder"),
        actions: <Widget>[
          new FlatButton(
            child: _current == 4
                ? Text('Submit', style: TextStyle(fontWeight: FontWeight.bold))
                : Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _current == 4
                ? () {
                    // add image to firebase storage
                    final String fileLocation = user.uid +
                        "/" +
                        DateTime.now().microsecondsSinceEpoch.toString();
                    DatabaseService(uid: user.uid)
                        .uploadImage(imageFile, fileLocation)
                        .then((downloadUrl) => {
                              print("Successful image upload"),
                              print(downloadUrl),

                              // Check for the TYPE of the challenge (who they want to do it), 
                              // create a Template or Post accordingly
                              if(whoDoes[selected]=="Myself"){
                                // Create a post from the state and image url, and add that post to firebase
                                DatabaseService(uid: user.uid)
                                    .uploadPost(new Post(
                                      title: titleController.text.toString(),
                                      subtitle:
                                          subtitleController.text.toString(),
                                      author: user.uid,
                                      charity: charities[charity],
                                      likes: [],
                                      comments: {},
                                      timestamp: DateTime.now(),
                                      amountRaised: "0",
                                      targetAmount:
                                          moneyController.text.toString(),
                                      imageUrl: downloadUrl,
                                    ))
                                    .then((postId) => {
                                          print("The doc id is " + postId.toString().substring(1, postId.toString().length - 1)),
                                          
                                          // if the post is successfully added, view the post
                                          Navigator.pushReplacementNamed(
                                              context,
                                              '/post/' +
                                                  postId.toString().substring(
                                                      1,
                                                      postId.toString().length -
                                                          1)) //the substring is very important as postId.toString() is in brackets
                                        })
                              }else{
                                // Create a template
                                print("Creating a template")
                              }});}
                : () {
                    /*Navigator.of(context).pushReplacement(_viewPost());*/
                    _carouselController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.linear);
                  },
          )
        ],
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
              enableInfiniteScroll: false,
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              // autoPlay: false,
            ),
            items: [
              _defineDescription(),
              _choosePerson(),
              _setMoney(),
              _chooseCharity(),
              _imageUpload()
            ],
          );
        },
      ),
    );
  }
  // Define widgets for each of the form stages:

  // _defineDescription state:
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();

  Widget _defineDescription() {
    return ListView(children: <Widget>[
      Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Title of Challenge',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: 'Write a title')),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Subtitle',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                    controller: subtitleController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText:
                            'This will appear under the title in the feed')),
              ]))
    ]);
  }

  // _choosePerson state:
  int selected = -1;
  final List<String> whoDoes = <String>[
    "A specific person",
    'Myself',
    'Anyone'
  ];
  final List<String> subWho = <String>[
    "Does not have to be a Fundder user",
    'Raise money for your own challenge',
    'Will be public and anyone will be able to accept the challenge. This appears in the custom challenges in the do tab in the Feed'
  ];

  Widget _choosePerson() {
    return ListView(children: <Widget>[
      Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Who do you want to do it',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                shrinkWrap: true,
                itemCount: whoDoes.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    dense: true,
                    leading: Builder(builder: (context) {
                      if (selected == index) {
                        return Icon(Icons.check_circle);
                      } else {
                        return Icon(Icons.check_circle_outline);
                      }
                    }),
                    title: Text('${whoDoes[index]}'),
                    subtitle: Text('${subWho[index]}'),
                    onTap: () {
                      selected = index;
                      setState(() {});
                    },
                  );
                },
              )
            ],
          )),
    ]);
  }

  // _setMoney state:
  final moneyController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  Widget _setMoney() {
    return ListView(children: <Widget>[
      Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Text(
              'What is the target amount:',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Row(children: [
              Text(
                '£',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Roboto Mono',
                  fontSize: 45,
                ),
              ),
              Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontFamily: 'Roboto Mono',
                        fontSize: 45,
                      ),
                      controller: moneyController,
                      decoration: InputDecoration(hintText: 'Amount in £'))),
            ])
          ])),
    ]);
  }

  // _chooseCharity state:
  final List<String> charities = <String>[
    "Cancer Research",
    'British Heart Foundation',
    'Oxfam'
  ];
  int charity = -1;

  Widget _chooseCharity() {
    return ListView(children: <Widget>[
      Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Which charity are you raising for?',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shrinkWrap: true,
                  itemCount: charities.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      dense: true,
                      leading: Builder(builder: (context) {
                        if (charity == index) {
                          return Icon(Icons.check_circle);
                        } else {
                          return Icon(Icons.check_circle_outline);
                        }
                      }),
                      title: Text('${charities[index]}'),
                      onTap: () {
                        charity = index;
                        setState(() {});
                      },
                    );
                  })
            ],
          )),
    ]);
  }

  // _imageUpload state
  PickedFile imageFile;
  final picker = ImagePicker();
  Widget _imageUpload() {
    return ListView(children: <Widget>[
      Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Text(
          'Add a photo to make your Fundder more recognisable',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      Container(
        child: _decideImageView(),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 9 / 16,
      ),
      GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          margin: EdgeInsets.only(left: 70, right: 70, bottom: 20, top: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(
            "Select Image",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
        onTap: () {
          _changePic();
        },
      ),
    ]);
  }

  void _changePic() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
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
        });
  }

  // Helper functions for the image picker
  _openGallery() async {
    imageFile = await picker.getImage(source: ImageSource.gallery);
    this.setState(() {});
  }

  _openCamera() async {
    imageFile = await picker.getImage(source: ImageSource.camera);
    this.setState(() {});
  }

  _removePhoto() {
    imageFile = null;
    this.setState(() {});
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return Center(child: Text('No image selected'));
    } else {
      return Image.file(File(imageFile.path));
    }
  }

  ListView _buildBottomNavigationMenu(context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Photo'),
          onTap: () async {
            _removePhoto();
          },
        ),
        ListTile(
          leading: Icon(FontAwesome5Brands.facebook_square),
          title: Text('Import from Facebook'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Photo'),
          onTap: () {
            _openCamera();
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose From Library'),
          onTap: () {
            _openGallery();
          },
        ),
      ],
    );
  }
}
