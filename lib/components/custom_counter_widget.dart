import 'package:flutter/material.dart';

class CustomCounterWidget extends StatefulWidget {
  final String title;
  final Color color;
  final ValueChanged<Color> setTeamWin;
  const CustomCounterWidget({
    super.key,
    required this.title,
    required this.color,
    required this.setTeamWin,
  });

  @override
  State<CustomCounterWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CustomCounterWidget> {
  int _counter = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(widget.title),
          const SizedBox(height: 10),
          Text('Count: $_counter', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_counter >= 21) {
                widget.setTeamWin(widget.color);
                return;
              }
              setState(() {
                _counter++;
              });
            },
            child: Text('Increment+'),
          ),
        ],
      ),
    );
  }
}
