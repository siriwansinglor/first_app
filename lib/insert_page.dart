import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_page.dart';
import 'edit_page.dart';
import 'delete_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

// class for keep each section (1 section = image + storyline EN + storyline TH)
class StorySection {
  TextEditingController enController = TextEditingController();
  TextEditingController thController = TextEditingController();
  Uint8List? imageBytes; // keep image as Bytes
  String? imageName;
  StorySection();
}

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<InsertPage> {
  final TextEditingController _nameController = TextEditingController();

  // List of Genre
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

  Uint8List? _coverImageBytes; // keep Cover Image
  String? _coverName;
  // list of story
  List<StorySection> _sections = [];
  final ImagePicker _picker = ImagePicker(); // select image from device
  bool _isUploading = false; // status of upload

  @override
  void initState() {
    super.initState();
    // create new content for input
    _sections.add(StorySection());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // press + to add new content
  void _addNewSection() => setState(() => _sections.add(StorySection()));

  // delete content
  void _removeSection(int index) {
    if (_sections.length > 1) setState(() => _sections.removeAt(index));
  }

  // select Cover Image from device
  Future<void> _pickCoverImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        // read file by Bytes to prepare upload
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

  // select Content Image
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

  // save to Firebase
  Future<void> _uploadToFirebase() async {
    // validation
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter Story Name")));
      return;
    }
    // check Genre<1 ?
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one Genre")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // upload Cover Image to Firebase Storage
      String? coverUrl;
      if (_coverImageBytes != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'story_covers/${DateTime.now().millisecondsSinceEpoch}_$_coverName',
        );
        await storageRef.putData(_coverImageBytes!);
        coverUrl = await storageRef
            .getDownloadURL(); // retrieve Url of Cover Image
      }

      // loop for upload content
      List<Map<String, dynamic>> contentDataList = [];
      for (int i = 0; i < _sections.length; i++) {
        String? contentUrl;
        if (_sections[i].imageBytes != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
            'story_contents/${DateTime.now().millisecondsSinceEpoch}_${i}_${_sections[i].imageName}',
          );
          await storageRef.putData(_sections[i].imageBytes!);
          contentUrl = await storageRef.getDownloadURL();
        }
        // keep data
        contentDataList.add({
          'index': i + 1,
          'image_url': contentUrl ?? '',
          'text_en': _sections[i].enController.text,
          'text_th': _sections[i].thController.text,
        });
      }

      // convert List that select to , (send to Firebase)
      String genreString = _selectedGenres.join(', ');

      await FirebaseFirestore.instance.collection('stories').add({
        'name': _nameController.text,
        'genre': genreString, // keep value that have convert
        'cover_image': coverUrl ?? '',
        'contents': contentDataList,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save Success!")));

      // clear screen
      _nameController.clear();
      setState(() {
        _selectedGenres.clear(); // clear value that selected
        _coverImageBytes = null;
        _sections = [StorySection()];
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false); // stop load
    }
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
        actions: [
          // button for logout
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
                    // change to login_dart.page
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            // detail button user
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
      body: _isUploading
          ? Center(child: CircularProgressIndicator()) // show loading
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopMenu(), // top bar
                  Divider(thickness: 1),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('*Cover Image', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        // input data :  Cover Image, Name, Genre
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // box for select Cover Image
                            _buildImagePickerBox(
                              onTap: _pickCoverImage,
                              imageBytes: _coverImageBytes,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // box for input name
                                  _buildTextFieldContainer(
                                    controller: _nameController,
                                    label: "Story's Name",
                                    height: 80,
                                  ),
                                  SizedBox(height: 15),

                                  // make Genre tag (FilterChip)
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
                                        // check button selected?
                                        selected: _selectedGenres.contains(
                                          genre,
                                        ),
                                        selectedColor: Colors.blue.shade100,
                                        checkmarkColor: Colors.blue,
                                        // change text color that selected
                                        labelStyle: TextStyle(
                                          color: _selectedGenres.contains(genre)
                                              ? Colors.blue.shade900
                                              : Colors.black,
                                          fontSize: 12,
                                        ),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedGenres.add(
                                                genre,
                                              ); // insert in list
                                            } else {
                                              _selectedGenres.remove(
                                                genre,
                                              ); // delete out list
                                            }
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
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 20),
                        // show content
                        ..._sections.asMap().entries.map((entry) {
                          int index = entry.key;
                          StorySection section = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${index + 1} Content Image',
                                    style: TextStyle(fontSize: 16),
                                  ),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // box for selected Content Image
                                  _buildImagePickerBox(
                                    onTap: () => _pickContentImage(index),
                                    imageBytes: section.imageBytes,
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        // input storyline EN
                                        _buildTextFieldContainer(
                                          controller: section.enController,
                                          label: "Storyline EN",
                                          maxLines: 3,
                                        ),
                                        SizedBox(height: 10),
                                        // input storyline TH
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
                              SizedBox(height: 30),
                            ],
                          );
                        }).toList(),
                        Center(
                          // button for create new content
                          child: IconButton(
                            onPressed: _addNewSection,
                            icon: Icon(Icons.add_circle_outline, size: 45),
                            tooltip: "Add next content block",
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              child: Text("Generate Audio"),
                            ),
                            Spacer(),
                            // button for press save to Firebase
                            ElevatedButton.icon(
                              onPressed: _uploadToFirebase,
                              icon: Icon(Icons.cloud_upload),
                              label: Text("Save"),
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

  // top bar
  Widget _buildTopMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuItem(
            "Search",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            ),
          ),
          _menuItem("Insert", true, () {}),
          _menuItem(
            "Edit",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EditPage()),
            ),
          ),
          _menuItem(
            "Delete",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DeletePage()),
            ),
          ),
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
              width: 50,
              color: Colors.blue,
              margin: EdgeInsets.only(top: 5),
            ),
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
