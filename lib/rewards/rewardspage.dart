import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:fundder/shared/constants.dart';

import '../helper_classes.dart';

class RewardsPage extends StatefulWidget {
  final String uid;
  RewardsPage({this.uid});

  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  // TO DO: GET REWARDS DATA FROM FIREBASE
  // Future<List<Reward>> _getRewards() async {
  //   List<Reward>> rewardList = await DatabaseService().getRewards(widget.uid);
  //   return rewardList;
  // }

  @override
  Widget build(BuildContext context) {
    // TO DO: RENDER FUTURE BUILDER WHICH RENDERS A LIST OF POST-LIKE REWARDS
    return (Scaffold(
        appBar: AppBar(
          title: Text('Rewards'),
          centerTitle: true,
        ),
        body: Center(child: Text("REWARDS"))));
  }
}
