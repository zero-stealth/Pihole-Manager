import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  var logs = [];

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
              return Column(
                children: [
                  Text(
                    logs[index][0]['timestamp'].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontFamily: "SFT-Regular",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    logs[index][1]['domain'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontFamily: "SFT-Regular",
                    ),
                  ),
                  SizedBox(height: 8.0),
                ],
              );
            }),
      );
    } else {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Color(0xff3FB950),
              size: 20.0,
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
          'http://${devices[i]['ip']}/admin/api.php?getAllQueries=5&auth=${devices[i]['apitoken']}'));
      if (res.statusCode == 200) {
        var pars = jsonDecode(res.body);
        // print(DateTime.parse(pars['data'][0][0].toDate().toString()));

        // var timestamp = DateTime.parse('1658126697');

        // // print(d);
        // var date = DateTime.fromMicrosecondsSinceEpoch(1658126697 * 1000, isUtc: false);
        // String formattedTime = DateFormat.jm().format(date);
        // print(date);

        print('first: ${pars['data']}');

        try {
          for (var n = 0; n < pars['data'].length; i++) {
            var data = [
              {'timestamp': pars['data'][n][0].toString()},
              {'domain': pars['data'][n][2].toString()},
              {'type': pars['data'][n][4].toString()},
              {'client': pars['data'][n][3].toString()},
            ];

            setState(() {
              logs.add(data);
            });
          }

          print('second: $logs');
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
    // fetchLogs();
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
          padding: const EdgeInsets.only(
            top: 15.0,
            bottom: 10.0,
            left: 15.0,
            right: 15.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text("Logs"),
        ),
      ],
    );
  }
}
