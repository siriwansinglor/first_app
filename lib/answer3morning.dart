import 'package:flutter/material.dart';

class Answer3morning extends StatefulWidget {
  const Answer3morning({super.key});

  @override
  State<Answer3morning> createState() => _Answer3State();
}

class _Answer3State extends State<Answer3morning> {
  final _formKey = GlobalKey<FormState>();

  int _basePrice = 150;

  bool _vacuum = false;
  bool _wax = false;

  int _totalPrice = 0;

  void _calculateTotal() {
    _totalPrice = _basePrice;
    if (_vacuum) {
      _totalPrice += 50;
    }
    if (_wax) {
      _totalPrice += 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("คำนวณค่าบริการล้างรถ")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ขนาดรถ", style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<int>(
                value: _basePrice,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 150,
                    child: Text("รถเล็ก (Small) - 150 บาท"),
                  ),
                  DropdownMenuItem(
                    value: 200,
                    child: Text("รถเก๋ง (Medium) - 200 บาท"),
                  ),
                  DropdownMenuItem(
                    value: 250,
                    child: Text("รถ SUV/กระบะ (Large) - 250 บาท"),
                  ),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _basePrice = newValue;
                      _calculateTotal();
                    });
                  }
                },
              ),
              SizedBox(height: 24),

              CheckboxListTile(
                title: Text("ดูดฝุ่น (+50 บาท)"),
                value: _vacuum,
                onChanged: (bool? newValue) {
                  setState(() {
                    _vacuum = newValue ?? false;
                    _calculateTotal();
                  });
                },
              ),

              CheckboxListTile(
                title: Text("เคลือบแว็กซ์ (+100 บาท)"),
                value: _wax, // (โจทย์ 3.2)
                onChanged: (bool? newValue) {
                  setState(() {
                    _wax = newValue ?? false;
                    _calculateTotal();
                  });
                },
              ),

              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),

              Center(
                child: Text(
                  "ราคารวม: $_totalPrice บาท",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
