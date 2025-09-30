import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiExample1 extends StatefulWidget {
  const ApiExample1({super.key});

  @override
  State<ApiExample1> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ApiExample1> {
  void fetchUser() async {
    try {
      var response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Name: ${data["name"]}');
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Example')),
      body: Center(child: Text('Hello API')),
    );
  }
}

// Model Class
class User {
  final int id;
  final String name;
  final String username;
  final String email;
  // Constructor
  User(this.id, this.name, this.username, this.email);
  // แปลง JSON เป็น Object
  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      username = json['username'],
      email = json['email'];
  // แปลง Object เป็น JSON Map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'username': username, 'email': email};
  }
}
