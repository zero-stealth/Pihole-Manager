import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piremote/data/fonts.dart';

class Stats extends StatelessWidget {
  final String memoryUsage;
  final String temperature;

  Stats({
    required this.memoryUsage,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.device_thermostat_outlined,
            size: 16.0,
            color: Colors.white,
          ),
          SizedBox(width: 5.0),
          Text(
            '$temperature°',
            style: TextStyle(
              color: Colors.white,
              fontFamily: pRegular,
              fontSize: 12.0,
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            width: 1.0,
            height: 15.0,
            color: Colors.white.withOpacity(0.4),
          ),
          SizedBox(width: 10.0),
          Icon(
            Icons.storage,
            size: 16.0,
            color: Colors.white,
          ),
          SizedBox(width: 10.0),
          Text(
            memoryUsage,
            style: TextStyle(
              color: Colors.white,
              fontFamily: pRegular,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
