import 'package:first_app/components/custom_profile_card.dart';
import 'package:flutter/material.dart';

class Simple extends StatefulWidget {
  const Simple({super.key});

  @override
  State<Simple> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Simple> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Widget')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomProfileCard(
              name: 'Siriwan Singlor',
              position: 'Student',
              email: 'singlor_s@silpakorn.edu',
              phoneNumber: '092-894-7501',
            ),
          ],
        ),
      ),
    );
  }
}
