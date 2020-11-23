import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/models/rewards.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:fundder/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper_classes.dart';

class RewardsPage extends StatefulWidget {
  final String uid;
  final String lastPostTime;
  RewardsPage({this.uid, this.lastPostTime});

  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  // TO DO: GET REWARDS DATA FROM FIREBASE
  // Future<List<Reward>> _getRewards() async {
  //   List<Reward>> rewardList = await DatabaseService().getRewards(widget.uid);
  //   return rewardList;
  // }

  final cloudFunc = CloudFunctions.instance;
  bool loading = false;

  Future<List<Reward>> _getRewards() async {
    List<Reward> rewardList = await DatabaseService().getRewardsList();
    return rewardList;
  }

  Future<List<dynamic>> _checkRewardFunction(
      functionName, rewardId, uid) async {
    print(functionName + '/' + uid + '/' + rewardId);

    HttpsCallable rewardFunction =
        cloudFunc.getHttpsCallable(functionName: functionName);
    print('got function');
    HttpsCallableResult res = await rewardFunction.call(<String, String>{
      'uid': uid.toString(),
      'rewardid': rewardId.toString()
    });
    print(res.data);
    return [
      res.data['rewardAvailable'],
      res.data['titleMessage'],
      res.data['bodyMessage']
    ];
  }

  @override
  Widget build(BuildContext context) {
    // TO DO: RENDER FUTURE BUILDER WHICH RENDERS A LIST OF POST-LIKE REWARDS
    return (Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Rewards'),
          centerTitle: true,
        ),
        body: loading == true
            ? Loading()
            : FutureBuilder(
                future: _getRewards(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Reward>> rewardList) {
                  switch (rewardList.connectionState) {
                    case ConnectionState.none:
                      return new Text('Press to start');
                    case ConnectionState.waiting:
                      return Loading();
                    default:
                      if (rewardList.hasError)
                        return new Text('There are no rewards available.');
                      else
                        return ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(
                            height: 10,
                          ),
                          padding: const EdgeInsets.only(top: 10.0),
                          itemCount: rewardList.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            Reward rewardData = rewardList.data[index];
                            return GestureDetector(
                                child: Container(
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: new BorderRadius.all(
                                          Radius.circular(10.0),
                                        )),
                                    padding: EdgeInsets.all(18.0),
                                    child: Column(children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(rewardData.title,
                                            style: TextStyle(
                                              fontFamily: 'Founders Grotesk',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20,
                                            )),
                                      ),
                                      SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "What you have to do: " +
                                                rewardData.task,
                                            style: TextStyle(
                                              fontFamily: 'Founders Grotesk',
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                      SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "Your reward: " + rewardData.reward,
                                            style: TextStyle(
                                              fontFamily: 'Founders Grotesk',
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                      SizedBox(height: 10),
                                      PrimaryFundderButton(
                                          text: 'Get reward',
                                          onPressed: () async {
                                            print(rewardData.rewardId);
                                            /*setState(() {
                                              loading = true;
                                            });*/
                                            List<dynamic> status =
                                                await _checkRewardFunction(
                                                    rewardData.function,
                                                    rewardData.rewardId,
                                                    widget.uid);
                                            // user has completed the task
                                            showDialog(
                                                context: context,
                                                child: new AlertDialog(
                                                  title: new Text(status[1]),
                                                  content: new Text(status[2]),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text("OK"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                ));
                                          }),
                                    ])));
                          },
                        );
                  }
                })));
  }
}
