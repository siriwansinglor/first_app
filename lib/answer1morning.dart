import 'package:flutter/material.dart';

class Answer1morning extends StatelessWidget {
  const Answer1morning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comment Thread')),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 24, child: Text('A')),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User A',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'This is the main comment. Flutter layouts are fun!',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, size: 18),
                    Text('12'),
                    SizedBox(width: 20),
                    Icon(Icons.comment_outlined, size: 18),
                    Text(' Reply'),
                    Spacer(),
                    Text('1h ago', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 42.0, top: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 18, child: Text('B')),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User B',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('I agree!'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
