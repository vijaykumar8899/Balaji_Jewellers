//final search_screen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String input = "";
  Stream<QuerySnapshot>? searchResults;
  final CollectionReference searchCollection =
      FirebaseFirestore.instance.collection('Search');

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus on the FocusNode when the screen is initialized
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    // Dispose of the FocusNode when the screen is disposed
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orangeAccent,
                    width: 1.0,
                  ),
                  color: Colors.black,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo9.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Sri Balaji Jewelers",
              style: GoogleFonts.mateSc(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    offset: Offset(3, 3),
                    blurRadius: 7,
                    color: Colors.black,
                  ),
                ],
                decoration: TextDecoration.none,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [Colors.orange, Colors.orange],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 30.0)),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Material(
            borderRadius: BorderRadius.circular(30),
            elevation: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          // Convert user input to lowercase
                          input = val.toLowerCase();
                        });
                      },
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      decoration: InputDecoration(
                        hintText: "Search for Ornaments",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 20),
                      ),
                      focusNode: _searchFocusNode,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.mic),
                    color: Colors.black87,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings),
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // Filter the documents based on the user input
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final imageName = doc['ImageName'].toString().toLowerCase();
                  return imageName.contains(input);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text('No results found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    return ListTile(
                      title: Text(doc['ImageName']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePopup(
                              imageUrl: doc['imageUrl'],
                              id: doc['id'],
                              weight: doc['Weight'].toString(),
                              context: context,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePopup extends StatelessWidget {
  final String imageUrl;
  final String id;
  final String weight;
  final BuildContext context; // Add context as a parameter

  ImagePopup({
    required this.imageUrl,
    required this.id,
    required this.weight,
    required this.context, // Add context as a parameter
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 400,
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            Positioned(
              top: 10, // Adjust the top position as needed
              left: 10, // Adjust the left position as needed
              child: Text(
                "Id: $id",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 40, // Adjust the top position as needed
              left: 10, // Adjust the left position as needed
              child: Text(
                "Weight: $weight",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
