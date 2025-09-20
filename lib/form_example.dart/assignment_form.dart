import 'package:flutter/material.dart';

class AssignmentForm extends StatefulWidget {
  const AssignmentForm({super.key});

  @override
  State<AssignmentForm> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AssignmentForm> {
  String fullname = '';
  String email = '';
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  String? selectedProvince;
  bool isAccept = false;
  String? selectedGender;
  bool isReceiveNews = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration Form')),
      body: Form(
        key: formkey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              onChanged: (value) {
                setState(() {
                  fullname = value;
                });
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your First Name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your First Name';
                }
                return null;
              },
            ),

            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Province'),
              value: selectedProvince,
              items: ['Bangkok', 'Chiangmai', 'Phuket', 'Khon kaen']
                  .map(
                    (String item) =>
                        DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedProvince = value!;
                });
              },

              validator: (String? value) {
                if (value == null) {
                  return 'Please select Gender';
                }
                return null;
              },
            ),

            Column(
              children: [
                RadioListTile(
                  title: Text('Male'),
                  value: 'male',
                  groupValue: selectedGender,
                  onChanged: (String? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Female'),
                  value: 'female',
                  groupValue: selectedGender,
                  onChanged: (String? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
              ],
            ),

            CheckboxListTile(
              title: const Text('Accept Terms and Conditions'),
              checkColor: Colors.blue,
              value: isAccept,
              onChanged: (bool? value) {
                setState(() {
                  isAccept = value!;
                });
              },
            ),

            ElevatedButton(
              onPressed: () {
                if (formkey.currentState!.validate()) {
                  print('Success form');
                  print('Name: $nameController.text');
                }
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
