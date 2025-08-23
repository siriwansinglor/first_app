import 'package:flutter/material.dart';

class Week3 extends StatelessWidget {
  const Week3({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> ListProduct = ['Apple', 'Samsung', 'Oppo'];
    return Scaffold(
      appBar: AppBar(title: Text('ListView')),
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemCount: ListProduct.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text('$index'),
            title: Text(ListProduct[index]),
            subtitle: Text('loremlorem....'),
            trailing: Icon(Icons.edit),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 2,
            width: double.infinity,
            color: Colors.blue,
          );
        },
      ),
    );
  }
}
