import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiExample extends StatefulWidget {
  const ApiExample({super.key});

  @override
  State<ApiExample> createState() => _ApiExampleState();
}

class _ApiExampleState extends State<ApiExample> {
  List<User> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        final data = list
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
        if (!mounted) return;
        setState(() {
          users = data;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch data (${response.statusCode})';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Example')),
      body: Builder(
        builder: (_) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errorMessage!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      fetchUsers();
                    },
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: Text('${index + 1}'),
                title: Text(u.name),
                subtitle: Text(u.email),
                trailing: Text('(${u.username})'),
                onTap: () {},
              );
            },
          );
        },
      ),
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
