import 'package:flutter/material.dart';
import 'view_post_controller.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  int _current = 0;
  CarouselController _carouselController = CarouselController();
  final List<Widget> screens = [
   DefineDescription(),
   ChoosePerson(),
   SetMoney(),
   ChooseCharity(),
   ImageUpload()];
  @override
  Widget build(BuildContext context) {
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
            ? () {Navigator.of(context).pushReplacement(_viewPost());}
            : () {/*Navigator.of(context).pushReplacement(_viewPost());*/
            _carouselController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.linear);},
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
            items: screens,
          );
        },
      ),
    );
  }
}

class DefineDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical:10),
                child: Text('Title of Challenge',style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Write a title'
                )
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical:10),
                child: Text('Subtitle',style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'This will appear under the title in the feed'
                )
              ),
             Container(
                margin: EdgeInsets.symmetric(vertical:10),
                child: Text('Description',style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'A long description for detailed view'
                )
              )
            ])
        )]
        
      );
  }
}

class ChoosePerson extends StatefulWidget {
  @override
  _ChoosePersonState createState() => _ChoosePersonState();
}

class _ChoosePersonState extends State<ChoosePerson> {
  int selected = -1;
  final List<String> whoDoes = <String>["A specific person",'Myself','Anyone'];
  final List<String> subWho = <String>["Does not have to be a Fundder user",'Raise money for your own challenge','Will be public and anyone will be able to accept the challenge'];
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('Who do you want to do it',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    shrinkWrap: true,
                    itemCount: whoDoes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        dense: true,
                        leading: Builder(
                                builder: (context) {if(selected==index){
                                return Icon(Icons.check_circle);
                              }else{
                                return Icon(Icons.check_circle_outline);
                              }}),
                        title: Text(
                              '${whoDoes[index]}'),
                        subtitle: Text('${subWho[index]}'),
                        onTap: (){
                          selected=index;
                          setState(() {
                            
                          });
                        } ,
                      );
                    },
                  )
                ],)
            ),]
        
      );
  }
}

class SetMoney extends StatelessWidget {
  final moneyController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('What is the target amount:',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                  Row(
                    children: [Text('£',
                    style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Roboto Mono',
                          fontSize:45,
                        ),
                        ), Expanded( child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Roboto Mono',
                          fontSize:45,
                        ),
                    controller: moneyController,
                    decoration: InputDecoration(
                      hintText: 'Amount in £'
                    ))),]
                  )
                ])
            ),]
        
      );
  }
}

class ChooseCharity extends StatefulWidget {
  @override
  _ChooseCharityState createState() => _ChooseCharityState();
}

class _ChooseCharityState extends State<ChooseCharity> {
  final List<String> charities = <String>["Cancer Research",'British Heart Foundation','Oxfam'];
  int charity = -1;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('Which charity are you raising for?',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shrinkWrap: true,
                    itemCount: charities.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        dense: true,
                        leading: Builder(
                                builder: (context) {if(charity==index){
                                return Icon(Icons.check_circle);
                              }else{
                                return Icon(Icons.check_circle_outline);
                              }}),
                        title: Text(
                              '${charities[index]}'),
                        onTap: (){
                          charity=index;
                          setState(() {
                            
                          });
                        } ,
                      );
                    }
                  )
                ],)
            ),]
        
      );
  }
}

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {

  PickedFile imageFile;
  final picker = ImagePicker();

  _openGallery() async {
    imageFile = await picker.getImage(source: ImageSource.gallery);
    this.setState(() { });
  }

  _openCamera() async {
    imageFile = await picker.getImage(source: ImageSource.camera);
    this.setState(() { });
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Make a choice'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Gallery"),
                onTap: (){
                  _openGallery();
                },
                ),
              Padding(padding: EdgeInsets.all(8)),
              GestureDetector(
                child: Text("Camera"),
                onTap: (){
                  _openCamera();
                },
                ),
            ]
          ),
          ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Center(child: Text('No image selected')),
        Center(child: FlatButton(
          child: Text('Select Image'),
          onPressed: (){
            _showChoiceDialog(context);
          },
        ))
      ]
    );
  }


}


Route _viewPost() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewPost(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}