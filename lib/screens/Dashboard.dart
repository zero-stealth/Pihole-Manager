import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: CustomScrollView(
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
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => Notifications()),
                    // );
                  },
                  child: const Icon(
                    CupertinoIcons.plus,
                    color: Colors.white,
                    size: 23.0,
                  ),
                ),
              ),
              const SizedBox(width: 28.0),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5.0,
                  right: 20.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Settings()),
                    // );
                  },
                  child: const Icon(
                    CupertinoIcons.settings_solid,
                    color: Colors.white,
                    size: 23.0,
                  ),
                ),
              )
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
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Icon(
                                CupertinoIcons.check_mark_circled_solid,
                                color: Color(0xff3FB950),
                                size: 20.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                "Pi 4",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "SFD-Bold",
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Panels(
                          firstLabel: "Total Queries",
                          firstValue: "45,334",
                          secondLabel: "Queries Blocked",
                          secondValue: "5,333",
                        ),
                        Panels(
                          firstLabel: "Percent Blocked",
                          firstValue: "8.8%",
                          secondLabel: "Blocklist",
                          secondValue: "133,556",
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
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class Panels extends StatelessWidget {
  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;

  Panels(
      {required this.firstLabel,
      required this.firstValue,
      required this.secondLabel,
      required this.secondValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 50) / 2,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFF161B22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstLabel,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontFamily: "SFD-Bold",
                      color: Color(0xff3FB950),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    firstValue,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "SFT-Regular",
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: (MediaQuery.of(context).size.width - 50) / 2,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFF161B22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    secondLabel,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontFamily: "SFD-Bold",
                      color: Color(0xff3FB950),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    secondValue,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "SFT-Regular",
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10.0)
      ],
    );
  }
}
