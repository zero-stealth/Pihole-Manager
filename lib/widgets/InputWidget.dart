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
    required this.info,
  }) : super(key: key);

  final TextEditingController namecontroller;
  final String label;
  final String placeholder;
  final int lines;
  final bool qrcode;
  final bool info;

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

  void _popup() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            title: 'Admin password',
            content:
                'Pihole Manager needs your web admin password to be able to access pihole\'s system stats and display them to you.',
            continueWidget: Column(
              children: [
                // Container(
                //   width: MediaQuery.of(context).size.width - 80,
                //   child: CupertinoButton(
                //     padding: const EdgeInsets.all(10.0),
                //     color: dBlueBackground,
                //     child: const Text(
                //       'Skip for now',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 16.0,
                //         fontFamily: 'SFT-Regular',
                //       ),
                //     ),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => Dashboard()),
                //       );
                //     },
                //   ),
                // ),
                // SizedBox(height: 10.0),
                Container(
                  width: MediaQuery.of(context).size.width - 80,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(10.0),
                    color: Colors.white,
                    child: Text(
                      'Got it',
                      style: TextStyle(
                        color: Color(0xff3FB950),
                        fontSize: 16.0,
                        fontFamily: 'SFNSR',
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10.0,
      ),
      child: Column(
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
                widget.info == true
                    ? InkWell(
                        onTap: () {
                          _popup();
                        },
                        child: Icon(
                          CupertinoIcons.exclamationmark_circle_fill,
                          size: 18.0,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
                // widget.qrcode == true ? qr() : Container(),
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
              obscureText: widget.placeholder == "password" ? true : false,
              placeholderStyle: TextStyle(
                color: Colors.grey.withOpacity(0.2),
                fontFamily: pRegular,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Dialog extends StatelessWidget {
  final String title;
  final String content;
  // final Widget cancelWidget;
  final Widget continueWidget;

  Dialog({
    required this.title,
    required this.content,
    // required this.cancelWidget,
    required this.continueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Color(0xFF0D1117).withOpacity(0.9),
      child: Center(
        child: Wrap(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Color(0xff3FB950),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        CupertinoIcons.lock_shield_fill,
                        color: Colors.white,
                        size: 120.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.0),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AR',
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SFNSR',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [continueWidget],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
