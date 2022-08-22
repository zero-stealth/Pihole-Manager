import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/screens/EditDevice.dart';

class Disconnected extends StatelessWidget {
  const Disconnected({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 170,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150.0,
              height: 150.0,
              //padding: EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100.0)),
              child: Center(
                child: Icon(
                  CupertinoIcons.antenna_radiowaves_left_right,
                  color: Colors.redAccent,
                  size: 70.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              "Oh no!",
              style: TextStyle(
                fontSize: 18.0,
                // color: Color(0xff3FB950),
                color: Colors.redAccent,
                fontFamily: pBold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Could not connect to your pihole instance.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                // color: Color(0xff3FB950),
                color: Colors.redAccent,
                fontFamily: pRegular,
              ),
            ),
            SizedBox(height: 30.0),
            CupertinoButton(
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.redAccent,
              child: Text(
                "Edit Device",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontFamily: pRegular,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDevice(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
