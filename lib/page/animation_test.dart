import 'package:flutter/material.dart';

class AnimationTest extends StatefulWidget {
  const AnimationTest({super.key});

  @override
  State<AnimationTest> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AnimationTest> {
  double _size = 100;
  Color _color = Colors.red;
  double _opacity = 0;
  bool _isLeft = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            alignment: _isLeft ? Alignment.centerLeft : Alignment.centerRight,
            duration: Duration(milliseconds: 200),
            child: Container(height: 100, width: 100, color: Colors.red),
          ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLeft = !_isLeft;
              });
            },
            child: Text('Move Box'),
          ),
        ],
      ),
    );
  }
}
