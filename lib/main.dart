import 'package:first_app/Search_Page.dart';
import 'package:first_app/answer1.dart';
import 'package:first_app/answer1morning.dart';
import 'package:first_app/answer2.dart';
import 'package:first_app/answer2morning.dart';
import 'package:first_app/answer3morning.dart';
import 'package:first_app/api_example.dart/ApiExample.dart';
import 'package:first_app/api_example.dart/api_assignment.dart';
import 'package:first_app/assignment.dart';
import 'package:first_app/counter_widget.dart';
import 'package:first_app/form_example.dart/assignment_form_new.dart';
import 'package:first_app/form_example.dart/form_example1.dart';
import 'package:first_app/insert_page.dart';
import 'package:first_app/login_page.dart';
import 'package:first_app/navigation.dart/first_page.dart';
import 'package:first_app/navigation.dart/second_page.dart';
import 'package:flutter/material.dart';
import 'package:first_app/week3.dart';
import 'package:first_app/greeting_widget.dart';
import 'package:first_app/counter_fullwidget.dart';
import 'package:first_app/counter_fullwidget.dart';
import 'package:first_app/form_example.dart/form_example1.dart';
import 'package:first_app/form_example.dart/assignment_form.dart';
import 'package:first_app/api_example.dart/ApiExampleList.dart';
import 'package:first_app/api_example.dart/AssignmentWeek5.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/firebase_options.dart';
import 'package:first_app/page/simple_custom_widget.dart';
import 'package:first_app/components/custom_card.dart';
import 'package:first_app/page/simple.dart';
import 'package:first_app/page/animation_test.dart';
import 'package:first_app/page/traffic_light.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: LoginPage(),
    );
  }
}

//gs://final-project-mb-97077.firebasestorage.app
// stl+enter
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('dog.jpeg')));
  }
}
