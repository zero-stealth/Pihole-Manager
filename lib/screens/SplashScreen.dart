import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:piremote/functions/Functions.dart';
import 'package:piremote/screens/AddDevices.dart';
import 'package:piremote/screens/Dashboard.dart';

import '../database/database_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  moveOn() async {
    await testToken();
    var timer = Timer(
        Duration(seconds: 3),
        () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Dashboard(),
                ),
              )
            });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    moveOn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/appico.png',
              width: 170.0,
              height: 170.0,
            ),
            // LoadingAnimationWidget.staggeredDotsWave(
            //   color: Color(0xff3FB950),
            //   size: 50.0,
            // )
          ],
        ),
      ),
    );
  }
}
