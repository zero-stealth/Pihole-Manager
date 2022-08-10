import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/screens/Blocked.dart';
import 'package:piremote/screens/Clients.dart';
import 'package:piremote/screens/EditDevice.dart';
import 'package:piremote/widgets/Disconnected.dart';
import 'package:piremote/widgets/InputWidget.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController messagecontroller = TextEditingController();
  String buttonState = 'notloading';
  var ipStatus = true;

  all() {
    if (ipStatus == false) {
      return Disconnected(context: context);
    }

    return Container(
      padding: EdgeInsets.only(
        top: 16.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: double.infinity,
      child: Column(
        children: [
          SettingsItem(
            icon: CupertinoIcons.gear_alt_fill,
            name: "Manage clients",
            subtitle: "Manage pihole users",
            iconSize: 22.0,
            borderStatus: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Clients()),
              );
            },
          ),
          SettingsItem(
            icon: CupertinoIcons.wrench_fill,
            name: "Manage device",
            subtitle: "Manage pihole instances",
            iconSize: 22.0,
            borderStatus: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditDevice()),
              );
            },
          ),
          SettingsItem(
            icon: CupertinoIcons.xmark_shield_fill,
            name: "Blocked services",
            subtitle: "Manage popular services",
            iconSize: 22.0,
            borderStatus: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Blocked()),
              );
            },
          ),
          SettingsItem(
            icon: CupertinoIcons.chat_bubble_fill,
            name: "Feature suggestion",
            subtitle: "Your feature ideas",
            iconSize: 20.0,
            borderStatus: true,
            onPressed: () {
              feedbackModal(context);
            },
          ),
          SettingsItem(
            icon: CupertinoIcons.info_circle_fill,
            name: "Changelog",
            subtitle: "Latest changes",
            borderStatus: false,
            iconSize: 22.0,
            onPressed: () {
              aboutModal(context);
            },
          ),
        ],
      ),
    );
  }

  check() async {
    var status = await test_ip();
    if (status == false) {
      return setState(() {
        ipStatus = false;
      });
    }
  }

  buttonStatus() {
    switch (buttonState) {
      case "loading":
        return LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 25.0,
        );
      case "notloading":
        return Text(
          'Send',
          style: TextStyle(
            fontSize: 14.0,
            fontFamily: "SFT-Regular",
          ),
        );
    }
  }

  aboutModal(context) {
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
                  // const SizedBox(height: 30.0),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Container(
                  //       padding: EdgeInsets.all(20.0),
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(50.0),
                  //         color: const Color(0xFF0D1117),
                  //       ),
                  //       child: Icon(
                  //         CupertinoIcons.doc_on_clipboard_fill,
                  //         color: Color(0xff3FB950),
                  //         size: 100.0,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Changelog',
                    style: TextStyle(
                      color: Color(0xff3FB950),
                      fontSize: 18.0,
                      fontFamily: 'SFD-Bold',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChangelogItem(message: 'Block popular services.'),
                      ChangelogItem(message: 'Enable and disable pihole.'),
                      ChangelogItem(message: 'View pihole statistics.'),
                      ChangelogItem(message: 'View query logs.'),
                      ChangelogItem(message: 'Blacklist and whitelist domains.'),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(6.0),
                      color: const Color(0xFF161B22),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xff3FB950),
                          fontSize: 12.0,
                          fontFamily: "SFT-Regular",
                        ),
                      ),
                      onPressed: () {
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

  thanksModal(context) {
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
                        'Thanks for the feedback!',
                        style: TextStyle(
                          color: Color(0xff3FB950),
                          fontSize: 12.0,
                          fontFamily: "SFT-Regular",
                        ),
                      ),
                      onPressed: () {
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

  feedbackModal(context) {
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
                  const SizedBox(height: 22.0),
                  InputWidget(
                    namecontroller: messagecontroller,
                    label: "Feedback",
                    placeholder: 'Add a peanut butter dispenser.',
                    lines: 5,
                  ),
                  const SizedBox(height: 15.0),
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
                      child: buttonStatus(),
                      onPressed: () {
                        var mymessage = messagecontroller.text;
                        if (mymessage.length == 0) {
                          print("DO NOTHING");
                        } else {
                          sendHome(messagecontroller.text);
                          setState(() {});
                          Duration timeDelay = Duration(seconds: 4);
                          Timer(
                            timeDelay,
                            () => {
                              Navigator.pop(context),
                              setState(() {
                                messagecontroller.text = "";
                              }),
                              thanksModal(context),
                            },
                          );
                        }
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

  sendHome(message) async {
    setState(() {
      buttonState = 'loading';
    });
    final res = await http.Client().post(
      Uri.parse(dotenv.env['URL'].toString()),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'content': '**PIREMOTE FEEDBACK MESSAGE**\n$message',
        'name': dotenv.env['USERNAME'],
        'type': dotenv.env['TYPE'],
        'token': dotenv.env['TOKEN']
      }),
    );

    setState(() {
      buttonState = 'notloading';
    });
    return;
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
    check();
  }

  @override
  Widget build(BuildContext context) {
    return all();
  }
}

class ChangelogItem extends StatelessWidget {
  final String message;

  ChangelogItem({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.pin_fill,
            color: Color(0xff3FB950),
            size: 16.0,
          ),
          SizedBox(width: 10.0),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontFamily: "SFT-Regular",
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final double iconSize;
  final bool borderStatus;
  final Function onPressed;
  final String subtitle;

  SettingsItem({
    required this.name,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    required this.borderStatus,
    required this.subtitle,
  });

  myBorder(s) {
    if (s == true) {
      return Column(
        children: [
          SizedBox(height: 10.0),
          Divider(
            color: Colors.grey.withOpacity(0.04),
            thickness: 2.0,
          ),
          SizedBox(height: 10.0),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          enableFeedback: true,
          borderRadius: BorderRadius.circular(6.0),
          onTap: () {
            onPressed();
          },
          child: Container(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: Color(0xff3FB950),
                ),
                SizedBox(width: 15.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "SFT-Regular",
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12.0,
                        fontFamily: "SFT-Regular",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        myBorder(borderStatus),
      ],
    );
  }
}
