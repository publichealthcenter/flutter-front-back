import 'package:flutter/material.dart';
import 'package:untitled/backoffice.dart';
import 'package:untitled/page/floorinfo.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        print('Current route: ${settings.name}');
        switch (settings.name) {
          case '/acceptance':
            return MaterialPageRoute(builder: (context) => Acceptance());
          case '/backoffice':
            return MaterialPageRoute(builder: (context) => Backoffice());
          case '/floorinfo':
            return MaterialPageRoute(builder: (context) => FloorInfo());
          default:
            return MaterialPageRoute(builder: (context) => Backoffice());
        }
      },
    );
  }
}
