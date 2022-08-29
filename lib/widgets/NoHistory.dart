import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piremote/data/fonts.dart';
import 'package:piremote/screens/EditDevice.dart';

class NoHistory extends StatelessWidget {
  const NoHistory({
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
                  color: Color(0xff3FB950).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100.0)),
              child: Center(
                child: Icon(
                  CupertinoIcons.clock,
                  color: Color(0xff3FB950),
                  size: 70.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              "Hmmmm!",
              style: TextStyle(
                fontSize: 18.0,
                // color: Color(0xff3FB950),
                color: Color(0xff3FB950),
                fontFamily: pBold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "It appears you have not whitelisted or blacklisted anything.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                // color: Color(0xff3FB950),
                color: Color(0xff3FB950),
                fontFamily: pRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
