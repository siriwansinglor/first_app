import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data; // recive input data storytelling

  const DetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // retrive data contents
    List<dynamic> contents = data['contents'] ?? [];

    // retrive Genre
    String genreRaw = data['genre'] ?? '';
    List<String> genreList = genreRaw.isNotEmpty
        ? genreRaw.split(',').map((e) => e.trim()).toList()
        : ["General"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          data['name'] ?? 'Story Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Center(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: data['cover_image'] != ''
                      ? Image.network(data['cover_image'], fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: 50),
                        ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Name storytelling
            Text(
              data['name'] ?? '',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),

            Row(
              children: [
                // create tag
                ...genreList.map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _tag(g),
                  ),
                ),

                Spacer(),
                Icon(Icons.star, color: Colors.amber),
                Text(" 4.9 (57 likes)", style: TextStyle(color: Colors.grey)),
              ],
            ),
            Divider(height: 40, thickness: 1),

            // Contents
            if (contents.isEmpty)
              Center(
                child: Text(
                  "No content available.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  var item = contents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content Image
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                          ),
                          child:
                              item['image_url'] != null &&
                                  item['image_url'] != ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    item['image_url'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.image, color: Colors.grey),
                        ),
                        SizedBox(width: 20),

                        // Story
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Storyline EN
                              Text(
                                item['text_en'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 15),
                              // Storyline TH
                              Text(
                                item['text_th'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // play audio button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.play_circle_fill),
                label: Text("Play Audio Story"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: TextStyle(color: Colors.blue[800], fontSize: 12)),
  );
}
