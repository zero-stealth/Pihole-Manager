import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:piremote/functions/Functions.dart';

class Blocked extends StatefulWidget {
  const Blocked({Key? key}) : super(key: key);

  @override
  State<Blocked> createState() => _BlockedState();
}

class _BlockedState extends State<Blocked> {
  final dbHelper = DatabaseHelper.instance;
  var services = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchServices();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  fetchServices() async {
    var s = await dbHelper.queryAllRows("services");

    setState(() {
      services = s;
    });
  }

  getService(name){
    for (var i = 0; i < services.length; i++) {
      if(services[i]['name'] == name){
        if(services[i]['status'] == "blocked"){
          log("${services[i]['name']} ${services[i]['status']}");
          return true;
        } else {
          log("${services[i]['name']} ${services[i]['status']}");
          return false;
        }
      }
    }

    return false;
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
            child: Column(children: [
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
                    'Block Services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: pBold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: 15.0,
                  bottom: 15.0,
                  left: 20.0,
                  right: 20.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    ServiceItem(
                      service: "Reddit",
                      icon: 'assets/reddit.svg',
                      listsCount: 1,
                      status: getService("reddit"),
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Discord",
                      icon: 'assets/discord.svg',
                      listsCount: 1,
                      status: getService("discord"),
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Whatsapp",
                      icon: 'assets/whatsapp.svg',
                      listsCount: 1,
                      status: getService("whatsapp"),
                      bottomBorder: true,
                    ),
                    // ServiceItem(
                    //   service: "Ebay",
                    //   icon: 'assets/ebay.svg',
                    //   listsCount: 1,
                    //   status: false,
                    //   bottomBorder: true,
                    // ),
                    ServiceItem(
                      service: "Instagram",
                      icon: 'assets/instagram.svg',
                      listsCount: 1,
                      status: getService("instagram"),
                      bottomBorder: true,
                    ),
                    // ServiceItem(
                    //   service: "Amazon",
                    //   icon: 'assets/amazon.svg',
                    //   listsCount: 1,
                    //   status: false,
                    //   bottomBorder: true,
                    // ),
                    ServiceItem(
                      service: "Netflix",
                      icon: 'assets/netflix.svg',
                      listsCount: 1,
                      status: getService("netflix"),
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Facebook",
                      listsCount: 1,
                      icon: 'assets/facebook.svg',
                      status: getService("facebook"),
                      bottomBorder: false,
                    ),
                    // ServiceItem(
                    //   service: "Facebook",
                    //   listsCount: 1,
                    //   status: false,
                    //   bottomBorder: false,
                    // ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class ServiceItem extends StatefulWidget {
  final String service;
  final int listsCount;
  bool status;
  final bool bottomBorder;
  final String icon;
  //final Function action;

  ServiceItem({
    required this.service,
    required this.listsCount,
    required this.status,
    required this.bottomBorder,
    required this.icon,
    //required this.action,
  });

  @override
  State<ServiceItem> createState() => _ServiceItemState();
}

class _ServiceItemState extends State<ServiceItem> {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Icon(
                //   CupertinoIcons.device_desktop,
                //   size: 20.0,
                //   color: Colors.white,
                // ),
                SvgPicture.asset(
                  widget.icon,
                  color: Colors.white,
                  width: 25.0,
                  height: 25.0,
                ),
                SizedBox(width: 15.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service,
                      style: TextStyle(
                        color: Color(0xff3FB950),
                        fontSize: 14.0,
                        fontFamily: pBold,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${widget.listsCount} regex entry',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12.0,
                        fontFamily: pRegular,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            CupertinoSwitch(
              activeColor: Color(0xff3FB950),
              value: widget.status,
              onChanged: (value)async{
                if(widget.status == true){
                  await enableService(widget.service.toLowerCase());
                } else {
                  await blockService(widget.service.toLowerCase());
                }

                setState(() {
                  widget.status = value;
                });
              },
            ),
          ],
        ),
        myBorder(widget.bottomBorder),
      ],
    );
  }
}



// facebook
// ^(.+\.)??(facebook|fb)\.(com|net|org|me)$ 
// ^(.+\.)?(facebook|fb(cdn|sbx)?|tfbnw)\.(com|net)$
// ^(.+\.)??(facebook|(t)?fb(nw)?(cdn|sbx)?)(\.[^\.]+|\.co\.uk)$
// ^(.+\.)?(facebook|fb(cdn|sbx)?|tfbnw)\..+$

// twitter
// ^(.+[_.-])?(twitter|twimg|cms-twdigitalassets)\.(co\.)?[^.]+$

// reddit
// ^(.+\.)??(reddit|redd|redditmedia|redditinc|redditstatus|redditstatic|redditblog|redditmail)\.(com|it)$

// discord
// ^(.+\.)??(discord|discordapp|discordstatus)\.(com|gg|media|net)\$

// whatsapp
// (.+\.)??(whatsapp|whatsappbrand|whatsapp-plus)\.(com|me|org|info|cc|tv|net)

// ebay
// cant do ebay

// instagram
// (.+\.)??(cdninstagram|instagram|ig)\.(com|me|org|info|cc|tv|net)

// disneyplus
// (.+\.)??(disneyplus|disneyplus.bn5x.net|disney-portal.my.onetrust|disney-portal)\.(com|net)
// (.+\.)??(bamgrid|bam.nr-data|cdn.registrydisney.go|cws.conviva|d9.flashtalking)\.(com|net)
// (.+\.)??(adobedtm|dssott|js-agent.newrelic)\.(com|net)

// netflix
// (.+\.)??(netflix|netflix.com|netflixdnstest10|netflixdnstest|netflixdnstest1|netflixdnstest2|netflixdnstest3|netflixdnstest4|netflixdnstest5|netflixdnstest6|netflixdnstest7|netflixdnstest8|netflixdnstest9)\.(com|net|au|ca)
// ^(.+\.)??(netflix|netflix.com|netflixstudios|netflixinvestor|netflixtechblog|nflxext|nflximg|nflxso|nflxvideo|nflxvpn)\.(com|net|ca|au)\$
// (.+\.)??(nflxext|nflximg|nflxso|nflxvideo|nflxvpn)\.(com|net|ca|au)



