import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List clients = [];
  List topQueries = [];
  List topAds = [];

  myclients() {
    if (clients.length > 0) {
      print('${clients}');
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            itemCount: clients.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          child: Text(
                            '${clients[index][0]['ip'].toString()}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontFamily: "SFT-Regular",
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        clients[index][1]['requests'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontFamily: "SFT-Regular",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                ],
              );
            }),
      );
    } else {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Color(0xff3FB950),
              size: 20.0,
            )
          ],
        ),
      );
    }
  }

  myqueries() {
    if (topQueries.length > 0) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            itemCount: topQueries.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              topQueries[index][0]['url'].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "SFT-Regular",
                                fontSize: 13.0,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          topQueries[index][1]['requests'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontFamily: "SFT-Regular",
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.0),
                ],
              );
            }),
      );
    } else {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Color(0xff3FB950),
              size: 20.0,
            )
          ],
        ),
      );
    }
  }

  myads() {
    if (topAds.length > 0) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            itemCount: topAds.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          // padding: EdgeInsets.only(right: 10.0),
                          child: Text(
                            topAds[index][0]['url'].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.white,
                              fontFamily: "SFT-Regular",
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        topAds[index][1]['requests'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontFamily: "SFT-Regular",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                ],
              );
            }),
      );
    } else {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Color(0xff3FB950),
              size: 20.0,
            )
          ],
        ),
      );
    }
  }

  fetchTopQueries() async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

    for (var i = 0; i < devices.length; i++) {
      final res = await http.Client().get(Uri.parse(
          'http://${devices[i]['ip']}/admin/api.php?topItems&auth=${devices[i]['apitoken']}'));
      if (res.statusCode == 200) {
        var pars = jsonDecode(res.body);
        // print('CLIENTS: $pars');
        // print(pars['top_sources'].keys.elementAt(2));

        // print(pars['top_sources'].length);

        for (var i = 0; i < pars['top_queries'].length; i++) {
          var key = pars['top_queries'].keys.elementAt(i);
          var value = pars['top_queries']['$key'];
          var data = [
            {'url': key},
            {'requests': value}
          ];

          setState(() {
            topQueries.add(data);
          });
        }

        for (var i = 0; i < pars['top_ads'].length; i++) {
          var key = pars['top_ads'].keys.elementAt(i);
          var value = pars['top_ads']['$key'];
          var data = [
            {'url': key},
            {'requests': value}
          ];

          setState(() {
            topAds.add(data);
          });
        }
      } else {
        return;
      }
    }
  }

  fetchTopClients() async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

    for (var i = 0; i < devices.length; i++) {
      final res = await http.Client().get(Uri.parse(
          'http://${devices[i]['ip']}/admin/api.php?topClients&auth=${devices[i]['apitoken']}'));
      if (res.statusCode == 200) {
        var pars = jsonDecode(res.body);
        // print('CLIENTS: $pars');
        // print(pars['top_sources'].keys.elementAt(2));

        // print(pars['top_sources'].length);

        for (var i = 0; i < pars['top_sources'].length; i++) {
          var key = pars['top_sources'].keys.elementAt(i);
          var value = pars['top_sources']['$key'];
          var data = [
            {'ip': key},
            {'requests': value}
          ];

          setState(() {
            clients.add(data);
          });
        }
      } else {
        return;
      }
    }
  }

  refresh() {
    print('refreshed');
    fetchTopClients();
    fetchTopQueries();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTopClients();
    fetchTopQueries();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('Dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        await refresh();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 15.0,
              bottom: 10.0,
              left: 15.0,
              right: 15.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          CupertinoIcons.device_laptop,
                          color: Color(0xff3FB950),
                          size: 20.0,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'Top Clients',
                          style: TextStyle(
                            color: Color(0xff3FB950),
                            fontFamily: "SFD-Bold",
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    // Icon(
                    //   CupertinoIcons.chevron_forward,
                    //   color: Color(0xff3FB950),
                    // ),
                  ],
                ),
                SizedBox(height: 12.0),
                myclients(),
                // manage btn
                // SizedBox(height: 10.0),
                // CupertinoButton(
                //   padding: const EdgeInsets.all(10.0),
                //   color: const Color(0xFF0D1117),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         'Manage clients',
                //         style: TextStyle(
                //           color: Color(0xff3FB950),
                //           fontSize: 14.0,
                //           fontFamily: 'SFT-Regular',
                //         ),
                //       ),
                //     ],
                //   ),
                //   onPressed: () {},
                // ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.only(
              top: 15.0,
              bottom: 10.0,
              left: 15.0,
              right: 15.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          CupertinoIcons.checkmark_shield_fill,
                          color: Color(0xff3FB950),
                          size: 22.0,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'Top Allowed',
                          style: TextStyle(
                            color: Color(0xff3FB950),
                            fontFamily: "SFD-Bold",
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    // Icon(
                    //   CupertinoIcons.chevron_forward,
                    //   color: Color(0xff3FB950),
                    // ),
                  ],
                ),
                SizedBox(height: 12.0),
                myqueries(),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.only(
              top: 15.0,
              bottom: 10.0,
              left: 15.0,
              right: 15.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          CupertinoIcons.xmark_shield_fill,
                          color: Colors.redAccent,
                          size: 22.0,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'Top Blocked',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: "SFD-Bold",
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    // Icon(
                    //   CupertinoIcons.chevron_forward,
                    //   color: Colors.redAccent,
                    // ),
                  ],
                ),
                SizedBox(height: 12.0),
                myads(),
              ],
            ),
          ),
          SizedBox(height: 100.0)
        ],
      ),
    );
  }
}
