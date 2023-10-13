//whishlistScreen
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewellery/Login_Screens/user_check.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class WishlistScreen extends StatefulWidget {
  final String wishlistUserCollectionDocName;
  final String userName;

  const WishlistScreen({
    Key? key,
    required this.wishlistUserCollectionDocName,
    required this.userName,
  }) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

var logger = Logger();

class _WishlistScreenState extends State<WishlistScreen> {
  String generatedId = '';
  final firestore = FirebaseFirestore.instance;
  late TabController tabController;
  List<String> selectedImages = [];
  bool isSelectionMode = false;
  int currentCount = 0;
  double weight = 0;
  Map<String, dynamic> imageUrlCache = {};
  List<DocumentReference> imageUrls = [];
  List<SelectedItem> selectedItems = [];
  bool isLoading = false;
  // String? userPhoneNumber;
  // String? userName;
  // String wishlistUserCollectionDocName = '';

  @override
  void initState() {
    super.initState();
    _loadImagesForCategory();
  }

  Stream<QuerySnapshot> getWishlistImagesStream() {
    return FirebaseFirestore.instance
        .collection('Wishlist')
        .doc(widget.wishlistUserCollectionDocName)
        .collection('Wishlist')
        .snapshots(); // Listen to changes in the collection
  }

  void _loadImagesForCategory() {
    final stream = getWishlistImagesStream();

    stream.listen((QuerySnapshot querySnapshot) {
      // This code will be executed whenever there's a change in the Firestore collection.
      final List<DocumentReference> refs = querySnapshot.docs
          .map((doc) => doc.reference)
          .where((ref) => ref != null)
          .toList();

      setState(() {
        imageUrls = refs;
      });
    });
  }

  void _showImagePopup(
      BuildContext context, String imageUrl, String id, String weight) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
      },
    );
  }

  Future<void> _shareSelectedImages() async {
    if (selectedImages.isNotEmpty) {
      final List<String> imageFiles = [];

      for (final imageRef in selectedImages) {
        final filePath = await _downloadImage(imageRef);
        if (filePath.isNotEmpty) {
          imageFiles.add(filePath);
        }
      }

      if (imageFiles.isNotEmpty) {
        Share.shareFiles(imageFiles,
            text: 'Sharing ${selectedImages.length} images');
      } else {
        // Handle the case when no images could be downloaded.
        print('No images to share.');
      }
    }
  }

  Future<String> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }

    return ''; // Return an empty string if there's an error
  }

  Future<void> _shareImages(List<String> imageUrls) async {
    final List<String> imageFiles = [];

    for (final imageUrl in imageUrls) {
      final filePath = await _downloadImage(imageUrl);
      imageFiles.add(filePath);
    }

    Share.shareFiles(imageFiles, text: 'Sharing ${imageUrls.length} images');
  }

  Future<void> toggleWishlist(imageUrl, id, weight) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore
          .collection('Wishlist')
          .doc(widget.wishlistUserCollectionDocName)
          .collection('Wishlist');

      final existingDoc = await collection
          .where('imageUrl', isEqualTo: imageUrl)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        // Item exists in the wishlist, remove it
        await collection.doc(existingDoc.docs.first.id).delete();
        imageUrlCache.remove(existingDoc.docs.first.reference.path);
        setState(() {
          imageUrlCache;
        });
      } else {
        print('Error toggling wishlist: ');
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Center(
          child: Text(
            "Wishlist",
            style: GoogleFonts.rowdies(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                _shareSelectedImages();
              },
              icon: const Icon(
                Icons.share,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ],
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Visibility(
                visible: isLoading,
                child: SpinKitCircle(
                  size: 120,
                  itemBuilder: (context, index) {
                    final colors = [Colors.orangeAccent, Colors.black];
                    final color = colors[index % colors.length];

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: imageUrls.isEmpty
                  ? const Center(
                      // Show a message when there are no images in the wishlist
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your wishlist is empty!',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'To add images to your wishlist, press the',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 30,
                                color: Colors.red,
                              ),
                              Text(
                                ' icon on your favorite images.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : buildGridView(imageUrls), // Display images
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            final whatsappLink =
                'https://wa.me/919247879511?text=Hi%2C%20Balaji%20Jewellers%2C%20I%20am%20${widget.userName}%20and%20interested%20in%20your%20catalogue';
            launch(whatsappLink);
          },
          child: Container(
            width: 80.0, // Adjust the width of the rectangular container
            height: 56.0, // Adjust the height of the rectangular container
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  11.0), // Adjust the border radius as needed
              color: Colors.green,
            ),
            child: Image.asset(
              "assets/images/wa.jpg", // Replace with the path to your asset
              width: 66.0, // Adjust the width of the image
              height: 42.0, // Adjust the height of the image
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGridView(List<DocumentReference<Object?>> imageUrls) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        mainAxisExtent: 270,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (BuildContext context, index) {
        final documentReference = imageUrls[index];

        return FutureBuilder<Map<String, dynamic>>(
          future: _getImageUrlFromReference(documentReference),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.white,
                ),
              );
            } else if (snapshot.hasError) {
              return const Text('Error loading image');
            } else {
              final data = snapshot.data;
              final imageUrl = data?['imageUrl'];
              final id = data?['id'];
              final weight = data?['weight'];
              final isSelected = selectedImages.contains(imageUrl);
              return Container(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelectionMode) {
                          if (!isSelected) {
                            selectedImages.add(imageUrl!);
                          } else {
                            selectedImages.remove(imageUrl);
                            if (selectedImages.isEmpty) {
                              isSelectionMode = false;
                            }
                          }
                        } else {
                          _showImagePopup(context, imageUrl!, id, weight);
                        }
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        isSelectionMode = !isSelectionMode;
                        if (!isSelected) {
                          selectedImages.add(imageUrl!);
                        }
                      });
                    },
                    child: Container(
                      height: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 190,
                                width: 190,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl.toString(),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.delete),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  "Weight : $weight",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Id : $id',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        toggleWishlist(
                                            imageUrl, id, weight.toString());
                                      },
                                      icon: Icon(
                                        Icons.favorite,
                                        size: 30,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getImageUrlFromReference(
      DocumentReference reference) async {
    final String refPath = reference.path;

    if (imageUrlCache.containsKey(refPath)) {
      return imageUrlCache[refPath];
    }

    try {
      final snapshot = await reference.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        if (data.isNotEmpty && data.containsKey('imageUrl')) {
          final imageUrl = data['imageUrl'] as String;
          final Id = data['id'] as String;
          final weight = data['weight'] as String;

          imageUrlCache[refPath] = {
            'imageUrl': imageUrl,
            'id': Id,
            'weight': weight,
          };

          return imageUrlCache[refPath];
        }
      }
    } catch (e) {
      print('Error fetching image URL: $e');
    }

    return {};
  }
}

class SelectedItem {
  final String imageUrls;
  bool isSelected;

  SelectedItem(this.imageUrls, {this.isSelected = false});
}
