import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/screens/Dashboard.dart';

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
          margin: EdgeInsets.symmetric(
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
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                child: Text(
                  'Device Name',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xff3FB950),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                  ),
                  scrollPhysics: BouncingScrollPhysics(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: namecontroller,
                  onChanged: (text) {},
                  maxLines: 1,
                  placeholder: "Mainframe",
                  placeholderStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.2),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                child: Text(
                  'Pihole ip address',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xff3FB950),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                  ),
                  scrollPhysics: BouncingScrollPhysics(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: ipcontroller,
                  onChanged: (text) {},
                  maxLines: 1,
                  placeholder: "192.168.0.1",
                  placeholderStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.2),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                child: Text(
                  'Pihole api token',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xff3FB950),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                  ),
                  scrollPhysics: BouncingScrollPhysics(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: tokencontroller,
                  onChanged: (text) {},
                  maxLines: 1,
                  placeholder: "token",
                  placeholderStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.2),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 25.0),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: 10.0,
                  left: 0.0,
                  right: 0.0,
                ),
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(6.0),
                  color: Color(0xff3FB950),
                  child: buttonStatus(buttonState),
                  onPressed: () {
                    print(
                      'ip address: ${ipcontroller.text} api token: ${tokencontroller.text}',
                    );

                    if (ipcontroller.text.length == 0 ||
                        tokencontroller.text.length == 0 ||
                        namecontroller.text.length == 0) {
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
                margin: EdgeInsets.only(
                  bottom: 20.0,
                  left: 0.0,
                  right: 0.0,
                ),
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(6.0),
                  color: Color.fromARGB(255, 16, 21, 27),
                  child: Text(
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
              SizedBox(height: 4.0),
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
