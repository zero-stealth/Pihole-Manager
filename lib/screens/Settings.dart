import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piremote/widgets/InputWidget.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController messagecontroller = TextEditingController();

  feedbackModal(context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      )),
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1117),
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50.0,
                    height: 4.0,
                    margin: EdgeInsets.only(top: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: const Color(0xFF161B22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22.0),
              InputWidget(
                namecontroller: messagecontroller,
                label: "Feature suggestion",
                placeholder: 'Add a peanut dispenser.',
                lines: 5,
              ),
              const SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 10.0,
                  left: 0.0,
                  right: 0.0,
                ),
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(6.0),
                  color: const Color(0xff3FB950),
                  child: Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "SFT-Regular",
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsItem(
          icon: CupertinoIcons.chat_bubble_fill,
          name: "Feature suggestion",
          iconSize: 18.0,
          onPressed: () {
            feedbackModal(context);
          },
        ),
        SettingsItem(
          icon: CupertinoIcons.info_circle_fill,
          name: "About",
          iconSize: 20.0,
          onPressed: () {
            print("about");
          },
        ),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final double iconSize;
  final Function onPressed;

  SettingsItem({
    required this.name,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        enableFeedback: true,
        borderRadius: BorderRadius.circular(6.0),
        onTap: () {
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.only(
            top: 15.0,
            bottom: 15.0,
            left: 15.0,
            right: 15.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Colors.white,
              ),
              SizedBox(width: 15.0),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: "SFT-Regular",
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
