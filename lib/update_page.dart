import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class for keep data each of section
class StorySection {
  TextEditingController enController = TextEditingController();
  TextEditingController thController = TextEditingController();
  Uint8List? newImageBytes; // new image that selected
  String? oldImageUrl; // Url old image from Firebase
  String? imageName;

  StorySection({this.oldImageUrl, String en = '', String th = ''}) {
    enController.text = en;
    thController.text = th;
  }
}

class UpdatePage extends StatefulWidget {
  final String docId; // recieve id to edit
  final Map<String, dynamic> data; // recieve all old data

  const UpdatePage({super.key, required this.docId, required this.data});

  @override
  State<UpdatePage> createState() => _UpdateStoryPageState();
}

class _UpdateStoryPageState extends State<UpdatePage> {
  final TextEditingController _nameController = TextEditingController();

  // list Genre
  final List<String> _allGenres = [
    "Adventure",
    "Fantasy",
    "Fable",
    "Comedy",
    "Drama",
    "Horror",
    "Sci-Fi",
    "Romance",
    "Action",
  ];

  // keep Genre that selected
  List<String> _selectedGenres = [];

  Uint8List? _newCoverBytes;
  String? _oldCoverUrl; // new Cover Image
  String? _coverName; // old Covr Image

  List<StorySection> _sections = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData(); // load old data
  }

  void _loadExistingData() {
    // old name
    _nameController.text = widget.data['name'] ?? '';

    //  Genre
    String genreRaw = widget.data['genre'] ?? '';

    // Debug
    print("Loaded Genre Raw: $genreRaw");

    if (genreRaw.isNotEmpty) {
      setState(() {
        // convert "Adventure, Action" -> List ["Adventure", "Action"]
        _selectedGenres = genreRaw.split(',').map((e) => e.trim()).toList();
      });
    }

    // keep Url old Cover Image
    _oldCoverUrl = widget.data['cover_image'];

    // create content from old data
    if (widget.data['contents'] != null) {
      List<dynamic> contents = widget.data['contents'];
      for (var item in contents) {
        _sections.add(
          StorySection(
            oldImageUrl: item['image_url'],
            en: item['text_en'],
            th: item['text_th'],
          ),
        );
      }
    } else {
      _sections.add(StorySection());
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _newCoverBytes = bytes;
        _coverName = pickedFile.name;
      });
    }
  }

  Future<void> _pickContentImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _sections[index].newImageBytes = bytes;
        _sections[index].imageName = pickedFile.name;
      });
    }
  }

  void _addNewSection() => setState(() => _sections.add(StorySection()));

  void _removeSection(int index) {
    if (_sections.length > 1) setState(() => _sections.removeAt(index));
  }

  // save edit
  Future<void> _updateData() async {
    setState(() => _isUploading = true);
    try {
      // check that have change Cover Image?
      String finalCoverUrl = _oldCoverUrl ?? ''; // set start as old Cover Image
      if (_newCoverBytes != null) {
        // have new image : upload and use new Url
        final storageRef = FirebaseStorage.instance.ref().child(
          'story_covers/${DateTime.now().millisecondsSinceEpoch}_$_coverName',
        );
        await storageRef.putData(_newCoverBytes!);
        finalCoverUrl = await storageRef.getDownloadURL();
      }

      // check each image of sectiom
      List<Map<String, dynamic>> contentDataList = [];
      for (int i = 0; i < _sections.length; i++) {
        String finalContentUrl = _sections[i].oldImageUrl ?? '';
        if (_sections[i].newImageBytes != null) {
          // have new image : upload
          final storageRef = FirebaseStorage.instance.ref().child(
            'story_contents/${DateTime.now().millisecondsSinceEpoch}_${i}_${_sections[i].imageName}',
          );
          await storageRef.putData(_sections[i].newImageBytes!);
          finalContentUrl = await storageRef.getDownloadURL();
        }
        contentDataList.add({
          'index': i + 1,
          'image_url': finalContentUrl,
          'text_en': _sections[i].enController.text,
          'text_th': _sections[i].thController.text,
        });
      }

      // convert Genre to String
      String genreString = _selectedGenres.join(', ');

      // update data in Firebase
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(widget.docId) // old id
          .update({
            'name': _nameController.text,
            'genre': genreString,
            'cover_image': finalCoverUrl,
            'contents': contentDataList,
            'updated_at': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update Success!")));
      Navigator.pop(
        context,
      ); // close update_page.dart and back to edit_page.dart
    } catch (e) {
      print(e);
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
      appBar: AppBar(
        title: Text(
          'Edit Story',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        elevation: 0,
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image
                  Text('*Cover Image', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildImageBox(
                        _newCoverBytes,
                        _oldCoverUrl,
                        _pickCoverImage,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            _buildTextField(
                              _nameController,
                              "Story's Name",
                              height: 80,
                            ),
                            SizedBox(height: 15),

                            // Genre
                            Text(
                              "Genre",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 5),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: _allGenres.map((genre) {
                                return FilterChip(
                                  label: Text(genre),
                                  selected: _selectedGenres.contains(genre),
                                  selectedColor: Colors.blue.shade100,
                                  checkmarkColor: Colors.blue,
                                  labelStyle: TextStyle(
                                    color: _selectedGenres.contains(genre)
                                        ? Colors.blue.shade900
                                        : Colors.black,
                                    fontSize: 12,
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected)
                                        _selectedGenres.add(genre);
                                      else
                                        _selectedGenres.remove(genre);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 40),

                  ..._sections.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${index + 1} Content Image',
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeSection(index),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            _buildImageBox(
                              entry.value.newImageBytes,
                              entry.value.oldImageUrl,
                              () => _pickContentImage(index),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTextField(
                                    entry.value.enController,
                                    "Storyline EN",
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: 10),
                                  _buildTextField(
                                    entry.value.thController,
                                    "Storyline TH",
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                      ],
                    );
                  }).toList(),

                  Center(
                    child: IconButton(
                      onPressed: _addNewSection,
                      icon: Icon(Icons.add_circle_outline, size: 40),
                    ),
                  ),
                  SizedBox(height: 30),

                  // button update
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        "Update Changes",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildImageBox(
    Uint8List? newBytes,
    String? oldUrl,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: newBytes != null
              ? Image.memory(newBytes, fit: BoxFit.cover)
              : (oldUrl != null && oldUrl.isNotEmpty)
              ? Image.network(oldUrl, fit: BoxFit.cover)
              : Icon(Icons.add_a_photo, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    double? height,
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
