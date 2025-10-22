import 'package:flutter/material.dart';

void main() {
  runApp(const TrafficLight());
}

class TrafficLight extends StatelessWidget {
  const TrafficLight({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Light',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int currentLight = 0; // 0 = แดง, 1 = เหลือง, 2 = เขียว

  void changeLight() {
    setState(() {
      currentLight = (currentLight + 1) % 3; // วนลูป 0 → 1 → 2 → 0
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Layout', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  height: 300,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // ไฟแดง
                Positioned(
                  top: 20,
                  child: AnimatedOpacity(
                    opacity: currentLight == 0 ? 1.0 : 0.3,
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                // ไฟเหลือง
                Positioned(
                  top: 110,
                  child: AnimatedOpacity(
                    opacity: currentLight == 1 ? 1.0 : 0.3,
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ),
                // ไฟเขียว
                Positioned(
                  top: 200,
                  child: AnimatedOpacity(
                    opacity: currentLight == 2 ? 1.0 : 0.3,
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: changeLight,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('เปลี่ยนไฟ'),
            ),
          ],
        ),
      ),
    );
  }
}
