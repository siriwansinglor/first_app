import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_page.dart';

// class นี้ใช้เก็บข้อมูลของ "แต่ละท่อน" (1 ท่อน = รูป + อังกฤษ + ไทย)
class StorySection {
  TextEditingController enController = TextEditingController();
  TextEditingController thController = TextEditingController();
  Uint8List? imageBytes;
  String? imageName;

  StorySection();
}

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<InsertPage> {
  // ส่วนหัวเรื่อง (Cover)
  final TextEditingController _nameController = TextEditingController();
  Uint8List? _coverImageBytes;
  String? _coverName;

  // รายการเนื้อหา (เริ่มต้นมี 1 ท่อนเสมอ)
  List<StorySection> _sections = [];

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // เริ่มต้น App มา ให้มีช่องกรอกเนื้อหาท่อนที่ 1 รอไว้เลย
    _sections.add(StorySection());
  }

  // ฟังก์ชันกดปุ่ม (+) แล้วเพิ่มช่องกรอกต่อท้ายในหน้านี้
  void _addNewSection() {
    setState(() {
      _sections.add(StorySection()); // เพิ่มท่อนใหม่ลงใน List
    });
  }

  // ฟังก์ชันลบท่อน (เผื่อกดผิด)
  void _removeSection(int index) {
    if (_sections.length > 1) {
      setState(() {
        _sections.removeAt(index);
      });
    }
  }

  // เลือกรูปปก
  Future<void> _pickCoverImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _coverImageBytes = bytes;
          _coverName = pickedFile.name;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // เลือกรูปเนื้อหา (ต้องระบุ index ว่าเลือกให้ท่อนที่เท่าไหร่)
  Future<void> _pickContentImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _sections[index].imageBytes = bytes;
          _sections[index].imageName = pickedFile.name;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _uploadToFirebase() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter Story Name")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. อัปโหลดรูปปก
      String? coverUrl;
      if (_coverImageBytes != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'story_covers/${DateTime.now().millisecondsSinceEpoch}_$_coverName',
        );
        await storageRef.putData(_coverImageBytes!);
        coverUrl = await storageRef.getDownloadURL();
      }

      // 2. วนลูปอัปโหลดรูปเนื้อหาทุกท่อน และเก็บข้อมูลเตรียมส่งเข้า DB
      List<Map<String, dynamic>> contentDataList = [];

      for (int i = 0; i < _sections.length; i++) {
        String? contentUrl;
        // ถ้ารูปในท่อนนี้มี ให้ Upload
        if (_sections[i].imageBytes != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
            'story_contents/${DateTime.now().millisecondsSinceEpoch}_${i}_${_sections[i].imageName}',
          );
          await storageRef.putData(_sections[i].imageBytes!);
          contentUrl = await storageRef.getDownloadURL();
        }

        // เก็บข้อมูลท่อนนั้นๆ (รูป, อังกฤษ, ไทย) ลงตัวแปรชั่วคราว
        contentDataList.add({
          'index': i + 1, // ลำดับที่ 1, 2, 3...
          'image_url': contentUrl ?? '',
          'text_en': _sections[i].enController.text,
          'text_th': _sections[i].thController.text,
        });
      }

      // 3. บันทึกลง Firestore (เก็บเป็น Array ใน field เดียวชื่อ 'contents')
      await FirebaseFirestore.instance.collection('stories').add({
        'name': _nameController.text,
        'cover_image': coverUrl ?? '',
        'contents': contentDataList, // ส่งรายการเนื้อหาทั้งหมดไปเก็บ
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save Success!")));

      // เคลียร์ค่าหลังบันทึกเสร็จ ให้เหลือท่อนเดียวเหมือนเดิม
      _nameController.clear();
      setState(() {
        _coverImageBytes = null;
        _sections = [StorySection()];
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Storytelling Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(Icons.account_circle, color: Colors.black, size: 35),
          ),
        ],
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Scroll ได้เมื่อเนื้อหายาวขึ้น
              child: Column(
                children: [
                  _buildTopMenu(),
                  Divider(thickness: 1),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ส่วน Cover Image (ส่วนหัว) ---
                        Text('*Cover Image', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImagePickerBox(
                              onTap: _pickCoverImage,
                              imageBytes: _coverImageBytes,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildTextFieldContainer(
                                controller: _nameController,
                                label: "Story's Name",
                                hint: "The Hare and the Tortoise",
                                height: 80,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 20),

                        // --- ส่วน Content Loop (วนลูปแสดงรายการท่อนเนื้อหา) ---
                        // ตรงนี้แหละครับ ที่จะทำให้มันงอก "ต่อจากอันเดิม" ลงมาเรื่อยๆ
                        ..._sections.asMap().entries.map((entry) {
                          int index = entry.key;
                          StorySection section = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // หัวข้อท่อน (เช่น 1 Content Image, 2 Content Image)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${index + 1} Content Image',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  // ปุ่มลบ (แสดงเฉพาะถ้ามีมากกว่า 1 ท่อน)
                                  if (_sections.length > 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeSection(index),
                                    ),
                                ],
                              ),
                              SizedBox(height: 10),

                              // ฟอร์มใส่รูปและข้อความ
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildImagePickerBox(
                                    onTap: () => _pickContentImage(index),
                                    imageBytes: section.imageBytes,
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildTextFieldContainer(
                                          controller: section.enController,
                                          label: "Storyline EN",
                                          maxLines: 3,
                                        ),
                                        SizedBox(height: 10),
                                        _buildTextFieldContainer(
                                          controller: section.thController,
                                          label: "Storyline TH",
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30), // ระยะห่างระหว่างท่อน
                            ],
                          );
                        }).toList(),

                        // --- ปุ่ม (+) เพิ่มท่อนถัดไป ---
                        Center(
                          child: IconButton(
                            onPressed:
                                _addNewSection, // กดแล้วเพิ่มท่อนใหม่ต่อท้ายทันที
                            icon: Icon(Icons.add_circle_outline, size: 45),
                            tooltip: "Add next content block",
                          ),
                        ),

                        SizedBox(height: 30),

                        // --- ปุ่ม Save ---
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              child: Text("Generate Audio"),
                            ),
                            Spacer(),
                            ElevatedButton.icon(
                              onPressed: _uploadToFirebase,
                              icon: Icon(Icons.cloud_upload),
                              label: Text("Save to Cloud"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper Widgets (เหมือนเดิม)
  // ใน InsertPage.dart

  Widget _buildTopMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ปุ่ม Search (กดแล้วไปหน้า Search)
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            child: Text(
              "Search",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),

          // ปุ่ม Insert (หน้านี้ - เป็นสีฟ้า)
          Column(
            children: [
              Text(
                "Insert",
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

          // ปุ่มอื่นๆ
          Text("Edit", style: TextStyle(color: Colors.grey, fontSize: 16)),
          Text("Delete", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildImagePickerBox({
    required VoidCallback onTap,
    Uint8List? imageBytes,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: imageBytes == null
              ? Border.all(color: Colors.grey.shade300)
              : null,
        ),
        child: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(imageBytes, fit: BoxFit.cover),
              )
            : Icon(Icons.image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextFieldContainer({
    required TextEditingController controller,
    required String label,
    String? hint,
    double? height,
    int maxLines = 1,
  }) {
    return Container(
      height: height,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(top: 5),
            ),
          ),
        ],
      ),
    );
  }
}
