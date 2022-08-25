import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';

class Query extends StatefulWidget {
  final String status;
  final String domain;
  final String client;
  final String type;
  final String timestamp;

  Query({
    required this.status,
    required this.domain,
    required this.client,
    required this.type,
    required this.timestamp,
  });

  @override
  State<Query> createState() => _QueryState();
}

class _QueryState extends State<Query> {
  checkStatus(type) {
    switch (type) {
      case '1':
        return QueryItem(
          title: "Status",
          domain: "Blocked",
          icon: CupertinoIcons.xmark_shield_fill,
          color: Colors.redAccent,
          textcolor: Colors.redAccent,
          titlecolor: Colors.redAccent,
        );

      case '2':
        return QueryItem(
          title: "Status",
          domain: "Allowed",
          icon: CupertinoIcons.xmark_shield_fill,
          color: Color(0xff3FB950),
          textcolor: Color(0xff3FB950),
          titlecolor: Color(0xff3FB950),
        );

      case '3':
        return QueryItem(
          title: "Status",
          domain: "Allowed",
          icon: CupertinoIcons.xmark_shield_fill,
          color: Color(0xff3FB950),
          textcolor: Color(0xff3FB950),
          titlecolor: Color(0xff3FB950),
        );

      case '4':
        return QueryItem(
          title: "Status",
          domain: "Allowed",
          icon: CupertinoIcons.xmark_shield_fill,
          color: Color(0xff3FB950),
          textcolor: Color(0xff3FB950),
          titlecolor: Color(0xff3FB950),
        );

      default:
        return QueryItem(
          title: "Status",
          domain: "Blocked",
          icon: CupertinoIcons.xmark_shield_fill,
          color: Colors.redAccent,
          textcolor: Colors.redAccent,
          titlecolor: Colors.redAccent,
        );
    }
  }

  var progress = "inactive";

