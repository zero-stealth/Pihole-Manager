import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/screens/Splash.dart';

import '../models/QueryModel.dart';
import '../widgets/Panels.dart';
import '../widgets/Stats.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  containerWidth() {
    var width = (MediaQuery.of(context).size.width - 50) / 2;
    return width;
  }

  String memory = "0%";
  String temperature = "0°";

  String totalQueries = "0";
  String queriesBlocked = "0";
  String percentBlocked = "0";
  String blocklist = "0";
  String status = "";
  String clients_ever_seen = "";

  var devices_data = [];

  var selectedMenuItem = "home";

  fetchQueries() async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

    for (var i = 0; i < devices.length; i++) {
      final resp = await http.Client()
          .get(Uri.parse('http://${devices[i]['ip']}/admin/'));
      if (resp.statusCode == 200) {
        var document = parser.parse(resp.body);
        try {
          var temp = document.getElementsByClassName('pull-left info')[0];

          LineSplitter ls = new LineSplitter();
          List<String> lines = ls.convert(temp.text.trim());

          for (var i = 0; i < lines.length; i++) {
            if (i == 4) {
              var ext = lines[i].replaceAll(new RegExp(r'[^\.0-9]'), '');
              setState(() {
                var mytemp = double.parse(ext);
                assert(mytemp is double);
                temperature = mytemp.toStringAsFixed(1);
              });
            }

            if (i == 3) {
              var ext2 = lines[i].replaceAll(new RegExp(r'[^\.0-9]'), '');
              setState(() {
                memory = '$ext2%';
              });
            }
          }
        } catch (e) {
          print(e);
        }
      }

      var myurl = "http://${devices[i]['ip']}";
      final response =
          await http.get(Uri.parse('$myurl/admin/api.php?summary'));

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        QueryModel queryModel = QueryModel.fromMap(parsed);

        var data = {
          "name": devices[i]['name'],
          "ip": devices[i]['ip'],
          "temperature": temperature,
          "memory": memory,
          "totalQueries": queryModel.dns_queries_today,
          "queriesBlocked": queryModel.ads_blocked_today,
          "percentBlocked": queryModel.ads_percentage_today,
          "blocklist": queryModel.domains_being_blocked,
          "status": queryModel.status,
          "allClients": queryModel.clients_ever_seen,
        };

        setState(() {
          devices_data.add(data);
        });
      } else {
        throw Exception("Unable to fetch query data");
      }
    }
  }

  pageHandler() {
    switch (selectedMenuItem) {
      case 'home':
        return devices_list();

      case 'stats':
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Statistics")
            ],
          ),
        );

      case 'logs':
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Logs")
            ],
          ),
        );

      case 'settings':
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Settings")
            ],
          ),
        );

      default:
    }
  }

  devices_list() {
    print(devices_data.length);
    if (devices_data.length > 0) {
      for (var i = 0; i < devices_data.length; i++) {
        return Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: Color(0xff3FB950),
                    size: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        devices_data[i]['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "SFD-Bold",
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Stats(
              temperature: devices_data[i]['temperature'],
              memoryUsage: devices_data[i]['memory'],
            ),
            const SizedBox(height: 15.0),
            Panels(
              firstLabel: "Total queries",
              firstValue: devices_data[i]['totalQueries'],
              secondLabel: "Queries blocked",
              secondValue: devices_data[i]['queriesBlocked'],
            ),
            Panels(
              firstLabel: "Percent blocked",
              firstValue: '${devices_data[i]['percentBlocked']}%',
              secondLabel: "Blocklist",
              secondValue: devices_data[i]['blocklist'],
            ),
            Panels(
              firstLabel: "Status",
              firstValue: '${devices_data[i]['status']}',
              secondLabel: "All Clients",
              secondValue: devices_data[i]['allClients'],
            ),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              child: CupertinoButton(
                padding: const EdgeInsets.all(10.0),
                color: const Color(0xFF161B22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    // Icon(
                    //   CupertinoIcons.stop,
                    //   color: Colors.white,
                    //   size: 16.0,
                    // ),
                    // SizedBox(width: 10.0),
                    Text(
                      'Disable',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14.0,
                        fontFamily: 'SFT-Regular',
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  // Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      }
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

  @override
  void initState() {
    super.initState();
    fetchQueries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF161B22),
                elevation: 1.0,
                centerTitle: false,
                automaticallyImplyLeading: false,
                title: const Padding(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    left: 5.0,
                  ),
                  child: Text(
                    'Pihole Remote',
                    style: TextStyle(
                      fontFamily: 'SFD-Bold',
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5.0,
                      right: 28.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => super.widget),
                        );
                      },
                      child: const Icon(
                        CupertinoIcons.arrow_counterclockwise,
                        color: Colors.white,
                        size: 23.0,
                      ),
                    ),
                  ),
                  // SizedBox(width: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5.0,
                      right: 20.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SplashScreen()),
                        );
                      },
                      child: const Icon(
                        CupertinoIcons.add_circled,
                        color: Colors.white,
                        size: 23.0,
                      ),
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          left: 20.0,
                          right: 20.0,
                        ),
                        child: pageHandler(),
                      ),
                    ],
                  ),
                ]),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15.0),
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  width: MediaQuery.of(context).size.width - 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            focusColor: Colors.blue,
                            splashColor: Colors.blue,
                            onTap: () {
                              if (selectedMenuItem != "home") {
                                setState(() {
                                  selectedMenuItem = "home";
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                CupertinoIcons.house_fill,
                                size: 24.0,
                                color: selectedMenuItem == "home"
                                    ? Color(0xff3FB950)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 5.0),
                      Column(
                        children: [
                          InkWell(
                            focusColor: Colors.blue,
                            splashColor: Colors.blue,
                            onTap: () {
                              if (selectedMenuItem != "stats") {
                                setState(() {
                                  selectedMenuItem = "stats";
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                CupertinoIcons.graph_square_fill,
                                size: 24.0,
                                color: selectedMenuItem == "stats"
                                    ? Color(0xff3FB950)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 5.0),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (selectedMenuItem != "logs") {
                                setState(() {
                                  selectedMenuItem = "logs";
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                CupertinoIcons.square_list_fill,
                                size: 24.0,
                                color: selectedMenuItem == "logs"
                                    ? Color(0xff3FB950)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 5.0),
                      Column(
                        children: [
                          InkWell(
                            focusColor: Colors.blue,
                            splashColor: Colors.blue,
                            onTap: () {
                              if (selectedMenuItem != "settings") {
                                setState(() {
                                  selectedMenuItem = "settings";
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                CupertinoIcons.settings_solid,
                                size: 24.0,
                                color: selectedMenuItem == "settings"
                                    ? Color(0xff3FB950)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
