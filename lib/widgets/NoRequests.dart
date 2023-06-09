import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piremote/data/fonts.dart';

class NoRequests extends StatelessWidget {
  const NoRequests({
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
                  color: Color.fromARGB(255, 32, 38, 46).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100.0)),
              child: Center(
                child: Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                  size: 70.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              "No requests.",
              style: TextStyle(
                fontSize: 18.0,
                // color: Color(0xff3FB950),
                color: Colors.white,
                fontFamily: pBold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "The client you selected has not sent any requests recently.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                // color: Color(0xff3FB950),
                color: Color.fromARGB(255, 145, 145, 145),
                fontFamily: pRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}