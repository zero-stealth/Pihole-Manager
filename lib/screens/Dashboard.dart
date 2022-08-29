import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/screens/AddDevices.dart';
import 'package:piremote/screens/Devices.dart';
import 'package:piremote/screens/Logs.dart';
import 'package:piremote/screens/LogsHistory.dart';
import 'package:piremote/screens/Settings.dart';
import 'package:piremote/screens/Statistics.dart';
import 'package:piremote/widgets/InputWidget.dart';
import 'package:url_launcher/url_launcher.dart';

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

  var selectedMenuItem = "home";
  var timesPressed = 0;
  var _parentVariable = false;
  var clients = [];

  final Uri _url = Uri.parse('https://youtube.com/watch?v=xvFZjo5PgG0');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  refreshScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => super.widget),
    );
  }

  pageHandler() {
    switch (selectedMenuItem) {
      case 'home':
        return Devices();

      case 'stats':
        return Statistics();

      case 'logs':
        return Logs();

      case 'settings':
        return Settings();

      default:
    }
  }

  appBarName() {
    switch (selectedMenuItem) {
      case "home":
        return "Home";

      case "stats":
        return "Statistics";

      case "logs":
        return "Logs";

      case "settings":
        return "Settings";
      default:
    }
  }

  logsHistory() {
    if (selectedMenuItem == "logs") {
      return Row(
        children: [
          SizedBox(width: 10.0),
          Padding(
            padding: const EdgeInsets.only(
              top: 5.0,
              right: 20.0,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogsHistory()),
                );
              },
              child: const Icon(
                CupertinoIcons.clock,
                color: Colors.white,
                size: 23.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // cheeck of client already exists in the db
  // if yes do nothing
  // if not add them
  // checkClient(ip, requests) async {
  //   try {
  //     final dbHelper = DatabaseHelper.instance;
  //     var myclients = await dbHelper.queryAllRows('clients');

  //     for (var i = 0; i < myclients.length; i++) {
  //       if (ip == myclients[i]['ip']) {
  //         print("[-] $ip already exists in db");
  //         return;
  //       }
  //     }

  //     Map<String, dynamic> row = {
  //       "name": "none",
  //       "ip": ip,
  //       "requests": requests
  //     };

  //     await dbHelper.insert(row, "clients");
  //     print("[+] Added $ip to clients db");
  //     return;
  //   } catch (e) {
  //     print('ERROR');
  //     print(e);
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fixdb();
    addServices();
    setClients();
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
                floating: true,
                // pinned: true,
                backgroundColor: const Color(0xFF161B22),
                elevation: 1.0,
                centerTitle: false,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    left: 5.0,
                  ),
                  child: Text(
                    appBarName(),
                    style: TextStyle(
                      fontFamily: pBold,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                actions: [
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     top: 5.0,
                  //     right: 20.0,
                  //   ),
                  //   child: InkWell(
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => super.widget),
                  //       );
                  //     },
                  //     child: const Icon(
                  //       CupertinoIcons.arrow_counterclockwise,
                  //       color: Colors.white,
                  //       size: 23.0,
                  //     ),
                  //   ),
                  // ),
                  logsHistory(),
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
                          left: 0.0,
                          right: 0.0,
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
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 0.0),
                      padding: EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        // color: Color.fromARGB(255, 12, 15, 19),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF161B22).withOpacity(0.9),
                            const Color(0xFF161B22).withOpacity(0.9)
                          ],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                        // borderRadius: BorderRadius.circular(50.0),
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
                                  setState(() {
                                    timesPressed = timesPressed + 1;
                                  });

                                  if (timesPressed >= 10) {
                                    setState(() {
                                      timesPressed = 0;
                                    });
                                    _launchUrl();
                                  }
                                  // print("TIMES PRESSED: $timesPressed");
                                  if (selectedMenuItem != "home") {
                                    setState(() {
                                      selectedMenuItem = "home";
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.house_fill,
                                        size: 24.0,
                                        color: selectedMenuItem == "home"
                                            ? Color(0xff3FB950)
                                            : Color.fromARGB(
                                                255, 161, 161, 161),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'Home',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                          fontFamily: pRegular,
                                          color: selectedMenuItem == "home"
                                              ? Color(0xff3FB950)
                                              : Color.fromARGB(
                                                  255, 161, 161, 161),
                                        ),
                                      ),
                                    ],
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
                                  setState(() {
                                    timesPressed = 0;
                                  });
                                  if (selectedMenuItem != "stats") {
                                    setState(() {
                                      selectedMenuItem = "stats";
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.graph_square_fill,
                                        size: 24.0,
                                        color: selectedMenuItem == "stats"
                                            ? Color(0xff3FB950)
                                            : Color.fromARGB(
                                                255, 161, 161, 161),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'Stats',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                          fontFamily: pRegular,
                                          color: selectedMenuItem == "stats"
                                              ? Color(0xff3FB950)
                                              : Color.fromARGB(
                                                  255, 161, 161, 161),
                                        ),
                                      ),
                                    ],
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
                                  setState(() {
                                    timesPressed = 0;
                                  });
                                  if (selectedMenuItem != "logs") {
                                    setState(() {
                                      selectedMenuItem = "logs";
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.square_list_fill,
                                        size: 25.0,
                                        color: selectedMenuItem == "logs"
                                            ? Color(0xff3FB950)
                                            : Color.fromARGB(
                                                255, 161, 161, 161),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'Logs',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                          fontFamily: pRegular,
                                          color: selectedMenuItem == "logs"
                                              ? Color(0xff3FB950)
                                              : Color.fromARGB(
                                                  255, 161, 161, 161),
                                        ),
                                      ),
                                    ],
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
                                  setState(() {
                                    timesPressed = 0;
                                  });
                                  if (selectedMenuItem != "settings") {
                                    setState(() {
                                      selectedMenuItem = "settings";
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.settings_solid,
                                        size: 24.0,
                                        color: selectedMenuItem == "settings"
                                            ? Color(0xff3FB950)
                                            : Color.fromARGB(
                                                255, 161, 161, 161),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'Settings',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                          fontFamily: pRegular,
                                          color: selectedMenuItem == "settings"
                                              ? Color(0xff3FB950)
                                              : Color.fromARGB(
                                                  255, 161, 161, 161),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
