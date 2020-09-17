import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/models/charity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fundder/helper_classes.dart';

class CharityTile extends StatefulWidget {
  @override
  _CharityTileState createState() => _CharityTileState();

  final Charity charity;
  final bool selected;
  CharityTile(this.charity, this.selected);
}

class _CharityTileState extends State<CharityTile> {
  bool isExpanded = false;

  @override
  void didUpdateWidget(CharityTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          color:
              widget.selected == true ? HexColor('ff6b6c') : Colors.grey[200],
        ),
        child: ExpandableCardContainer(
          expandedChild: createExpandedColumn(context),
          collapsedChild: createCollapsedColumn(context),
          isExpanded: isExpanded,
        ));
  }

  Widget createExpandedColumn(context) {
    return Column(children: [
      createCollapsedColumn(context),
      Container(
          margin: EdgeInsets.all(20),
          child: Text(
            widget.charity.bio,
            style: TextStyle(
                color: widget.selected == true ? Colors.white : Colors.black),
          )),
      SizedBox(
        height: 20,
      ),
      widget.selected == true
          ? SecondaryFundderButton(
              text: 'View Page',
              onPressed: () {
                Navigator.pushNamed(context, '/charity/' + widget.charity.id);
              })
          : PrimaryFundderButton(
              text: 'View Page',
              onPressed: () {
                Navigator.pushNamed(context, '/charity/' + widget.charity.id);
              }),
      SizedBox(
        height: 20,
      )
    ]);
  }

  Widget createCollapsedColumn(context) {
    return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          color: Colors.white,
        ),
        height: 65,
        child: AspectRatio(
            aspectRatio: 1 / 1,
            child: ClipRRect(
              borderRadius: new BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.charity.image,
                fit: BoxFit.contain,
              ),
            )),
      ),
      Expanded(
        child: Text(
          widget.charity.name,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.selected == true ? Colors.white : Colors.black),
        ),
      ),
      tileExpander(),
    ]));
  }

  Widget tileExpander() {
    return GestureDetector(
      child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          color:
              widget.selected == true ? HexColor('ff6b6c') : Colors.grey[200],
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.all(10),
          child: Icon(
            isExpanded ? Ionicons.ios_arrow_down : Ionicons.ios_arrow_up,
            color: widget.selected == true ? Colors.white : Colors.grey,
            size: 30,
          )),
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
    );
  }
}

class ExpandableCardContainer extends StatefulWidget {
  final bool isExpanded;
  final Widget collapsedChild;
  final Widget expandedChild;

  const ExpandableCardContainer(
      {Key key, this.isExpanded, this.collapsedChild, this.expandedChild})
      : super(key: key);

  @override
  _ExpandableCardContainerState createState() =>
      _ExpandableCardContainerState();
}

class _ExpandableCardContainerState extends State<ExpandableCardContainer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return new AnimatedSize(
      vsync: this,
      duration: new Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: widget.isExpanded ? widget.expandedChild : widget.collapsedChild,
    );
  }
}
