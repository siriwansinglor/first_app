import 'package:flutter/material.dart';

class Assignment extends StatelessWidget {
  const Assignment({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> ListProduct = [
      'Student ID',
      'Name - Surname',
      'Faculty',
      'Motto',
    ];
    List<String> subtitleList = [
      '650710095',
      'Siriwan Singlor',
      'Computor Science',
      'In the middle of difficulty lies opportunity.',
    ];

    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 480,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              ClipOval(
                child: Image.asset(
                  'pic_student.jpg',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 11),
              Expanded(
                child: ListView.separated(
                  itemCount: ListProduct.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(ListProduct[index]),
                      subtitle: Text(subtitleList[index]),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 2,
                      width: double.infinity,
                      color: Colors.brown,
                    );
                  },
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
