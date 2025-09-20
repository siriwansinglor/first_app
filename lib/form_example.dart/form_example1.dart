import 'package:flutter/material.dart';

class FormExample1 extends StatefulWidget {
  const FormExample1({super.key});

  @override
  State<FormExample1> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<FormExample1> {
  String firstName = '';
  String lastName = '';
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  String? selectedGender;
  bool isAccept = false;
  String mariedStatus = 'single';
  bool isReceiveNews = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Example')),
      body: Form(
        key: formkey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              onChanged: (value) {
                setState(() {
                  firstName = value;
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
              decoration: const InputDecoration(labelText: 'LastName'),
              onChanged: (value) {
                setState(() {
                  lastName = value;
                });
                print('lastname value: $value');
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your First Name';
                }
                return null;
              },
            ),

            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Gender'),
              value: selectedGender,
              items: ['male', 'female', 'other']
                  .map(
                    (String item) =>
                        DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedGender = value!;
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
                  title: Text('Single'),
                  value: 'single',
                  groupValue: mariedStatus,
                  onChanged: (String? value) {
                    setState(() {
                      mariedStatus = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Maried'),
                  value: 'maried',
                  groupValue: mariedStatus,
                  onChanged: (String? value) {
                    setState(() {
                      mariedStatus = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Separated'),
                  value: 'separated',
                  groupValue: mariedStatus,
                  onChanged: (String? value) {
                    setState(() {
                      mariedStatus = value!;
                    });
                  },
                ),
              ],
            ),

            SwitchListTile(
              title: Text('Enable Receive News'),
              value: isReceiveNews,
              onChanged: (bool? value) {
                setState(() {
                  isReceiveNews = value!;
                });
              },
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    nameController.clear();
                    lastNameController.clear();
                  },
                  child: Text('Clear'),
                ),

                ElevatedButton(
                  onPressed: () {
                    nameController.text = 'Dev';
                    lastNameController.text = 'Ops';
                  },
                  child: Text('Auto input'),
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

            Container(
              color: Colors.amber,
              child: Text(
                'Name: $firstName $lastName',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
