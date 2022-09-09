import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:piremote/screens/Dashboard.dart';
import 'package:piremote/screens/SplashScreen.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/appicon.png'), context);
    precacheImage(AssetImage('assets/appico.png'), context);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF161B22),
        bottomAppBarColor: const Color(0xFF161B22),
        bottomAppBarTheme: BottomAppBarTheme(
          color: const Color(0xFF161B22),
        ),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: const Color(0xFF161B22),
            statusBarColor: const Color(0xFF161B22),
            systemNavigationBarDividerColor: const Color(0xFF161B22),
          ),
        ),
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
