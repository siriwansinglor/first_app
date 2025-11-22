import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'insert_page.dart';
import 'search_page.dart';
import 'edit_page.dart'; // หรือ edit_list_page.dart ตามชื่อไฟล์จริงของคุณ
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class DeletePage extends StatefulWidget {
  const DeletePage({super.key});

  @override
  State<DeletePage> createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {
  String _searchText = ""; // keep text that search

  // connfirm and delete data
  Future<void> _confirmDelete(String docId, String storyName) async {
    // alert user before delete
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text(
            "Are you sure you want to delete '$storyName'?\nThis action cannot be undone.",
          ),
          actions: [
            // cancle button
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // confirm delete button
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // ปิด Dialog ก่อน

                // delete data form Firebase
                await FirebaseFirestore.instance
                    .collection('stories')
                    .doc(docId)
                    .delete();

                // show delete success
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Deleted '$storyName' successfully"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Storytelling Management',
          style: GoogleFonts.shortStack(color: Colors.black, fontSize: 28),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // user and logout
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.black,
              size: 35,
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) {
              final user = FirebaseAuth.instance.currentUser;
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Signed in as",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        user?.email ?? "Guest",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          _buildTopMenu(),
          Divider(thickness: 1),
          Padding(
            // search bar
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  hintText: 'Enter the name of the story...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          // show storytelling that want to delete
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stories')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;
                // filtor data by search
                if (_searchText.isNotEmpty) {
                  docs = docs
                      .where(
                        (doc) => doc['name'].toString().toLowerCase().contains(
                          _searchText.toLowerCase(),
                        ),
                      )
                      .toList();
                }
                if (docs.isEmpty)
                  return Center(child: Text("No stories found"));
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    // create card for delete
                    return _buildDeleteCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // create card and delete button
  Widget _buildDeleteCard(String docId, Map<String, dynamic> data) {
    // retrive Genre and convert to list
    String genreRaw = data['genre'] ?? '';
    List<String> genreList = genreRaw.isNotEmpty
        ? genreRaw.split(',').map((e) => e.trim()).toList()
        : ["General"];

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          Container(
            width: 100,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: data['cover_image'] != ''
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      data['cover_image'],
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.image, size: 40, color: Colors.grey),
          ),
          SizedBox(width: 15),
          // detail about storytelling
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${data['name']}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),

                // --- ส่วน Genre แบบ Dynamic ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Genre: ",
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: genreList
                            .map((genre) => _badge(genre))
                            .toList(),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow[700], size: 16),
                    Text(
                      " 4.9 stars",
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      "Details: ",
                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                    ),
                    _iconText(Icons.access_time, "15 mins+"),
                    SizedBox(width: 8),
                    _iconText(Icons.menu_book, "92 reads"),
                    SizedBox(width: 8),
                    _iconText(
                      Icons.favorite,
                      "57 likes",
                      color: Colors.redAccent,
                    ),

                    Spacer(),

                    InkWell(
                      onTap: () =>
                          _confirmDelete(docId, data['name'] ?? "Unknown"),
                      child: Row(
                        children: [
                          // delete icon
                          Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                          Text(
                            " Delete",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // top bar
          _menuItem(
            "Search",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SearchPage()),
            ),
          ),
          _menuItem(
            "Insert",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => InsertPage()),
            ),
          ),
          _menuItem(
            "Edit",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => EditPage()),
            ),
          ),
          _menuItem("Delete", true, () {}), // Active หน้าปัจจุบัน
        ],
      ),
    );
  }

  Widget _menuItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue : Colors.black,
              fontSize: 16,
            ),
          ),
          if (isActive)
            Container(
              height: 3,
              width: 55,
              color: Colors.blue,
              margin: EdgeInsets.only(top: 5),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: Colors.blue.shade900,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _iconText(IconData icon, String text, {Color color = Colors.grey}) =>
      Row(
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 2),
          Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[800])),
        ],
      );
}
