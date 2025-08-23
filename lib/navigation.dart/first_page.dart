import 'package:first_app/navigation.dart/second_page.dart';
import 'package:flutter/material.dart'; // stl

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('First Page'), backgroundColor: Colors.yellow),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(name: 'Dev', age: 20),
                  ),
                );
              },
              child: Text('Second Page >'),
            ),
          ],
        ),
      ),
    );
  }
}
