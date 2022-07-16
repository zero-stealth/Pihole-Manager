import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    Key? key,
    required this.namecontroller,
    required this.label,
    required this.placeholder,
  }) : super(key: key);

  final TextEditingController namecontroller;
  final String label;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 12.0,
              color: Color(0xff3FB950),
              fontFamily: "SFT-Regular",
            ),
          ),
        ),
        SizedBox(height: 8.0),
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
            placeholder: placeholder,
            placeholderStyle: TextStyle(
              color: Colors.grey.withOpacity(0.2),
              fontFamily: "SFT-Regular",
            ),
          ),
        ),
      ],
    );
  }
}
