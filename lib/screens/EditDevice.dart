import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/screens/AddDevices.dart';
import 'package:piremote/widgets/InputWidget.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class EditDevice extends StatefulWidget {
  const EditDevice({Key? key}) : super(key: key);

  @override
  State<EditDevice> createState() => _EditDeviceState();
}

class _EditDeviceState extends State<EditDevice> {
  TextEditingController ipcontroller = TextEditingController();
  TextEditingController tokencontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();

  buttonStatus(buttonState) {
    switch (buttonState) {
      case "loading":
        return LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 25.0,
        );
      default:
        return Text(
          'Save',
          style: TextStyle(
            fontSize: 14.0,
            fontFamily: "SFD-Bold",
          ),
        );
    }
  }

  String buttonState = "notloading";

  bool piholeStatus = false;
  String piholeStatusMessage = "";

  bool tokenStatus = false;
  String tokenStatusMessage = "";
  int? protocol = 0;
  int id = 0;

  final dbHelper = DatabaseHelper.instance;

  currentData() async {
    var device = await dbHelper.queryAllRows('devices');

    namecontroller.text = device[0]['name'];
    ipcontroller.text = device[0]['ip'];
    tokencontroller.text = device[0]['apitoken'];

    setState(() {
      id = device[0]['_id'];
    });

    switch (device[0]['protocol']) {
      case "http":
        setState(() {
          protocol = 0;
        });
        break;

      case "https":
        setState(() {
          protocol = 1;
        });
        break;
      default:
    }
  }

  setProtocol() {
    switch (protocol) {
      case 0:
        return "http";

      case 1:
        return "https";
      default:
    }
  }

  updateData() async {
    Map<String, dynamic> row = {
      "_id": id,
      "ip": ipcontroller.text,
      "name": namecontroller.text,
      "protocol": await setProtocol(),
      "apitoken": tokencontroller.text,
    };

    await dbHelper.update(row, "devices");
    updatedModal(context);
  }

  test_ip() async {
    var prot = await setProtocol();

    try {
      var url = '$prot://${ipcontroller.text}';
      // /admin/api.php?getAllQueries=100&auth=
      final response = await http.get(Uri.parse('$url/admin/api.php?summary'));
      if (response.statusCode == 200) {
        setState(() {
          piholeStatus = true;
          piholeStatusMessage = "Pihole ip is active.";
        });
        test_token();
      } else {
        setState(() {
          piholeStatus = false;
          piholeStatusMessage =
              "Pihole not found on $prot://${ipcontroller.text}";
          buttonState = "notloading";
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        piholeStatus = false;
        piholeStatusMessage =
            "Pihole not found on ip $prot://${ipcontroller.text}";
        buttonState = "notloading";
      });
    }
  }

  updatedModal(context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      )),
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1117),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return Padding(
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
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: const Color(0xFF0D1117),
                        ),
                        child: Icon(
                          CupertinoIcons.hand_thumbsup_fill,
                          color: Color(0xff3FB950),
                          size: 100.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 10.0,
                      left: 0.0,
                      right: 0.0,
                    ),
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(6.0),
                      color: const Color(0xFF161B22),
                      child: Text(
                        'Updated successfully',
                        style: TextStyle(
                          color: Color(0xff3FB950),
                          fontSize: 12.0,
                          fontFamily: "SFT-Regular",
                        ),
                      ),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  test_token() async {
    var prot = await setProtocol();
    var url = '$prot://${ipcontroller.text}';
    // /admin/api.php?getAllQueries=100&auth=
    final resp = await http.get(Uri.parse(
        '$url/admin/api.php?getAllQueries=100&auth=${tokencontroller.text}'));

    if (resp.statusCode == 200) {
      final parsed = json.decode(resp.body);
      if (parsed.length == 0) {
        setState(() {
          tokenStatus = false;
          tokenStatusMessage = "Invalid Api token";
          buttonState = "notloading";
        });
      } else {
        setState(() {
          buttonState = "notloading";
          tokenStatusMessage = "";
          piholeStatusMessage = "";
          piholeStatus = false;
          tokenStatus = false;
        });
        updateData();
      }
    } else {
      setState(() {
        tokenStatus = false;
        tokenStatusMessage = "Invalid Api token";
        buttonState = "notloading";
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
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
                      'Manage device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: 'SFD-Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25.0),
                InputWidget(
                  namecontroller: namecontroller,
                  label: "Device Name",
                  placeholder: namecontroller.text,
                  lines: 1,
                  qrcode: false,
                ),
                SizedBox(height: 15.0),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    top: 5.0,
                    bottom: 20.0,
                  ),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: Color(0xFF161B22),
                    thumbColor: Color(0xff3FB950),
                    groupValue: protocol,
                    children: {
                      0: Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0)),
                        child: Text(
                          "http",
                          style: TextStyle(
                            fontSize: 12.0,
                            // color: Color(0xff3FB950),
                            color: Colors.white,
                            fontFamily: 'SFD-Bold',
                          ),
                        ),
                      ),
                      1: Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0)),
                        child: Text(
                          "https",
                          style: TextStyle(
                            fontSize: 12.0,
                            // color: Color(0xff3FB950),
                            color: Colors.white,
                            fontFamily: 'SFD-Bold',
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        protocol = value as int?;
                      });
                    },
                  ),
                ),
                InputWidget(
                  namecontroller: ipcontroller,
                  label: "Pihole ip address",
                  placeholder: ipcontroller.text,
                  lines: 1,
                  qrcode: false,
                ),
                const SizedBox(height: 20.0),
                InputWidget(
                  namecontroller: tokencontroller,
                  label: "Pihole api token",
                  placeholder: tokencontroller.text,
                  lines: 1,
                  qrcode: false,
                ),
                SizedBox(height: 25.0),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 10.0,
                    left: 0.0,
                    right: 0.0,
                  ),
                  child: CupertinoButton(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xff3FB950),
                    child: buttonStatus(buttonState),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      log("${namecontroller.text} - ${ipcontroller.text}");
                      setState(() {
                        buttonState = "loading";
                      });
                      test_ip();
                    },
                  ),
                ),
                const SizedBox(height: 4.0),
                Notifier(
                  active: piholeStatus,
                  message: piholeStatusMessage,
                ),
                Notifier(
                  active: tokenStatus,
                  message: tokenStatusMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
