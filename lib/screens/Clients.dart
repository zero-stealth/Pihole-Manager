import 'package:flutter/cupertino.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:flutter/material.dart';

class Clients extends StatefulWidget {
  const Clients({Key? key}) : super(key: key);

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  var myclients = [];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  fetchClients() async {
    final dbHelper = DatabaseHelper.instance;
    var clients = await dbHelper.queryAllRows('clients');

    setState(() {
      myclients = clients;
    });
  }

  getClients() {
    if (myclients.length > 0) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            clipBehavior: Clip.none,
            scrollDirection: Axis.vertical,
            itemCount: myclients.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(
                  bottom: 20.0,
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${myclients[index]['ip']}",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "SFT-Regular",
                        // color: Color(0xff3FB950),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "${myclients[index]['requests']} requests",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "SFT-Regular",
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                      ),
                      child: CupertinoButton(
                        borderRadius: BorderRadius.circular(6.0),
                        color: const Color.fromARGB(255, 16, 21, 27),
                        child: const Text(
                          'Manage Device',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff3FB950),
                            fontFamily: "SFT-Regular",
                          ),
                        ),
                        onPressed: () async {},
                      ),
                    ),
                  ],
                ),
              );
            }),
      );
    } else {
      return Container();
    }
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
                    'Manage clients',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'SFD-Bold',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25.0),
              getClients(),
            ]),
          ),
        ),
      ),
    );
  }
}
