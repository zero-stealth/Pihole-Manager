import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/screens/Dashboard.dart';
import 'package:piremote/widgets/InputWidget.dart';

class AddDevices extends StatefulWidget {
  const AddDevices({Key? key}) : super(key: key);

  @override
  State<AddDevices> createState() => _AddDevicesState();
}

class _AddDevicesState extends State<AddDevices> {
  TextEditingController ipcontroller = TextEditingController();
  TextEditingController tokencontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();

  String buttonState = "notloading";

  bool piholeStatus = false;
  String piholeStatusMessage = "";

  bool tokenStatus = false;
  String tokenStatusMessage = "";

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ipcontroller.addListener(() {
      print(ipcontroller.text);
    });

    tokencontroller.addListener(() {
      print(tokencontroller.text);
    });

    namecontroller.addListener(() {
      print(namecontroller.text);
    });
  }

  test_ip(name, ip, token) async {
    try {
      var url = 'http://$ip';
      // /admin/api.php?getAllQueries=100&auth=
      final response = await http.get(Uri.parse('$url/admin/api.php?summary'));
      if (response.statusCode == 200) {
        setState(() {
          piholeStatus = true;
          piholeStatusMessage = "Pihole ip is active.";
        });
        test_token(name, ip, token);
      } else {
        setState(() {
          piholeStatus = false;
          piholeStatusMessage = "Pihole not found on ip $ip";
          buttonState = "notloading";
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        piholeStatus = false;
        piholeStatusMessage = "Pihole not found on ip $ip";
        buttonState = "notloading";
      });
    }
  }

  test_token(name, ip, token) async {
    final dbHelper = DatabaseHelper.instance;

    var url = 'http://$ip';
    // /admin/api.php?getAllQueries=100&auth=
    final resp = await http
        .get(Uri.parse('$url/admin/api.php?getAllQueries=100&auth=$token'));

    if (resp.statusCode == 200) {
      final parsed = json.decode(resp.body);
      if (parsed.length == 0) {
        setState(() {
          tokenStatus = false;
          tokenStatusMessage = "Invalid Api token";
          buttonState = "notloading";
        });
      } else {
        var devices = await dbHelper.queryAllRows('devices');
        print(devices);

        for (var i = 0; i < devices.length; i++) {
          if (devices[i]['ip'] == ip) {
            return setState(() {
              piholeStatus = false;
              piholeStatusMessage = "Pihole ip is already saved.";
              buttonState = "notloading";
            });
            break;
          }
        }

        Map<String, dynamic> row = {
          "name": name,
          "ip": ip,
          "apitoken": token,
        };

        await dbHelper.insert(row, "devices");

        setState(() {
          tokenStatus = true;
          tokenStatusMessage = "Api token is functional.";
          buttonState = "notloading";
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
    } else {
      setState(() {
        tokenStatus = false;
        tokenStatusMessage = "Invalid Api token";
        buttonState = "notloading";
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // const Color(0xFF0D1117)
      backgroundColor: const Color(0xFF0D1117),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   width: double.infinity,
              //   child: Text(
              //     'Config',
              //     textAlign: TextAlign.start,
              //     style: TextStyle(
              //       fontSize: 16.0,
              //       color: Color(0xff3FB950),
              //       fontFamily: "SFD-Bold",
              //     ),
              //   ),
              // ),
              const SizedBox(height: 15.0),
              InputWidget(
                namecontroller: namecontroller,
                label: "Device Name",
                placeholder: "Mainframe",
              ),
              SizedBox(height: 15.0),
              InputWidget(
                namecontroller: ipcontroller,
                label: "Pihole ip address",
                placeholder: "192.168.0.1",
              ),
              const SizedBox(height: 15.0),
              InputWidget(
                namecontroller: tokencontroller,
                label: "Pihole api token",
                placeholder: "token",
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
                    print(
                      'ip address: ${ipcontroller.text} api token: ${tokencontroller.text}',
                    );

                    if (ipcontroller.text.isEmpty ||
                        tokencontroller.text.isEmpty ||
                        namecontroller.text.isEmpty) {
                      setState(() {
                        piholeStatus = false;
                        piholeStatusMessage = "Fill all fields idiot!";
                      });
                    } else {
                      setState(() {
                        buttonState = "loading";
                        piholeStatus = false;
                        tokenStatus = false;
                        piholeStatusMessage = "";
                        tokenStatusMessage = "";
                      });

                      test_ip(
                        namecontroller.text,
                        ipcontroller.text,
                        tokencontroller.text,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 0.0),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 20.0,
                  left: 0.0,
                  right: 0.0,
                ),
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(6.0),
                  color: const Color.fromARGB(255, 16, 21, 27),
                  child: const Text(
                    'Never mind',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xff3FB950),
                      fontFamily: "SFD-Bold",
                    ),
                  ),
                  onPressed: () async {
                    final dbHelper = DatabaseHelper.instance;
                    var d = await dbHelper.queryAllRows('devices');

                    if (d.length > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard()),
                      );
                    } else {
                      print("[+] No devices in database");
                    }
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
    );
  }
}


class Notifier extends StatelessWidget {
  final bool active;
  final String message;

  Notifier({
    required this.active,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (active == true) {
      return Container(
        // padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.check_mark_circled,
              color: Color(0xff3FB950),
              size: 20.0,
            ),
            SizedBox(width: 10.0),
            Text(
              message,
              style: TextStyle(
                color: Color(0xff3FB950),
                fontFamily: "SFT-Regular",
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      );
    } else {
      if (active == false && message.length > 0) {
        return Container(
          // padding: EdgeInsets.all(15.0),
          margin: EdgeInsets.only(bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.xmark_circle,
                color: Colors.redAccent,
                size: 20.0,
              ),
              SizedBox(width: 10.0),
              Text(
                message,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: "SFT-Regular",
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    }
  }
}
