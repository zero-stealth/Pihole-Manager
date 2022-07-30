import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Query extends StatefulWidget {
  const Query({Key? key}) : super(key: key);

  @override
  State<Query> createState() => _QueryState();
}

class _QueryState extends State<Query> {
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
                    InkWell(
                      radius: 50.0,
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
                      'Query',
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
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '09:59:00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontFamily: "SFT-Regular",
                            ),
                          ),
                          Text(
                            '30 July 2022',
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 14.0,
                              fontFamily: "SFT-Regular",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Request',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                      fontSize: 14.0,
                      fontFamily: "SFT-Regular",
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      QueryItem(
                        title: 'Status',
                        domain: 'blocked',
                        icon: CupertinoIcons.xmark_shield_fill,
                        color: Colors.redAccent,
                        textcolor: Colors.redAccent,
                        titlecolor: Colors.redAccent,
                      ),
                      SizedBox(height: 10.0),
                      Divider(
                        color: Colors.grey.withOpacity(0.04),
                        thickness: 2.0,
                      ),
                      SizedBox(height: 10.0),
                      QueryItem(
                        title: 'Domain',
                        domain: 'torn.com',
                        icon: CupertinoIcons.globe,
                        color: Color(0xff3FB950),
                        textcolor: Colors.white.withOpacity(0.5),
                        titlecolor: Colors.white,
                      ),
                      SizedBox(height: 10.0),
                      Divider(
                        color: Colors.grey.withOpacity(0.04),
                        thickness: 2.0,
                      ),
                      SizedBox(height: 10.0),
                      QueryItem(
                        title: 'Client',
                        domain: 'Windows Desktop',
                        icon: CupertinoIcons.device_laptop,
                        color: Color(0xff3FB950),
                        textcolor: Colors.white.withOpacity(0.5),
                        titlecolor: Colors.white,
                      ),
                      SizedBox(height: 10.0),
                      Divider(
                        color: Colors.grey.withOpacity(0.04),
                        thickness: 2.0,
                      ),
                      SizedBox(height: 10.0),
                      QueryItem(
                        title: 'Type',
                        domain: 'A',
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
                  child: CupertinoButton(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xff3FB950),
                    child: Text(
                      'Add to whitelist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.0,
                        fontFamily: "SFT-Regular",
                      ),
                    ),
                    onPressed: () {},
                  ),
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
    return Row(
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
                    fontFamily: "SFT-Regular",
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  domain,
                  style: TextStyle(
                    color: textcolor,
                    fontSize: 13.0,
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
