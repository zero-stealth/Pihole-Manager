import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/widgets/Disconnected.dart';
import 'package:piremote/widgets/InvalidToken.dart';
import 'package:piremote/widgets/NoDevices.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List clients = [];
  List topQueries = [];
  List topAds = [];
  var ipStatus = true;
  var deviceStatus = true;
  bool _tokenstatus = true;

  all() {
    if (deviceStatus == false) {
      return NoDevices(context: context);
    }

    if (ipStatus == false) {
      return Disconnected(context: context);
    }

    if (_tokenstatus == false) {
      return InvalidToken(context: context);
    }

    return Column(
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
              myads(),
            ],
          ),
        ),
        SizedBox(height: 100.0)
      ],
    );
  }

  myclients() {
    if (clients.length > 0) {
      print('${clients}');
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                      fontFamily: pBold,
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
          MediaQuery.removePadding(
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
                                clients[index]['name'] != "none"
                                    ? '${clients[index]['name'].toString()}'
                                    : '${clients[index]['ip'].toString()}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontFamily: pRegular,
                                  // fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            clients[index]['requests'].toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontFamily: pRegular,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                    ],
                  );
                }),
          ),
        ],
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
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                      fontFamily: pBold,
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
          MediaQuery.removePadding(
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
                                    fontFamily: pRegular,
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
                                fontFamily: pRegular,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  );
                }),
          ),
        ],
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
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                      fontFamily: pBold,
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
          MediaQuery.removePadding(
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
                                  fontFamily: pRegular,
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
                              fontFamily: pRegular,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                    ],
                  );
                }),
          ),
        ],
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
          '${devices[i]['protocol']}://${devices[i]['ip']}/admin/api.php?topItems&auth=${devices[i]['apitoken']}'));
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

          // setState(() {
          //   topQueries = [];
          // });

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

          // setState(() {
          //   topAds = [];
          // });

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

    if(devices[0]['validtoken'] == 0){
      setState(() {
        _tokenstatus = false;
      });
    }

    final dbHelper = DatabaseHelper.instance;
    var myclients = await dbHelper.queryAllRowsNormal('clients');

    setState(() {
      clients = myclients;
    });
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
    setClients();
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
                  "Statistics",
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
                    onTap: () async {
                      setState(() {
                        topAds = [];
                        topQueries = [];
                        clients = [];
                      });
                      await setClients();
                      await fetchTopClients();
                      await fetchTopQueries();
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
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                        ),
                        child: all(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
