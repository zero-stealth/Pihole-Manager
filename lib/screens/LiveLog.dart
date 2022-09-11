import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/screens/Query.dart';
import 'package:piremote/widgets/Disconnected.dart';
import 'package:piremote/widgets/InputWidget.dart';
import 'package:piremote/widgets/NoDevices.dart';
import 'package:piremote/widgets/NoLogs.dart';
import 'package:piremote/widgets/NoRequests.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class LiveLog extends StatefulWidget {
  const LiveLog({Key? key}) : super(key: key);

  @override
  State<LiveLog> createState() => _LiveLogState();
}

class _LiveLogState extends State<LiveLog> {
  var logs = [];
  var mydata = [];
  var status = "";
  var clients = [];
  var ipStatus = true;
  var deviceStatus = true;
  var nologs = false;
  var selectedClient = "none";
  var noRequest = false;

  var livelogStatus = false;

  final dbHelper = DatabaseHelper.instance;

  var myLiveLog = [];

  getDeviceNames() async {
    final dbHelper = DatabaseHelper.instance;
    var myclients = await dbHelper.queryAllRows('clients');

    setState(() {
      clients = myclients;
    });
  }

  deviceName(ip) {
    if (clients.length < 0) {
      return ip;
    } else {
      for (var i = 0; i < clients.length; i++) {
        if (clients[i]['ip'] == ip) {
          if (clients[i]['name'] != 'none') {
            return clients[i]['name'];
          } else {
            return ip;
          }
        }
      }
    }
  }

  calculateTime(timestamp) {
    try {
      var date =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      var formattedTime = DateFormat.jm().format(date);
      print("[TIME] $formattedTime");
      return formattedTime;
    } catch (e) {
      print(e);
      return timestamp.toString();
    }
  }

  calculateStatus(type, timestamp) {
    switch (type) {
      case '1':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.redAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Gravity list',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      case '2':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: Color(0xff3FB950),
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Upstream server',
                  style: TextStyle(
                    color: Color(0xff3FB950),
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Color(0xff3FB950),
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      case '3':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.blueAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Local cache',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      case '4':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.redAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Wildcard blocking',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.redAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Blacklist',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );
    }
  }

  fetchLogs() async {
    if(logs.length > 200){
      setState(() {
        logs.removeRange(200, logs.length);
      });
    }

    var mydevices = await checkDevices();

    if (mydevices == false) {
      return setState(() {
        deviceStatus = false;
      });
    } else {
      var status = await test_ip();
      if (status == false) {
        return setState(() {
          ipStatus = false;
        });
      }
    }

    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

      final res = await http.Client().get(Uri.parse(
          '${devices[0]['protocol']}://${devices[0]['ip']}/admin/api.php?getAllQueries=1&auth=${devices[0]['apitoken']}'));
      if (res.statusCode == 200) {
        var pars = jsonDecode(res.body);
        print(pars);

        if (pars['data'].length <= 0) {
          return setState(() {
            nologs = true;
          });
        }

        

        for (var n = 0; n < 1; n++) {
          var data = [
            {'timestamp': calculateTime(pars['data'][n][0])},
            {'requestType': pars['data'][n][1]},
            {'domain': pars['data'][n][2]},
            {'type': pars['data'][n][4]},
            {'client': pars['data'][n][3]},
          ];

          if (selectedClient == "none") {
            setState(() {
              mydata.add(data);
            });
            // var fetched = [];
            // fetched.add(data);

            // Iterable inReverse = fetched.reversed;

            //   fetched = inReverse.toList();
            //   return fetched;
          }

          // if (selectedClient != "none") {
          //   if (pars['data'][n][3] == selectedClient) {
          //     setState(() {
          //       logs.add(data);
          //     });
          //   }
          // }
        }
      }

    Iterable inReverse = mydata.reversed;

    setState(() {
      logs = inReverse.toList();
    });

    if (logs.length <= 0) {
      setState(() {
        noRequest = true;
      });
    }

    return logs;
  }

  myLogs(l) {
    if (deviceStatus == false) {
      return NoDevices(context: context);
    }

    if (nologs == true) {
      return NoLogs(context: context);
    }

    if (l.length <= 0 && noRequest == true) {
      return NoRequests(context: context);
    }

    if (ipStatus == false) {
      return Disconnected(context: context);
    }

    if (l.length > 0) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            itemCount: l.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Query(
                        domain: "${l[index][2]['domain'].toString()}",
                        client: deviceName(logs[index][4]['client'].toString()),
                        type: "${l[index][1]['requestType'].toString()}",
                        timestamp: "${l[index][0]['timestamp'].toString()}",
                        status: "${l[index][3]['type'].toString()}",
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  padding: EdgeInsets.only(
                    bottom: 5.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        width: 2.0,
                        color: const Color(0xFF161B22).withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      calculateStatus(l[index][3]['type'].toString(),
                          l[index][0]['timestamp'].toString()),
                      SizedBox(height: 5.0),
                      Text(
                        '${l[index][2]['domain'].toString()}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: pBold,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        deviceName(l[index][4]['client'].toString()),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontFamily: pRegular,
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              );
            }),
      );
    }

    if (l.length <= 0 && noRequest == false) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Color(0xff3FB950),
              size: 50.0,
            ),
          ],
        ),
      );
    }
  }

  fetchClients() async {
    final dbHelper = DatabaseHelper.instance;
    var myclients = await dbHelper.queryAllRows('clients');

    setState(() {
      clients = myclients;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchClients();
    getDeviceNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.all(2.0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.chevron_back,
                        size: 25.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Text(
                      'LiveLog',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: pBold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 0.0),
              // myLogs(),

              StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 5))
                    .asyncMap((i) => fetchLogs(),),
                    
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                      return myLogs(snapshot.data);
                  } else if (snapshot.hasError) {
                    Text("${snapshot.error}");
                    return LoadingWidget();
                  }
                  return LoadingWidget();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: Color(0xff3FB950),
            size: 50.0,
          ),
        ],
      ),
    );
  }
}
