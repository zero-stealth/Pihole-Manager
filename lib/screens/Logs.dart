import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/screens/LiveLog.dart';
import 'package:piremote/screens/LogsHistory.dart';
import 'package:piremote/screens/Query.dart';
import 'package:piremote/widgets/Disconnected.dart';
import 'package:piremote/widgets/InvalidToken.dart';
import 'package:piremote/widgets/NoDevices.dart';
import 'package:piremote/widgets/NoLogs.dart';
import 'package:piremote/widgets/NoRequests.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  TextEditingController searchcontroller = TextEditingController();
  var logs = [];
  var status = "";
  var clients = [];
  var ipStatus = true;
  var deviceStatus = true;
  var nologs = false;
  var selectedClient = "none";
  var noRequest = false;
  var searchresult = [];
  var _isSearching = false;
  late ScrollController _scrollController;
  var _showBackToTopButton = false;

  var livelogStatus = false;
  bool _tokenstatus = true;

  _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  getDeviceNames() async {
    final dbHelper = DatabaseHelper.instance;
    var myclients = await dbHelper.queryAllRows('clients');

    setState(() {
      clients = myclients;
    });
  }

  deviceName(ip) {
    if (clients.length < 0) {
      return ip;
    } else {
      for (var i = 0; i < clients.length; i++) {
        if (clients[i]['ip'] == ip) {
          if (clients[i]['name'] != 'none') {
            return clients[i]['name'];
          } else {
            return ip;
          }
        }
      }
    }
  }

  calculateTime(timestamp) {
    try {
      var date =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      var formattedTime = DateFormat.jm().format(date);
      print("[TIME] $formattedTime");
      return formattedTime;
    } catch (e) {
      print(e);
      return timestamp.toString();
    }
  }

  calculateStatus(type, timestamp) {
    switch (type) {
      case '1':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.redAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Gravity list',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      case '2':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: Color(0xff3FB950),
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Upstream server',
                  style: TextStyle(
                    color: Color(0xff3FB950),
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Color(0xff3FB950),
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      case '3':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.blueAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Local cache',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      case '4':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.redAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Wildcard blocking',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 13.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );

      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.xmark_shield_fill,
                  color: Colors.redAccent,
                  size: 15.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Blacklist',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12.0,
                    fontFamily: pRegular,
                  ),
                ),
              ],
            ),
            Text(
              '$timestamp',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12.0,
                fontFamily: pRegular,
              ),
            ),
          ],
        );
    }
  }

  myLogs() {
    if (deviceStatus == false) {
      return Container(
        margin: EdgeInsets.all(20.0),
        child: NoDevices(context: context),
      );
    }

    if (nologs == true) {
      return NoLogs(context: context);
    }

    if (logs.length <= 0 && noRequest == true) {
      return NoRequests(context: context);
    }

    if (ipStatus == false) {
      return Disconnected(context: context);
    }

    if (_tokenstatus == false) {
      return InvalidToken(context: context);
    }

    if (logs.length > 0) {
      switch (searchcontroller.text.isNotEmpty) {
        case false:
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                clipBehavior: Clip.none,
                scrollDirection: Axis.vertical,
                itemCount: logs.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Query(
                            domain: "${logs[index][2]['domain'].toString()}",
                            client:
                                deviceName(logs[index][4]['client'].toString()),
                            type: "${logs[index][1]['requestType'].toString()}",
                            timestamp:
                                "${logs[index][0]['timestamp'].toString()}",
                            status: "${logs[index][3]['type'].toString()}",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: 10.0,
                      ),
                      padding: EdgeInsets.only(
                        bottom: 5.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            width: 2.0,
                            color: const Color(0xFF161B22).withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          calculateStatus(logs[index][3]['type'].toString(),
                              logs[index][0]['timestamp'].toString()),
                          SizedBox(height: 5.0),
                          Text(
                            '${logs[index][2]['domain'].toString()}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontFamily: pBold,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            deviceName(logs[index][4]['client'].toString()),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontFamily: pRegular,
                            ),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  );
                }),
          );

        case true:
          if (searchresult.isEmpty) {
            return Container(
              margin: EdgeInsets.only(top: 150.0),
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("No result found"),
                ],
              ),
            );
          } else {
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.vertical,
                  itemCount: searchresult.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Query(
                              domain:
                                  "${searchresult[index][2]['domain'].toString()}",
                              client: deviceName(
                                  searchresult[index][4]['client'].toString()),
                              type:
                                  "${searchresult[index][1]['requestType'].toString()}",
                              timestamp:
                                  "${searchresult[index][0]['timestamp'].toString()}",
                              status:
                                  "${searchresult[index][3]['type'].toString()}",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 10.0,
                        ),
                        padding: EdgeInsets.only(
                          bottom: 5.0,
                          left: 20.0,
                          right: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              width: 2.0,
                              color: const Color(0xFF161B22).withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            calculateStatus(
                                searchresult[index][3]['type'].toString(),
                                searchresult[index][0]['timestamp'].toString()),
                            SizedBox(height: 5.0),
                            Text(
                              '${searchresult[index][2]['domain'].toString()}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontFamily: pBold,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              deviceName(
                                  searchresult[index][4]['client'].toString()),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.0,
                                fontFamily: pRegular,
                              ),
                            ),
                            SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    );
                  }),
            );
          }
        default:
      }
    }

    if (logs.length <= 0 && noRequest == false) {
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
            ),
          ],
        ),
      );
    }
  }

  _fetchLogs() async {
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
      final res = await http.Client().post(Uri.parse(
          '${devices[i]['protocol']}://${devices[i]['ip']}/admin/api.php?getAllQueries=100&auth=${devices[i]['apitoken']}'));
      if (res.statusCode == 200) {
        var pars = jsonDecode(res.body);
        print(pars);

        if (pars['data'].length <= 0) {
          return setState(() {
            nologs = true;
          });
        }

        for (var n = 0; n < pars['data'].length; n++) {
          var data = [
            {'timestamp': calculateTime(pars['data'][n][0])},
            {'requestType': pars['data'][n][1]},
            {'domain': pars['data'][n][2]},
            {'type': pars['data'][n][4]},
            {'client': pars['data'][n][3]},
          ];

          if (selectedClient == "none") {
            setState(() {
              logs.add(data);
            });
          }

          if (selectedClient != "none") {
            if (pars['data'][n][3] == selectedClient) {
              setState(() {
                logs.add(data);
              });
            }
          }
        }
      }
    }

    Iterable inReverse = logs.reversed;

    setState(() {
      logs = inReverse.toList();
    });

    if (logs.length <= 0) {
      setState(() {
        noRequest = true;
      });
    }
  }

  _fetchClients() async {
    await testToken();
    var devices = await getDevices();

    if(devices[0]['validtoken'] == 0){
      setState(() {
        _tokenstatus = false;
      });
    }

    final dbHelper = DatabaseHelper.instance;
    var myclients = await dbHelper.queryAllRows('clients');

    setState(() {
      clients = myclients;
    });
  }

  filterByClient() {
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
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
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
                    const SizedBox(height: 10.0),
                    Text(
                      'Filter log',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: pBold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Sort your query logs by a client.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12.0,
                        fontFamily: pRegular,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    for (var i = 0; i < clients.length; i++)
                      Column(
                        children: [
                          SizedBox(height: 15.0),
                          InkWell(
                            onTap: () {
                              if (selectedClient == clients[i]['ip']) {
                                Navigator.pop(context);
                                setState(() {
                                  selectedClient = "none";
                                  noRequest = false;
                                });
                                setState(() {
                                  logs = [];
                                });
                                fetchLogs();
                              } else {
                                setState(() {
                                  selectedClient = clients[i]['ip'];
                                  noRequest = false;
                                });
                                Navigator.pop(context);
                                setState(() {
                                  logs = [];
                                });
                                fetchLogs();
                              }
                            },
                            child: Container(
                              //margin: EdgeInsets.only(top: 15.0),
                              width: double.infinity,
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: selectedClient == clients[i]['ip']
                                    ? Color(0xff3FB950)
                                    : Color(0xFF161B22),
                              ),
                              child: Text(
                                clients[i]['name'] == "none"
                                    ? clients[i]['ip']
                                    : clients[i]['name'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: selectedClient == clients[i]['ip']
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontSize: 14.0,
                                  fontFamily: pRegular,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  liveLog() async {
    if (logs.length > 200) {
      logs.removeRange(199, logs.length);
    }

    while (livelogStatus == true) {
      var timer = Timer(
        Duration(seconds: 2),
        () => setState(() async {
          await fetchLogs();
        }),
      );
    }
  }

  searchOperation(String searchText) {
    setState(() {
      searchresult.clear();
      for (int i = 0; i < logs.length; i++) {
        if (logs[i][2]['domain']
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          searchresult.add(logs[i]);
        }
      }
    });
  }

  scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 2), curve: Curves.easeIn);
  }

  

  @override
  void initState() {
    // TODO: implement initState
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true;
          } else {
            _showBackToTopButton = false;
          }
        });
      });

    super.initState();
    _fetchClients();
    getDeviceNames();
    _fetchLogs();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color(0xFF0D1117),
          child: CustomScrollView(
            controller: _scrollController,
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
                    "Logs",
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
                      right: 30.0,
                    ),
                    child: InkWell(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          logs = [];
                        });
                        fetchLogs();
                      },
                      child: const Icon(
                        CupertinoIcons.arrow_counterclockwise,
                        color: Colors.white,
                        size: 21.0,
                      ),
                    ),
                  ),
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
                        filterByClient();
                      },
                      child: const Icon(
                        CupertinoIcons.doc_text_search,
                        color: Colors.white,
                        size: 21.0,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 10.0),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LogsHistory(),
                              ),
                            );
                          },
                          child: const Icon(
                            CupertinoIcons.clock,
                            color: Colors.white,
                            size: 23.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Column(
                            children: [
                              // InkWell(
                              //   onTap: () async {
                              //     // setState(() {
                              //     //   livelogStatus = !livelogStatus;
                              //     // });

                              //     // await liveLog();
                              //     // fetchLogs();

                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => LiveLog(),
                              //       ),
                              //     );
                              //   },
                              //   child: Container(
                              //     width: double.infinity,
                              //     padding: EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Row(
                              //           mainAxisAlignment: MainAxisAlignment.start,
                              //           children: [
                              //             Icon(
                              //               CupertinoIcons.waveform_circle,
                              //               color: livelogStatus == true
                              //                   ? Color(0xff3FB950)
                              //                   : Colors.redAccent,
                              //               size: 22.0,
                              //             ),
                              //             SizedBox(width: 15.0),
                              //             Text(
                              //               "Live log",
                              //               style: TextStyle(
                              //                 fontFamily: pBold,
                              //                 fontSize: 15.0,
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //         Container(
                              //           padding: EdgeInsets.only(
                              //             top: 4.0,
                              //             bottom: 4.0,
                              //             left: 10.0,
                              //             right: 10.0,
                              //           ),
                              //           decoration: BoxDecoration(
                              //             color: livelogStatus == true
                              //                 ? Color(0xff3FB950).withOpacity(0.2)
                              //                 : Colors.redAccent.withOpacity(0.2),
                              //             borderRadius: BorderRadius.circular(50.0),
                              //           ),
                              //           child: Center(
                              //             child: Text(
                              //               livelogStatus == true ? "ON" : "OFF",
                              //               style: TextStyle(
                              //                 color: livelogStatus == true
                              //                     ? Color(0xff3FB950)
                              //                     : Colors.redAccent,
                              //                 fontSize: 12.0,
                              //                 fontFamily: pBold,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 15.0,
                                  right: 15.0,
                                  bottom: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D1117),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          75,
                                      child: CupertinoTextField(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0D1117),
                                        ),
                                        scrollPhysics:
                                            const BouncingScrollPhysics(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        controller: searchcontroller,
                                        onChanged: (text) {
                                          searchOperation(text);
                                        },
                                        maxLines: 1,
                                        placeholder: "Search domain",
                                        placeholderStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.2),
                                          fontFamily: pRegular,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          searchcontroller.clear();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.clear_circled,
                                        color: searchcontroller.text.isEmpty
                                            ? Colors.grey.withOpacity(0.2)
                                            : Color(0xff3FB950),
                                        size: 20.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.0),
                              myLogs(),
                              SizedBox(height: 100.0),
                            ],
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
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
              bottom: 100.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _showBackToTopButton == true
                    ? InkWell(
                        onTap: () {
                          scrollToTop();
                        },
                        child: Container(
                          padding: EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: Color(0xff3FB950),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Icon(
                            CupertinoIcons.chevron_up,
                            size: 22.0,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
