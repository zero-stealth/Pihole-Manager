import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/widgets/NoHistory.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class LogsHistory extends StatefulWidget {
  const LogsHistory({Key? key}) : super(key: key);

  @override
  State<LogsHistory> createState() => _LogsHistoryState();
}

class _LogsHistoryState extends State<LogsHistory> {
  fetchHistory() async {
    final dbHelper = DatabaseHelper.instance;
    var hist = await dbHelper.queryAllRows('logsHistory');

    setState(() {
      history = hist;
    });
  }

  var history = [];

  // switch color of ui element to
  // fit action that has occurred
  changeElement(index, status) {
    // setState(() {
    //   history[index]['status'] = status;
    // });
    fetchHistory();
  }

  calculateTime(timestamp) {
    try {
      var date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      var formattedDate = DateFormat.yMMMd().format(date);
      var formattedTime = DateFormat.jm().format(date);
      return "Updated on ${formattedDate}, ${formattedTime}";
    } catch (e) {
      print(e);
      return timestamp.toString();
    }
  }

  actionHandler(status, domain, client, index, id, timestamp) {
    switch (status) {
      case "blacklisted":
        return ActionIcon(
          status: status,
          domain: domain,
          client: client,
          index: index,
          id: id,
          timestamp: timestamp,
        );

      case "allowed":
        return ActionIcon(
          status: status,
          domain: domain,
          client: client,
          index: index,
          id: id,
          timestamp: timestamp,
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
            return Container(
              padding: const EdgeInsets.only(
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          '${history[index]['domain']}',
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontFamily: pBold,
                          ),
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
                      SizedBox(height: 10.0),
                      Text(
                        calculateTime(history[index]['timestamp']),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12.0,
                          fontFamily: pRegular,
                        ),
                      ),
                    ],
                  ),
                  actionHandler(
                      history[index]['status'],
                      history[index]['domain'],
                      history[index]['client'],
                      index,
                      history[index]['_id'],
                      history[index]['timestamp']),
                ],
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchHistory();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

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

class ActionIcon extends StatefulWidget {
  // status, domain, client, index, id
  String status;
  final String domain;
  final String client;
  final int index;
  final int id;
  String timestamp;

  ActionIcon({
    required this.status,
    required this.domain,
    required this.client,
    required this.index,
    required this.id,
    required this.timestamp,
  });

  @override
  State<ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon> {
  addToBlacklist(domain, client, id, timestamp) async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');
    var ip = devices[0]['ip'];
    var url = '${devices[0]['protocol']}://$ip';
    var token = devices[0]['apitoken'];
    final response = await http.get(
        Uri.parse('$url/admin/api.php?list=black&add=$domain&auth=$token'));

    if (response.statusCode == 200) {
      print('ADDED TO BLACKLIST');
      await addToHistory(domain, "blacklisted", client, id, timestamp);
    }
  }

  addToHistory(domain, status, client, id, timestamp) async {
    final dbHelper = DatabaseHelper.instance;
    var hist = await dbHelper.queryAllRows('logsHistory');

    Map<String, dynamic> row = {
      "_id": id,
      "domain": domain,
      "status": status,
      "client": client,
      "timestamp": timestamp,
    };

    await dbHelper.update(row, "logsHistory");

    setState(() {
      if (widget.status == "allowed") {
        widget.status = "blacklisted";
      } else {
        widget.status = "allowed";
      }
    });
  }

  addToWhitelist(domain, client, id, timestamp) async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');
    var ip = devices[0]['ip'];
    var url = '${devices[0]['protocol']}://$ip';
    var token = devices[0]['apitoken'];
    final response = await http.get(
        Uri.parse('$url/admin/api.php?list=white&add=$domain&auth=$token'));

    if (response.statusCode == 200) {
      print('ADDED TO WHITELIST');
      await addToHistory(domain, "allowed", client, id, timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        switch (widget.status) {
          case "allowed":
            addToBlacklist(
                widget.domain, widget.client, widget.id, widget.timestamp);
            break;

          case "blacklisted":
            addToWhitelist(
                widget.domain, widget.client, widget.id, widget.timestamp);
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: widget.status == "allowed"
                ? Colors.redAccent.withOpacity(0.1)
                : Color(0xff3FB950).withOpacity(0.1),
            borderRadius: BorderRadius.circular(50.0)),
        child: Center(
          child: Icon(
            widget.status == "allowed"
                ? CupertinoIcons.xmark_shield_fill
                : CupertinoIcons.checkmark_shield_fill,
            color: widget.status == "allowed"
                ? Colors.redAccent
                : Color(0xff3FB950),
          ),
        ),
      ),
    );
  }
}
