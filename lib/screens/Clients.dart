import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:piremote/widgets/InputWidget.dart';

class Clients extends StatefulWidget {
  const Clients({Key? key}) : super(key: key);

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  TextEditingController namecontroller = TextEditingController();
  String buttonState = 'notloading';
  final dbHelper = DatabaseHelper.instance;

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

  buttonStatus() {
    switch (buttonState) {
      case "loading":
        return LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 25.0,
        );
      case "notloading":
        return Text(
          'Change name',
          style: TextStyle(
            fontSize: 14.0,
            fontFamily: "SFT-Regular",
          ),
        );
    }
  }

  editClientModal(context, id, name) {
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
                  const SizedBox(height: 22.0),
                  Text(
                    'Edit Client',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontFamily: "SFD-Bold",
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: CupertinoTextField(
                      decoration: const BoxDecoration(
                        color: Color(0xFF161B22),
                      ),
                      scrollPhysics: const BouncingScrollPhysics(),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      controller: namecontroller,
                      onChanged: (text) {},
                      maxLines: 1,
                      placeholder: "$name",
                      placeholderStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.2),
                        fontFamily: "SFT-Regular",
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
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
                      child: buttonStatus(),
                      onPressed: () async {
                        Map<String, dynamic> row = {
                          "_id": id,
                          "name": namecontroller.text
                        };
                        await dbHelper.update(row, "clients");
                        Navigator.pop(context);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => super.widget),
                        // );
                        setState((){
                          fetchClients();
                        });

                        // Duration timeDelay = Duration(seconds: 4);
                        // Timer(
                        //   timeDelay,
                        //   () => {
                            
                        //   },
                        // );
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          );
        });
      },
    );
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
                      "${myclients[index]['name']}",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "SFT-Regular",
                        color: Color(0xff3FB950),
                      ),
                    ),
                    SizedBox(height: 10.0),
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
                        onPressed: () async {
                          await editClientModal(
                            context,
                            myclients[index]['_id'],
                            myclients[index]['name'],
                          );
                        },
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
