import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.addListener(() {
      print(controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // const Color(0xFF0D1117)
      backgroundColor: const Color(0xFF0D1117),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   width: double.infinity,
              //   child: Text(
              //     'Config',
              //     textAlign: TextAlign.start,
              //     style: TextStyle(
              //       fontSize: 16.0,
              //       color: Color(0xff3FB950),
              //       fontFamily: "SFD-Bold",
              //     ),
              //   ),
              // ),
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                child: Text(
                  'Pihole ip address',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xff3FB950),
                    fontFamily: "SFD-Bold",
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                  ),
                  scrollPhysics: BouncingScrollPhysics(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: controller,
                  onChanged: (text){

                  },
                  maxLines: 1,
                  placeholder: "Pihole ip address",
                  placeholderStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.2),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                child: Text(
                  'Pihole api token',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xff3FB950),
                    fontFamily: "SFD-Bold",
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                  ),
                  scrollPhysics: BouncingScrollPhysics(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: controller,
                  onChanged: (text){

                  },
                  maxLines: 1,
                  placeholder: "Api token",
                  placeholderStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.2),
                    fontFamily: "SFT-Regular",
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: 20.0,
                  left: 0.0,
                  right: 0.0,
                ),
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(6.0),
                  color: Color(0xff3FB950),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: "SFD-Bold",
                    ),
                  ),
                  onPressed: () {
                    print('TEXT: ${controller.text}');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
