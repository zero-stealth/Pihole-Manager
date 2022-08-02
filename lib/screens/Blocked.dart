import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Blocked extends StatefulWidget {
  const Blocked({Key? key}) : super(key: key);

  @override
  State<Blocked> createState() => _BlockedState();
}

class _BlockedState extends State<Blocked> {
  // const List<String> _assetNames = <String>[
  //   'assets/reddit.svg'
  // ];

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
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      size: 25.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    'Blocked Services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'SFD-Bold',
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
                      listsCount: 0,
                      status: false,
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Discord",
                      icon: 'assets/discord.svg',
                      listsCount: 0,
                      status: false,
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Whatsapp",
                      icon: 'assets/whatsapp.svg',
                      listsCount: 0,
                      status: false,
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Ebay",
                      icon: 'assets/ebay.svg',
                      listsCount: 0,
                      status: false,
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Instagram",
                      icon: 'assets/instagram.svg',
                      listsCount: 0,
                      status: false,
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Amazon",
                      icon: 'assets/amazon.svg',
                      listsCount: 0,
                      status: false,
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Netflix",
                      icon: 'assets/netflix.svg',
                      listsCount: 0,
                      status: false,
                      bottomBorder: true,
                    ),
                    ServiceItem(
                      service: "Facebook",
                      listsCount: 0,
                      icon: 'assets/facebook.svg',
                      status: false,
                      bottomBorder: false,
                    ),
                    // ServiceItem(
                    //   service: "Facebook",
                    //   listsCount: 0,
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

class ServiceItem extends StatelessWidget {
  final String service;
  final int listsCount;
  final bool status;
  final bool bottomBorder;
  final String icon;

  ServiceItem({
    required this.service,
    required this.listsCount,
    required this.status,
    required this.bottomBorder,
    required this.icon,
  });

  myBorder(s) {
    if(s == true){
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
                  icon,
                  color: Colors.white,
                  width: 25.0,
                  height: 25.0,
                ),
                SizedBox(width: 15.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service,
                      style: TextStyle(
                        color: Color(0xff3FB950),
                        fontSize: 14.0,
                        fontFamily: "SFT-Regular",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '$listsCount regex entries',
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
            CupertinoSwitch(
              activeColor: Color(0xff3FB950),
              value: status,
              onChanged: (value) {},
            ),
          ],
        ),
        myBorder(bottomBorder),
      ],
    );
  }
}
