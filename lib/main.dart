import 'package:first_app/assignment.dart';
import 'package:first_app/counter_widget.dart';
import 'package:first_app/navigation.dart/first_page.dart';
import 'package:first_app/navigation.dart/second_page.dart';
import 'package:flutter/material.dart';
import 'package:first_app/week3.dart';
import 'package:first_app/greeting_widget.dart';
import 'package:first_app/counter_fullwidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}

// stl+enter
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('dog.jpeg')));
  }
}
