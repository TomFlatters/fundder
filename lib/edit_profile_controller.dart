import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final List<String> entries = <String>["Name",'Username','Website','Bio','Email','Phone','Gender'];
  final List<String> hints = <String>["Name",'Username','Website','Something about you','Email','Phone','Gender'];
  int selected = -1;
  int charity = -1;

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Profile'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close), 
            onPressed: () => Navigator.of(context).pop(null),
            )
        ],
        leading: new Container(),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20, bottom:10),
            alignment: Alignment.center,
            child: Container(
              child: ProfilePic("https://i.imgur.com/BoN9kdC.png", 90),
              margin: EdgeInsets.all(10.0),            
            ),
          ), GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: EdgeInsets.only(left: 70, right:70, bottom: 20, top:20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                "Change profile picture",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              onTap: () {_changePic();},
        ),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 10.0),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal:20),
                    width:80,
                    child: Text(entries[index])
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hints[index],
                      ),
                    ),
                    )
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index){
              return SizedBox(
                height: 10,
              );
            },
          ),
        ]
      ),
    );
 }

 void _changePic() {
  showModalBottomSheet(
    context: context, 
    builder: (context) {
      return ChangePic();
    }
    );
  }

}

class ChangePic extends StatelessWidget{

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

  ListView _buildBottomNavigationMenu(context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Photo'),
          onTap: () async {
            },
        ),
        ListTile(
          leading: Icon(FontAwesome5Brands.facebook_square),
          title: Text('Import from Facebook'),
          onTap: () {
            },
        ),
                ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Photo'),
          onTap: () {
            },
        ),
                ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose From Library'),
          onTap: () {
            },
        ),
      ],
      );
  }
}