  statusReport() {
    if (progress == "loading") {
      return progressBtn();
    }

    if (progress == "whitelisted") {
      return CupertinoButton(
        borderRadius: BorderRadius.circular(6.0),
        color: const Color(0xFF161B22),
        child: Text(
          'Whitelisted',
          style: TextStyle(
            color: Color(0xff3FB950),
            fontSize: 13.0,
            fontFamily: pRegular,
          ),
        ),
        onPressed: () {},
      );
    }

    if (progress == "blacklisted") {
      return CupertinoButton(
        borderRadius: BorderRadius.circular(6.0),
        color: const Color(0xFF161B22),
        child: Text(
          'Blacklisted',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 13.0,
            fontFamily: pRegular,
          ),
        ),
        onPressed: () {},
      );
    }
  }

  progressBtn() {
    return CupertinoButton(
      borderRadius: BorderRadius.circular(6.0),
      color: Color(0xff3FB950),
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.white,
        size: 25.0,
      ),
      onPressed: () {},
    );
  }

  changeBtn(type, domain) {
    switch (type) {
      case '1':
        return CupertinoButton(
          borderRadius: BorderRadius.circular(6.0),
          color: Color(0xff3FB950),
          child: Text(
            'Add to whitelist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.0,
              fontFamily: pRegular,
            ),
          ),
          onPressed: () {
            addToWhitelist(domain);
          },
        );

      case '2':
        return CupertinoButton(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.redAccent,
          child: Text(
            'Add to blacklist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.0,
              fontFamily: pRegular,
            ),
          ),
          onPressed: () {
            addToBlacklist(domain);
          },
        );

      case '3':
        return CupertinoButton(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.redAccent,
          child: Text(
            'Add to blacklist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.0,
              fontFamily: pRegular,
            ),
          ),
          onPressed: () {
            addToBlacklist(domain);
          },
        );

      case '4':
        return CupertinoButton(
          borderRadius: BorderRadius.circular(6.0),
          color: Color(0xff3FB950),
          child: Text(
            'Add to whitelist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.0,
              fontFamily: pRegular,
            ),
          ),
          onPressed: () {
            addToWhitelist(domain);
          },
        );

      default:
        return CupertinoButton(
          borderRadius: BorderRadius.circular(6.0),
          color: Color(0xff3FB950),
          child: Text(
            'Add to whitelist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.0,
              fontFamily: pRegular,
            ),
          ),
          onPressed: () {
            addToWhitelist(domain);
          },
        );
    }
  }

  addToBlacklist(domain) async {
    setState(() {
      progress = 'loading';
    });
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');
    var ip = devices[0]['ip'];
    var url = '${devices[0]['protocol']}://$ip';
    var token = devices[0]['apitoken'];
    final response = await http.get(
        Uri.parse('$url/admin/api.php?list=black&add=$domain&auth=$token'));

    if (response.statusCode == 200) {
      print('ADDED TO BLACKLIST');
      setState(() {
        progress = 'blacklisted';
      });
    }
  }

  addToWhitelist(domain) async {
    setState(() {
      progress = 'loading';
    });
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');
    var ip = devices[0]['ip'];
    var url = '${devices[0]['protocol']}://$ip';
    var token = devices[0]['apitoken'];
    final response = await http.get(
        Uri.parse('$url/admin/api.php?list=white&add=$domain&auth=$token'));

    if (response.statusCode == 200) {
      print('ADDED TO WHITELIST');
      setState(() {
        progress = 'whitelisted';
      });
    }
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
                      'Query',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: pBold,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 20.0),
                
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      checkStatus(widget.status),
                      Divider(
                        color: Colors.grey.withOpacity(0.04),
                        thickness: 2.0,
                      ),
                      
                      QueryItem(
                        title: 'Time',
                        domain: widget.timestamp,
                        icon: CupertinoIcons.clock_fill,
                        color: Color(0xff3FB950),
                        textcolor: Colors.white.withOpacity(0.5),
                        titlecolor: Colors.white,
                      ),
                      
                      Divider(
                        color: Colors.grey.withOpacity(0.04),
                        thickness: 2.0,
                      ),
                      
                      QueryItem(
                        title: 'Domain',
                        domain: widget.domain,
                        icon: CupertinoIcons.globe,
                        color: Color(0xff3FB950),
                        textcolor: Colors.white.withOpacity(0.5),
                        titlecolor: Colors.white,
                      ),
                      
                      Divider(
                        color: Colors.grey.withOpacity(0.04),
                        thickness: 2.0,
                      ),
                      
                      QueryItem(
                        title: 'Client',
                        domain: widget.client,
                        icon: CupertinoIcons.device_laptop,
                        color: Color(0xff3FB950),
                        textcolor: Colors.white.withOpacity(0.5),
                        titlecolor: Colors.white,
                      ),
                      
                      Divider(
                        color: Colors.grey.withOpacity(0.04),
                        thickness: 2.0,
                      ),
                      
                      QueryItem(
                        title: 'Type',
                        domain: widget.type,
                        icon: CupertinoIcons.wifi,
                        color: Color(0xff3FB950),
                        textcolor: Colors.white.withOpacity(0.5),
                        titlecolor: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 10.0,
                    left: 0.0,
                    right: 0.0,
                  ),
                  child: progress == "inactive"
                      ? changeBtn(widget.status, widget.domain)
                      : statusReport(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QueryItem extends StatelessWidget {
  final String domain;
  final IconData icon;
  final String title;
  final Color color;
  final Color textcolor;
  final Color titlecolor;

  QueryItem({
    required this.domain,
    required this.textcolor,
    required this.title,
    required this.icon,
    required this.titlecolor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24.0,
                color: color,
              ),
              SizedBox(width: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titlecolor,
                      fontSize: 14.0,
                      fontFamily: pRegular,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  SizedBox(
                    width: 250,
                    child: Text(
                      domain,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: textcolor,
                        fontSize: 13.0,
                        fontFamily: pRegular,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
