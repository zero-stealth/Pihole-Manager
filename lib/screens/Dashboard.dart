import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:piremote/database/database_helper.dart';

import '../models/QueryModel.dart';
import '../widgets/Panels.dart';
import '../widgets/Stats.dart';

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

  String memory = "0%";
  String temperature = "0°";
  String apitoken =
      "25aa34070a75ce79dcf2496484ad2301de3daa2b80581c9b265eaadb79685303";
  String url = "http://192.168.0.26";

  String totalQueries = "0";
  String queriesBlocked = "0";
  String percentBlocked = "0";
  String blocklist = "0";

  extractData() async {
    final response =
        await http.Client().get(Uri.parse('http://192.168.0.26/admin/'));
    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      try {
        var temp = document.getElementsByClassName('pull-left info')[0];

        LineSplitter ls = new LineSplitter();
        List<String> lines = ls.convert(temp.text.trim());

        for (var i = 0; i < lines.length; i++) {
          if (i == 4) {
            var ext = lines[i].replaceAll(new RegExp(r'[^\.0-9]'), '');
            setState(() {
              var mytemp = double.parse(ext);
              assert(mytemp is double);
              temperature = mytemp.toStringAsFixed(1);
            });
          }

          if (i == 3) {
            var ext2 = lines[i].replaceAll(new RegExp(r'[^\.0-9]'), '');
            setState(() {
              memory = '$ext2%';
            });
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }

  fetchQueries() async {
    final dbHelper = DatabaseHelper.instance;
    final response = await http.get(Uri.parse('$url/admin/api.php?summary'));
    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      QueryModel queryModel = QueryModel.fromMap(parsed);

      setState(() {
        totalQueries = queryModel.dns_queries_today;
        queriesBlocked = queryModel.ads_blocked_today;
        percentBlocked = queryModel.ads_percentage_today;
        blocklist = queryModel.domains_being_blocked;
      });

      Map<String, dynamic> row = {
        "totalQueries": totalQueries.toString(),
        "queriesBlocked":queriesBlocked.toString(),
        "percentBlocked": percentBlocked.toString(),
        "blocklist": blocklist.toString()
      };

      try {
        var queries = await dbHelper.queryAllRows('querystats');

        if(queries.length >= 1){
          await dbHelper.deleteTable('querystats');
          await dbHelper.insert(row, 'querystats');
        } else {
          await dbHelper.insert(row, 'querystats');
        }
        
      } catch (e) {
        print('[error] $e');
      }
    } else {
      throw Exception("Unable to fetch query data");
    }
  }

  @override
  void initState() {
    super.initState();
    extractData();
    fetchQueries();
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.check_mark_circled_solid,
                                color: Color(0xff3FB950),
                                size: 20.0,
                              ),
                              const SizedBox(width: 10.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Stats(temperature: temperature, memoryUsage: memory),
                        const SizedBox(height: 15.0),
                        Panels(
                          firstLabel: "Total Queries",
                          firstValue: totalQueries,
                          secondLabel: "Queries Blocked",
                          secondValue: queriesBlocked,
                        ),
                        Panels(
                          firstLabel: "Percent Blocked",
                          firstValue: '$percentBlocked%',
                          secondLabel: "Blocklist",
                          secondValue: blocklist,
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
