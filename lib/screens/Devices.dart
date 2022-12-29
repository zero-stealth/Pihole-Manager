import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/models/QueryModel.dart';
import 'package:piremote/screens/AddDevices.dart';
import 'package:piremote/screens/Blocked.dart';
import 'package:piremote/widgets/Disconnected.dart';
import 'package:piremote/widgets/InvalidToken.dart';
import 'package:piremote/widgets/NoDevices.dart';
import 'package:piremote/widgets/Panels.dart';
import 'package:piremote/widgets/Stats.dart';
import 'dart:async';
import 'dart:convert';

class Devices extends StatefulWidget {
  const Devices({Key? key}) : super(key: key);

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  var devices_data = [];
  String memory = "0%";
  String temperature = "0°";

  String totalQueries = "0";
  String queriesBlocked = "0";
  String percentBlocked = "0";
  String blocklist = "0";
  String status = "";
  String clients_ever_seen = "";
  var myprotocol = "";
  var ipStatus = true;
  var deviceStatus = true;

  var _myservices = [];
  var _blockedServices = [];

  bool tokenStatus = true;

  var FTLVERSION = "";
  var CPU_UTILIZATION = "";
  var MEM_UTILIZATION = "";
  var USED_MEMORY = "";
  var FTL_STARTED = "";

