import 'package:flutter/material.dart';

class Answer2morning extends StatelessWidget {
  const Answer2morning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Concert Ticket'),
        backgroundColor: Colors.blueGrey.shade600, // ปรับสีให้ตรงโจทย์
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Flutter Live',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Band: The Widgets'),
                            Text('Date: 8 NOV 2025'),
                            Text('Gate: 7'),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey.shade800,
                        child: Center(
                          child: Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 210,
                  child: Icon(Icons.more_vert, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
