import 'package:flutter/material.dart';

class Panels extends StatelessWidget {
  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;

  Panels(
      {required this.firstLabel,
      required this.firstValue,
      required this.secondLabel,
      required this.secondValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 50) / 2,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFF161B22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstLabel,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontFamily: "SFD-Bold",
                      color: Color(0xff3FB950),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    firstValue,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "SFT-Regular",
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: (MediaQuery.of(context).size.width - 50) / 2,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFF161B22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    secondLabel,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontFamily: "SFD-Bold",
                      color: Color(0xff3FB950),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    secondValue,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "SFT-Regular",
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10.0)
      ],
    );
  }
}
