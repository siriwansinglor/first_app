import 'package:flutter/material.dart';

class CounterFullwidget extends StatefulWidget {
  const CounterFullwidget({super.key});

  @override
  State<CounterFullwidget> createState() => _CounterFullwidgetState();
}

class _CounterFullwidgetState extends State<CounterFullwidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Stateful Widget'),
        backgroundColor: Colors.purpleAccent,
      ),
    );
  }
}
