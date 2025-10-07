import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Assigmentweek5 extends StatefulWidget {
  const Assigmentweek5({super.key});

  @override
  State<Assigmentweek5> createState() => _Assigmentweek5State();
}

class _Assigmentweek5State extends State<Assigmentweek5> {
  List<Product> listProducts = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var response = await http.get(
        Uri.parse('http://localhost:3000/products'),
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          listProducts = jsonList
              .map((item) => Product.fromJson(item))
              .toList();
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> createProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("http://localhost:3000/products"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "description": descriptionController.text,
          "price": double.tryParse(priceController.text) ?? 0.0,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มสินค้าสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        nameController.clear();
        descriptionController.clear();
        priceController.clear();
        fetchData(); // รีเฟรชข้อมูล
        Navigator.pop(context); // ปิด Dialog
      } else {
        throw Exception("Failed to create product");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> updateProduct(Product product) async {
    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = product.price.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แก้ไขสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสินค้า',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียด',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ราคา',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.clear();
                descriptionController.clear();
                priceController.clear();
                Navigator.pop(context);
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  var response = await http.put(
                    Uri.parse("http://localhost:3000/products/${product.id}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "name": nameController.text,
                      "description": descriptionController.text,
                      "price": double.tryParse(priceController.text) ?? 0.0,
                    }),
                  );
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('แก้ไขสินค้าสำเร็จ!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    nameController.clear();
                    descriptionController.clear();
                    priceController.clear();
                    fetchData();
                    Navigator.pop(context);
                  } else {
                    throw Exception("Failed to update product");
                  }
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    try {
      var response = await http.delete(
        Uri.parse("http://localhost:3000/products/$id"),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบสินค้าสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchData(); // รีเฟรชข้อมูล
      } else {
        throw Exception("Failed to delete product");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void showAddProductDialog() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เพิ่มสินค้าใหม่'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสินค้า',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียด',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ราคา',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: createProduct,
              child: const Text('เพิ่ม'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text('คุณต้องการลบสินค้า "${product.name}" ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                deleteProduct(product.id);
                Navigator.pop(context);
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Product'),
        actions: [
          IconButton(
            onPressed: () {
              fetchData();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: listProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: listProducts.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    listProducts[index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(listProducts[index].description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${listProducts[index].price.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          updateProduct(listProducts[index]);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDeleteConfirmDialog(listProducts[index]);
                        },
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Model Class
class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  Product(this.id, this.name, this.description, this.price);

  Product.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      description = json['description'],
      price = (json['price'] as num).toDouble();
}
