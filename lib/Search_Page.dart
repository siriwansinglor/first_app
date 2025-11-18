import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'insert_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = ""; // ตัวแปรเก็บคำค้นหา

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Storytelling Management',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Icon(Icons.account_circle, color: Colors.black, size: 35),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Menu Tab (Search Active)
          _buildTopMenu(),
          Divider(thickness: 1),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value; // อัปเดตคำค้นหา
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter the name of the story...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // 3. List รายการนิยายจาก Firebase
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stories')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // ดึงข้อมูลมาแล้วแปลงเป็น List
                var docs = snapshot.data!.docs;

                // กรองข้อมูลตามคำค้นหา (Search Logic)
                if (_searchText.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String name = data['name'] ?? '';
                    return name.toLowerCase().contains(
                      _searchText.toLowerCase(),
                    );
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(child: Text("No stories found"));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    // ดึงข้อมูลจริงจาก Firebase
                    String title = data['name'] ?? 'No Name';
                    String imageUrl = data['cover_image'] ?? '';

                    // สร้าง Card แสดงผล
                    return _buildStoryCard(title, imageUrl);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget ส่วน Menu Tab
  // ใน SearchPage.dart

  Widget _buildTopMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ปุ่ม Search (หน้านี้ - เป็นสีฟ้า)
          Column(
            children: [
              Text(
                "Search",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                height: 3,
                width: 50,
                color: Colors.blue,
                margin: EdgeInsets.only(top: 5),
              ),
            ],
          ),

          // ปุ่ม Insert (กดแล้วกลับไปหน้า Insert)
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const InsertPage()),
              );
            },
            child: Text(
              "Insert",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),

          // ปุ่มอื่นๆ
          Text("Edit", style: TextStyle(color: Colors.grey, fontSize: 16)),
          Text("Delete", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _menuItem(String title, bool isActive) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        if (isActive) Container(height: 3, width: 60, color: Colors.blue),
      ],
    );
  }

  // Widget การ์ดแสดงผลนิยายแต่ละเรื่อง
  Widget _buildStoryCard(String title, String imageUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปปก
          Container(
            width: 100,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Icon(Icons.image, size: 40, color: Colors.grey),
          ),
          SizedBox(width: 15),

          // ข้อมูลด้านขวา
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                // ชื่อเรื่อง
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ", style: TextStyle(color: Colors.grey[800])),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Genre (ข้อมูลสมมติ - ใส่ให้เหมือนแบบ)
                Row(
                  children: [
                    Text("Genre: ", style: TextStyle(color: Colors.grey[800])),
                    _tagBadge("Adventure"),
                    SizedBox(width: 5),
                    _tagBadge("Fantasy"),
                    SizedBox(width: 10),
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Text(" 4.9 stars", style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 15),

                // Details (ข้อมูลสมมติ - ใส่ให้เหมือนแบบ)
                Row(
                  children: [
                    Text(
                      "Details: ",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                    Text(" 15 mins+  ", style: TextStyle(fontSize: 11)),
                    Icon(Icons.menu_book, size: 14, color: Colors.grey),
                    Text(" 92 reads  ", style: TextStyle(fontSize: 11)),
                    Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                    Text(" 57 likes", style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper สร้างป้าย Tag สีฟ้า
  Widget _tagBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
      ),
    );
  }
}
