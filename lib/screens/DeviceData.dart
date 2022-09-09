import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:rive/rive.dart';

class DeviceData extends StatefulWidget {
  const DeviceData({Key? key}) : super(key: key);

  @override
  State<DeviceData> createState() => _DeviceDataState();
}

class _DeviceDataState extends State<DeviceData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10.0),
            width: 200.0,
            height: 200.0,
            decoration: BoxDecoration(
              color: Color(0xff3FB950).withOpacity(0.2),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Center(
              child: RiveAnimation.asset("assets/ip.riv"),
            ),
          ),
        ),
      ),
    );
  }
}
