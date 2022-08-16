import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/models/QueryModel.dart';
import 'package:piremote/screens/AddDevices.dart';
import 'package:piremote/widgets/Disconnected.dart';
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

    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

    for (var i = 0; i < devices.length; i++) {
      setState(() {
        myprotocol = devices[i]['protocol'];
      });
      final resp = await http.Client()
          .get(Uri.parse('$myprotocol://${devices[i]['ip']}/admin/'));
      if (resp.statusCode == 200) {
        var document = parser.parse(resp.body);
        try {
          var temp = document.getElementsByClassName('pull-left info')[0];

          LineSplitter ls = new LineSplitter();
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
      } else {
        print("FETCH FAILED.");
      }

      var myurl = "$myprotocol://${devices[i]['ip']}";
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
        // throw Exception("Unable to fetch query data");
        print("FETCH FAILED");
      }
    }
  }

  enableBlocking(ip, token) async {
    var url = '$myprotocol://$ip';
    final response =
        await http.get(Uri.parse('$url/admin/api.php?enable&auth=$token'));
    setState(() {
      devices_data[0]['status'] = "enabled";
    });
  }

  disableBlocking(ip, token, seconds) async {
    var url = '$myprotocol://$ip';
    final response = await http
        .get(Uri.parse('$url/admin/api.php?disable=$seconds&auth=$token'));
    Navigator.pop(context);
    setState(() {
      devices_data[0]['status'] = "disabled";
    });
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        devices_list(),
      ],
    );
  }
}
