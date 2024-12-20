import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uangkoo/pages/home_page.dart';
import 'package:uangkoo/pages/main_page.dart';
import 'package:uangkoo/pages/splashscreen_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const SplashScreen(),
        theme: ThemeData(primarySwatch: Colors.green));
  }
}
