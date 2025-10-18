import 'package:flutter/material.dart';
import 'package:first_app/components/custom_card.dart';
import 'package:first_app/components/custom_counter_widget.dart';

class SimpleCustomWidget extends StatefulWidget {
  const SimpleCustomWidget({super.key});

  @override
  State<SimpleCustomWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SimpleCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Widget')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomCounterWidget(
              title: 'Team A',
              color: Colors.lightBlue,
              setTeamWin: (Color value) {},
            ),
            CustomCounterWidget(
              title: 'Team B',
              color: Colors.pinkAccent,
              setTeamWin: (Color value) {},
            ),
          ],
        ),
      ),
    );
  }
}