  _getMyServices() async {
    var s = await dbHelper.queryAllRows("services");

    for (var i = 0; i < s.length; i++) {
      if (s[i]["status"] == "blocked") {
        setState(() {
          _blockedServices.add(s[i]);
        });
      }
    }

    setState(() {
      _myservices = s;
    });
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

  jsonToFormData(http.MultipartRequest request, Map<String, dynamic> data) {
    for (var key in data.keys) {
      request.fields[key] = data[key].toString();
    }
    return request;
  }

  void _popup() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color(0xFF0D1117).withOpacity(0.9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      color: Color(0xFF161B22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 5.0),
                        StatTab(title: "FTL VERSION", value: '$FTLVERSION'),
                        // Divider(),
                        // StatTab(
                        //     title: "PROCESS IDENTIFIER (PID)", value: '34'),
                        Divider(),
                        StatTab(
                            title: "TIME FTL STARTED", value: '$FTL_STARTED'),
                        // Divider(),
                        // StatTab(title: "USER/GROUP", value: '34'),
                        Divider(),
                        StatTab(
                            title: "TOTAL CPU UTILIZATION",
                            value: '$CPU_UTILIZATION'),
                        Divider(),
                        StatTab(
                            title: "MEMORY UTILIZATION",
                            value: '$MEM_UTILIZATION'),
                        // Divider(),
                        // StatTab(title: "USED MEMORY", value: '$USED_MEMORY'),
                        // Divider(),
                        // StatTab(title: "DNS CACHE SIZE", value: '34'),
                        // Divider(),
                        // StatTab(title: "DNS CACHE INSERTIONS", value: '34'),
                        // Divider(),
                        // StatTab(title: "DNS CACHE EVICTIONS", value: '34'),
                        SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 10.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(6.0),
                      color: const Color(0xff3FB950),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: "SFNSR",
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          );
        });
  }

  fetchQueries() async {
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
    await testToken();
    var devices = await getDevices();

    if (devices[0]['validtoken'] == 0) {
      setState(() {
        tokenStatus = false;
      });
    }

    setState(() {
      myprotocol = devices[0]['protocol'];
    });

    Map<String, String> headers = {};

    var request = await http.MultipartRequest(
        'POST', Uri.parse('$myprotocol://${devices[0]['ip']}/admin/login.php'));
    request = jsonToFormData(request, {"pw": devices[0]['password']});
    var res = await request.send();
    print(res.headers['set-cookie']);

    var rawCookie = res.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }

    var sysdata = await http.post(
      Uri.parse('$myprotocol://${devices[0]['ip']}/admin/settings.php'),
      body: {},
      encoding: Encoding.getByName('utf-8'),
      headers: headers,
    );

    if (sysdata.statusCode == 200) {
      var document = parser.parse(sysdata.body);
      try {
        LineSplitter ls = new LineSplitter();

        for (var i = 0; i < 6; i++) {
          var table = document.getElementsByTagName('tr')[i];
          log('TABLE');
          List<String> tables = ls.convert(table.text.trim());
          print(tables);

          switch (i) {
            case 0:
              setState(() {
                FTLVERSION = tables[1].substring(56);
              });
              break;

            case 2:
              setState(() {
                FTL_STARTED = tables[1].substring(56);
              });
              break;

            case 4:
              setState(() {
                CPU_UTILIZATION = tables[1].substring(56);
              });
              break;

            case 5:
              setState(() {
                MEM_UTILIZATION = tables[1].substring(56);
              });
              break;

            default:
          }
        }

        var temp = document.getElementsByClassName('pull-left info')[0];

        List<String> lines = ls.convert(temp.text.trim());

        for (var n = 0; n < lines.length; n++) {
          if (n == 4) {
            var ext = lines[n].replaceAll(new RegExp(r'[^\.0-9]'), '');
            setState(() {
              var mytemp = double.parse(ext);
              assert(mytemp is double);
              temperature = mytemp.toStringAsFixed(1);
            });
          }

          if (n == 3) {
            var ext2 = lines[n].replaceAll(new RegExp(r'[^\.0-9]'), '');
            setState(() {
              memory = '$ext2%';
            });
          }
        }
      } catch (e) {
        print(e);
      }
    }

    var myurl = "$myprotocol://${devices[0]['ip']}";
    final response = await http.get(Uri.parse(
        '$myurl/admin/api.php?summary&auth=${devices[0]['apitoken']}'));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      QueryModel queryModel = QueryModel.fromMap(parsed);

      var data = {
        "name": devices[0]['name'],
        "ip": devices[0]['ip'],
        "temperature": temperature,
        "memory": memory,
        "totalQueries": queryModel.dns_queries_today,
        "queriesBlocked": queryModel.ads_blocked_today,
        "percentBlocked": queryModel.ads_percentage_today,
        "blocklist": queryModel.domains_being_blocked,
        "status": queryModel.status,
        "allClients": queryModel.clients_ever_seen,
        "apitoken": devices[0]['apitoken'],
      };

      setState(() {
        devices_data = [];
      });

      var timer = Timer(
        Duration(seconds: 1),
        () => setState(() {
          devices_data.add(data);
        }),
      );

      // timer.cancel();
    } else {
      // throw Exception("Unable to fetch query data");
      print("FETCH FAILED");
    }
  }

  enableBlocking(ip, token) async {
    var url = '$myprotocol://$ip';
    final response =
        await http.get(Uri.parse('$url/admin/api.php?enable&auth=$token'));
    setState(() {
      devices_data[0]['status'] = "enabled";
    });

    // await AwesomeNotifications().cancelAllSchedules();
  }

  disableBlocking(ip, token, seconds) async {
    var url = '$myprotocol://$ip';
    final response = await http
        .get(Uri.parse('$url/admin/api.php?disable=$seconds&auth=$token'));
    // await AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     id: 0,
    //     channelKey: 'blocking_channel',
    //     title: 'Pihole Enabled',
    //     body: 'Pihole blocking is now enabled',
    //     notificationLayout: NotificationLayout.BigText,
    //   ),
    //   schedule: NotificationCalendar(
    //     minute: Duration(seconds: seconds).inMinutes,
    //     repeats: false,
    //   ),
    // );

    Navigator.pop(context);
    setState(() {
      devices_data[0]['status'] = "disabled";
    });
  }

  setNotifyTime() {
    log('${DateTime.now().day}');
    log('${DateTime.now().hour}');
  }

  refreshScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => super.widget),
    );
  }

  deviceSettingsModal(context, id, name, ip, token) {
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
                  onPressed: () async {
                    final dbHelper = DatabaseHelper.instance;
                    await dbHelper.deleteTable('devices');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddDevices()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
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

  devices_list() {
    // print(devices_data.length);
    if (deviceStatus == false) {
      return NoDevices(context: context);
    }

    if (ipStatus == false) {
      return Disconnected(context: context);
    }

    if (tokenStatus == false) {
      return InvalidToken(context: context);
    }

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
                              fontFamily: pBold,
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
                        deviceSettingsModal(
                            context,
                            devices_data[i]['name'],
                            devices_data[i]['_id'],
                            devices_data[i]['ip'],
                            devices_data[i]['apitoken']);
                      },
                      child: Container(),
                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: 10.0),
                      //   child: Icon(
                      //     CupertinoIcons.ellipsis,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ),
                  ),
                ],
              ),
            ),
            devices_data[i]['temperature'] == "0°"
                ? Container(
                    margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    width: double.infinity,
                    child: Text(
                      'Add your pihole admin password to view system stats in the "Manage Devices" section',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: "SFSNR",
                        color: Colors.red,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      _popup();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stats(
                          temperature: devices_data[i]['temperature'],
                          memoryUsage: devices_data[i]['memory'],
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
            // const SizedBox(height: 20.0),
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
            SizedBox(height: 5.0),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.only(
                top: 15.0,
                bottom: 15.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: const Color(0xFF161B22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Text(
                      "Blocked services",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: pBold,
                        color: Color(0xff3FB950),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  for (var i = 0; i < _blockedServices.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15.0,
                              right: 15.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.xmark_shield_fill,
                                  color: Colors.redAccent,
                                  size: 20.0,
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  "${_blockedServices[i]['name']}",
                                  style: TextStyle(
                                    fontFamily: "SFNSR",
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          i == _blockedServices.length - 1
                              ? SizedBox(height: 5.0)
                              : Column(
                                  children: [
                                    SizedBox(height: 10.0),
                                    Divider(
                                      color: Colors.grey.withOpacity(0.04),
                                      thickness: 2.0,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  _blockedServices.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 15.0,
                            right: 15.0,
                          ),
                          child: Text(
                            "No blocked services",
                            style: TextStyle(
                              fontFamily: "SFNSR",
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(height: 15.0),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              child: CupertinoButton(
                padding: const EdgeInsets.all(10.0),
                color: const Color(0xff3FB950),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Block services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: pRegular,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Blocked()),
                  );
                },
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              child: CupertinoButton(
                padding: const EdgeInsets.all(10.0),
                color: const Color(0xFF161B22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    devices_data[i]['status'] == 'enabled'
                        ? Text(
                            'Disable blocking',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14.0,
                              fontFamily: pRegular,
                            ),
                          )
                        : Text(
                            'Enable blocking',
                            style: TextStyle(
                              color: Color(0xff3FB950),
                              fontSize: 14.0,
                              fontFamily: pRegular,
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

    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     log("[+] Notification not allowed.");
    //   } else {
    //     log("[+] Notification is allowed.");
    //   }
    // });
    // checkToken();
    _getMyServices();
    fetchQueries();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFF0D1117),
        child: CustomScrollView(
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
                  "Home",
                  style: TextStyle(
                    fontFamily: pBold,
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5.0,
                    right: 20.0,
                  ),
                  child: InkWell(
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      fetchQueries();
                    },
                    child: const Icon(
                      CupertinoIcons.arrow_counterclockwise,
                      color: Colors.white,
                      size: 23.0,
                    ),
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                        ),
                        child: devices_list(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatTab extends StatelessWidget {
  const StatTab({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 20.0,
        right: 20.0,
        bottom: 10.0,
      ),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'SFNSR',
              fontSize: 10.0,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            value,
            textAlign: TextAlign.start,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontFamily: 'AR',
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
