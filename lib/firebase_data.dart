import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseData extends StatefulWidget {
  const FirebaseData({super.key});

  @override
  State<FirebaseData> createState() => _FirebaseDataState();
}

class _FirebaseDataState extends State<FirebaseData> {
  final CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase')),
      body: StreamBuilder<QuerySnapshot>(
        stream: products.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final data = snapshot.data!.docs;
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final product = data[index];
              String productId = product.id; // ดึงค่า ID ของเอกสาร
              return ListTile(
                leading: Text(productId),
                title: Text(product['name']),
                subtitle: Text(product['description']),
              );
            },
          );
        },
      ),
    );
  }
}
