import 'package:flutter/material.dart';

class AssignmentFormNew extends StatefulWidget {
  const AssignmentFormNew({super.key});

  @override
  State<AssignmentFormNew> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AssignmentFormNew> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedProvince;
  bool isAccept = false;
  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Form')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // จัดทุกอย่างชิดซ้าย
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Full Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- 💡 ส่วนที่ 1: GENDER (มาก่อน) ---
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: const Text('Male'),
                        value: 'male',
                        groupValue: selectedGender,
                        onChanged: (String? value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: const Text('Female'),
                        value: 'female',
                        groupValue: selectedGender,
                        onChanged: (String? value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // --- จบส่วน Gender ---

                // --- 💡 ส่วนที่ 2: PROVINCE (มาทีหลัง) ---
                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: 'Province'),
                  value: selectedProvince,
                  items: ['Bangkok', 'Chiang Mai', 'Phuket', 'Khon Kaen']
                      .map(
                        (String item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedProvince = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null) {
                      return 'Please select Province';
                    }
                    return null;
                  },
                ),
                // --- จบส่วน Province ---
                const SizedBox(height: 10),

                FormField<bool>(
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: const Text('Accept Terms and Conditions'),
                          value: isAccept,
                          onChanged: (bool? value) {
                            setState(() {
                              isAccept = value!;
                              field.didChange(value);
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .trailing, // ย้ายปุ่มไปไว้ขวา
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  validator: (value) {
                    if (!isAccept) {
                      return 'You must accept the terms and conditions';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        print('Success form');
                        print('Name: ${nameController.text}');
                        print('Email: ${emailController.text}');
                        print('Gender: $selectedGender');
                        print('Province: $selectedProvince');
                        print('Accepted Terms: $isAccept');
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
