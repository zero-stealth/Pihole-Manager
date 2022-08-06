import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/screens/Query.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  var logs = [];
  var status = "";

  calculateStatus(type) {
    switch (type) {
      case '1':
        return Row(
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
                fontFamily: "SFT-Regular",
              ),
            ),
          ],
        );

      case '2':
        return Row(
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
                fontFamily: "SFT-Regular",
              ),
            ),
          ],
        );

      case '3':
        return Row(
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
                fontFamily: "SFT-Regular",
              ),
            ),
          ],
        );

      case '4':
        return Row(
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
                fontFamily: "SFT-Regular",
              ),
            ),
          ],
        );

      default:
        return Row(
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
                fontFamily: "SFT-Regular",
              ),
            ),
          ],
        );
    }
  }

  myLogs() {
    if (logs.length > 0) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            itemCount: logs.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Query(
                        domain: "${logs[index][2]['domain'].toString()}",
                        client: "${logs[index][4]['client'].toString()}",
                        type: "${logs[index][1]['requestType'].toString()}",
                        timestamp: "${logs[index][0]['timestamp'].toString()}",
                        status: "${logs[index][3]['type'].toString()}",
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
                      calculateStatus(logs[index][3]['type'].toString()),
                      SizedBox(height: 5.0),
                      Text(
                        '${logs[index][2]['domain'].toString()}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: "SFT-Regular",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '${logs[index][4]['client'].toString()}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontFamily: "SFT-Regular",
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              );
            }),
      );
    } else {
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
            )
          ],
        ),
      );
    }
  }

  fetchLogs() async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

    for (var i = 0; i < devices.length; i++) {
      final res = await http.Client().get(Uri.parse(
          'http://${devices[i]['ip']}/admin/api.php?getAllQueries=50&auth=${devices[i]['apitoken']}'));
      if (res.statusCode == 200) {
        var pars = jsonDecode(res.body);
        // print(DateTime.parse(pars['data'][0][0].toDate().toString()));

        // var timestamp = DateTime.parse('1658126697');

        // // print(d);
        // var date = DateTime.fromMicrosecondsSinceEpoch(1658126697 * 1000, isUtc: false);
        // String formattedTime = DateFormat.jm().format(date);
        // print(date);

        try {
          for (var n = 0; n < pars['data'].length; n++) {
            var clientName = await findClientName(pars['data'][n][3]);

            var data = [
              {'timestamp': pars['data'][n][0]},
              {'requestType': pars['data'][n][1]},
              {'domain': pars['data'][n][2]},
              {'type': pars['data'][n][4]},
              {'client': clientName},
            ];

            setState(() {
              logs.add(data);
            });
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setClients();
    fetchLogs();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // padding: const EdgeInsets.only(
          //   top: 15.0,
          //   bottom: 10.0,
          //   left: 15.0,
          //   right: 15.0,
          // ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: myLogs(),
        ),
      ],
    );
  }
}
