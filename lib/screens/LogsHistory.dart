import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/widgets/NoHistory.dart';

class LogsHistory extends StatefulWidget {
  const LogsHistory({Key? key}) : super(key: key);

  @override
  State<LogsHistory> createState() => _LogsHistoryState();
}

class _LogsHistoryState extends State<LogsHistory> {
  var history = [
    // {
    //   "status": "blacklisted",
    //   "domain": "piholemanager.com",
    //   "client": "192.168.0.10",
    // },
    // {
    //   "status": "allowed",
    //   "domain": "piholemanager.com",
    //   "client": "192.168.0.10",
    // },
    // {
    //   "status": "blacklisted",
    //   "domain": "piholemanager.com",
    //   "client": "192.168.0.10",
    // },
  ];

  actionHandler(status) {
    switch (status) {
      case "blacklisted":
        return Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: Color(0xff3FB950).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.0)),
          child: Center(
            child: Icon(
              CupertinoIcons.checkmark_shield_fill,
              color: Color(0xff3FB950),
            ),
          ),
        );

      case "allowed":
        return Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.0)),
          child: Center(
            child: Icon(
              CupertinoIcons.checkmark_shield_fill,
              color: Colors.redAccent,
            ),
          ),
        );
    }
  }

  statusHandler(status) {
    switch (status) {
      case "blacklisted":
        return Text(
          "Blacklisted",
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: pRegular,
            fontSize: 12.0,
          ),
        );

      case "allowed":
        return Text(
          "Allowed",
          style: TextStyle(
            color: Color(0xff3FB950),
            fontFamily: pRegular,
            fontSize: 12.0,
          ),
        );
    }
  }

  myHistory() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          clipBehavior: Clip.none,
          scrollDirection: Axis.vertical,
          itemCount: history.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => Query(
                //       domain:
                //           "${logs[index][2]['domain'].toString()}",
                //       client: deviceName(
                //           logs[index][4]['client'].toString()),
                //       type:
                //           "${logs[index][1]['requestType'].toString()}",
                //       timestamp:
                //           "${logs[index][0]['timestamp'].toString()}",
                //       status:
                //           "${logs[index][3]['type'].toString()}",
                //     ),
                //   ),
                // );
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15.0,
                  left: 20.0,
                  right: 20.0,
                  top: 15.0,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        statusHandler(history[index]['status']),
                        SizedBox(height: 5.0),
                        Text(
                          '${history[index]['domain']}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontFamily: pBold,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          '${history[index]['client']}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontFamily: pRegular,
                          ),
                        ),
                      ],
                    ),
                    actionHandler(history[index]['status']),
                  ],
                ),
              ),
            );
          }),
    );
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Logs history',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontFamily: pBold,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Undo your previous actions.',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12.0,
                            height: 1.5,
                            fontFamily: pRegular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              history.isEmpty ? NoHistory(context: context) : myHistory(),
            ],
          ),
        ),
      ),
    );
  }
}
