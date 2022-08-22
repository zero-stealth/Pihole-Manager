import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piremote/data/fonts.dart';

class InputWidget extends StatefulWidget {
  const InputWidget({
    Key? key,
    required this.namecontroller,
    required this.label,
    required this.placeholder,
    required this.lines,
    required this.qrcode,
  }) : super(key: key);

  final TextEditingController namecontroller;
  final String label;
  final String placeholder;
  final int lines;
  final bool qrcode;

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  qr() {
    return InkWell(
      onTap: () {},
      child: Icon(
        CupertinoIcons.qrcode,
        color: Color(0xff3FB950),
        size: 20.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xff3FB950),
                  fontFamily: pRegular,
                ),
              ),
              widget.qrcode == true ? qr() : Container(),
            ],
          ),
        ),
        SizedBox(height: 12.0),
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
            controller: widget.namecontroller,
            onChanged: (text) {},
            maxLines: widget.lines,
            placeholder: widget.placeholder,
            placeholderStyle: TextStyle(
              color: Colors.grey.withOpacity(0.2),
              fontFamily: pRegular,
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }
}
