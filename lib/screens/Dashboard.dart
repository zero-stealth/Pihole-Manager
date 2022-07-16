import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/screens/AddDevices.dart';
import 'package:piremote/widgets/InputWidget.dart';

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

  TextEditingController namecontroller = TextEditingController();
  TextEditingController ipcontroller = TextEditingController();
  TextEditingController tokencontroller = TextEditingController();

  String totalQueries = "0";
  String queriesBlocked = "0";
  String percentBlocked = "0";
  String blocklist = "0";
  String status = "";
  String clients_ever_seen = "";

  var devices_data = [];

  var selectedMenuItem = "home";

  enableBlocking(ip, token) async {
    var url = 'http://$ip';
    final response =
        await http.get(Uri.parse('$url/admin/api.php?enable&auth=$token'));

    if (response.statusCode == 200) {
      print('ENABLED BLOCKING SUCCESSFULLY');
      refreshScreen();
    }
  }

  disableBlocking(ip, token, seconds) async {
    var url = 'http://$ip';
    final response = await http
        .get(Uri.parse('$url/admin/api.php?disable=$seconds&auth=$token'));

    if (response.statusCode == 200) {
      refreshScreen();
    }
  }

  refreshScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => super.widget),
    );
  }

  fetchQueries() async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

    for (var i = 0; i < devices.length; i++) {
      // FIGURE OUT HOW TO PARSE
      // THE TERRIBLY FORMATTED OBJECTS
      // WITH DART

      // final res = await http.Client().get(Uri.parse(
      //     'http://${devices[i]['ip']}/admin/api.php?topClients&auth=25aa34070a75ce79dcf2496484ad2301de3daa2b80581c9b265eaadb79685303'));
      // if (res.statusCode == 200) {
      //   Map pars = jsonDecode(res.body);
      //   // print('CLIENTS: $pars');
      //   print(pars['top_sources']);

      //   pars.entries.map((e) {
      //     print('KEY: ${e.key}');
      //     print('VALUE: ${e.value}');
      //   });
      // } else {
      //   print('ERROR');
      //   print(res);
      // }

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
          "apitoken": devices[i]['apitoken'],
        };

        var timer = Timer(
          Duration(seconds: 1),
          () => setState(() {
            devices_data.add(data);
          }),
        );

        // timer.cancel();
      } else {
        throw Exception("Unable to fetch query data");
      }
    }
  }

  deviceSettingsModal(context, name, ip, token) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      )),
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1117),
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50.0,
                    height: 4.0,
                    margin: EdgeInsets.only(top: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: const Color(0xFF161B22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22.0),
              // Text(
              //   name,
              //   style: TextStyle(
              //     fontFamily: 'SFD-Bold',
              //     color: Colors.white,
              //     fontSize: 20.0,
              //   ),
              // ),
              // const SizedBox(height: 15.0),
              // InputWidget(
              //   namecontroller: namecontroller,
              //   label: "Device Name",
              //   placeholder: name,
              // ),
              // const SizedBox(height: 15.0),
              // InputWidget(
              //   namecontroller: ipcontroller,
              //   label: "Pihole ip address",
              //   placeholder: ip,
              // ),
              // const SizedBox(height: 15.0),
              // InputWidget(
              //   namecontroller: tokencontroller,
              //   label: "Pihole api token",
              //   placeholder: token,
              // ),
              // const SizedBox(height: 20.0),
              // Container(
              //   width: double.infinity,
              //   margin: const EdgeInsets.only(
              //     bottom: 10.0,
              //     left: 0.0,
              //     right: 0.0,
              //   ),
              //   child: CupertinoButton(
              //     borderRadius: BorderRadius.circular(6.0),
              //     color: const Color(0xff3FB950),
              //     child: Text(
              //       'Edit',
              //       style: TextStyle(
              //         fontSize: 14.0,
              //         fontFamily: "SFT-Regular",
              //       ),
              //     ),
              //     onPressed: () {},
              //   ),
              // ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  left: 0.0,
                  right: 0.0,
                ),
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(6.0),
                  color: Color(0xFF161B22),
                  child: Text(
                    'Delete device',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14.0,
                      fontFamily: "SFT-Regular",
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
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
            children: [Text("Statistics")],
          ),
        );

      case 'logs':
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Logs")],
          ),
        );

      case 'settings':
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Settings")],
          ),
        );

      default:
    }
  }

  void _showActionSheet(BuildContext context, name, ip, token) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContextcontext) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: CupertinoActionSheet(
          title: Text('Disable Pi-hole blocking'),
          message: Text('How long do you want to disable blocking for $name'),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              onPressed: () {
                disableBlocking(ip, token, 60);
              },
              child: Text('1 minute'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                disableBlocking(ip, token, 300);
              },
              child: Text('5 minutes'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                disableBlocking(ip, token, 3600);
              },
              child: Text('1 hour'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                disableBlocking(ip, token, 28800);
              },
              child: Text('8 hours'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                disableBlocking(ip, token, 0);
              },
              child: Text('Until Turned on'),
            ),
          ],
        ),
      ),
    );
  }

  deviceStatusIcon(status) {
    switch (status) {
      case 'enabled':
        return const Icon(
          CupertinoIcons.check_mark_circled_solid,
          color: Color(0xff3FB950),
          size: 20.0,
        );

      case 'disabled':
        return const Icon(
          CupertinoIcons.xmark_circle_fill,
          color: Colors.redAccent,
          size: 20.0,
        );

      default:
    }
  }

  devices_list() {
    print(devices_data.length);
    if (devices_data.length > 0) {
      for (var i = 0; i < devices_data.length; i++) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      deviceStatusIcon(devices_data[i]['status']),
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
                  Container(
                    padding: EdgeInsets.only(
                      right: 0.0,
                      top: 8.0,
                    ),
                    child: InkWell(
                      
                      borderRadius: BorderRadius.circular(50.0),
                      onTap: () {
                        deviceSettingsModal(context, devices_data[i]['name'],
                            devices_data[i]['ip'], devices_data[i]['apitoken']);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          CupertinoIcons.ellipsis,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Stats(
              temperature: devices_data[i]['temperature'],
              memoryUsage: devices_data[i]['memory'],
            ),
            const SizedBox(height: 18.0),
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
                  children: [
                    devices_data[i]['status'] == 'enabled'
                        ? const Text(
                            'Disable',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14.0,
                              fontFamily: 'SFT-Regular',
                            ),
                          )
                        : const Text(
                            'Enable',
                            style: TextStyle(
                              color: Color(0xff3FB950),
                              fontSize: 14.0,
                              fontFamily: 'SFT-Regular',
                            ),
                          ),
                  ],
                ),
                onPressed: () {
                  // Navigator.pop(context);
                  if (devices_data[i]['status'] == 'disabled') {
                    enableBlocking(
                      devices_data[i]['ip'],
                      devices_data[i]['apitoken'],
                    );
                  } else {
                    _showActionSheet(
                      context,
                      devices_data[i]['name'],
                      devices_data[i]['ip'],
                      devices_data[i]['apitoken'],
                    );
                  }
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
                          MaterialPageRoute(builder: (context) => AddDevices()),
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
