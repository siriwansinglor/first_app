import 'package:flutter/material.dart';

ThemeData ligthTheme = ThemeData.light().copyWith();

ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Colors.blueGrey[800],
  appBarTheme: AppBarTheme(backgroundColor: Colors.blueAccent),
);
