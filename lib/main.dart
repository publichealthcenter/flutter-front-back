import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:untitled/acceptance.dart';
import 'package:untitled/backoffice.dart';

void main() {
  // Ensure URL strategy is set before running the app
  setUrlStrategy(PathUrlStrategy());

  // Wrap the app with ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/acceptance':
            return MaterialPageRoute(builder: (context) => const Acceptance());
          case '/settings':
            return MaterialPageRoute(builder: (context) => const Backoffice());
        // case '/floorinfo':
        //   return MaterialPageRoute(builder: (context) => const FloorInfo());
          default:
            return MaterialPageRoute(builder: (context) => const Scaffold(
              body: Center(child: Text('flutter web view'),),
            ));
        }
      },
    );
  }
}