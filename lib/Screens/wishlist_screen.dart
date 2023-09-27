//final_wishlist_screen

//final_Common_Screen

//final_common_screen

import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class WishlistScreen extends StatefulWidget {
  // final String mainFolder = "Wishlist";
  // final String title = "Wishlist";
  // final List<String> categories = ["Wishlist"];

  final String mainFolder;
  final String title;
  final List<String> categories;

  const WishlistScreen(
      {Key? key,
      required this.title,
      required this.categories,
      required this.mainFolder})
      : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

var logger = Logger();

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  static String selectedCategory = '';
  String generatedId = '';
  final firestore = FirebaseFirestore.instance;
  late int selectedTabIndex; // Track the selected tab index
  final storage = FirebaseStorage.instance;
  Map<String, List<DocumentReference>> imageUrlsByCategory =
      {}; // Store fetched image URLs

  late TabController tabController; // Declare TabController
  List<String> selectedImages = []; // Track selected images
  bool isSelectionMode = false; //Track Multiple images select option
  int currentCount = 0;
  double weight = 0;
  Map<String, dynamic> imageUrlCache = {};
  List<SelectedItem> selectedItems = [];

  String? userPhoneNumber;
  String? userName;

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhoneNumber = prefs.getString('userPhoneNumber');
      userName = prefs.getString('userName');
    });
  }

  @override
  void initState() {
    super.initState();
    // selectedTabIndex = 0; // Initialize with the first tab
    selectedCategory = 'Wishlist';
    _loadImagesForCategory(selectedCategory);
    tabController = TabController(
      length: widget.categories.length,
      vsync: this, // Provide the SingleTickerProviderStateMixin
    );
    tabController.addListener(_handleTabChange); // Listen to tab changes
    getUserDataFromSharedPreferences();
  }

  void _loadImagesForCategory(String category) async {
    try {
      final QuerySnapshot categoryQuery = await FirebaseFirestore.instance
          .collection(widget.mainFolder)
          .doc(widget.title)
          .collection(selectedCategory)
          .get();

      final List<DocumentReference> refs = categoryQuery.docs
          .map((doc) => doc.reference)
          .where((ref) => ref != null)
          .toList();

      setState(() {
        imageUrlsByCategory[category] = refs.cast<DocumentReference>();
        print("START");
        print(imageUrlCache);
        print("FINISH ");
      });
    } catch (e) {
      logger.e('Error fetching images', e);
    }
  }

  void _handleTabChange() {
    setState(() {
      selectedCategory =
          widget.categories[tabController.index]; // Update selected category
      print(selectedCategory);
    });

    if (!imageUrlsByCategory.containsKey(selectedCategory)) {
      _loadImagesForCategory(selectedCategory);
    }
  }

  @override
  void dispose() {
    tabController.dispose(); // Dispose of the TabController
    super.dispose();
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

  Future<List<String>> _fetchImageUrlsFromFirestore(
      double numberOfImages) async {
    final List<String> imageUrls = [];

    try {
      final folderName =
          '${widget.mainFolder}/${widget.title}/$selectedCategory';
      final collectionRef = firestore
          .collection(widget.mainFolder)
          .doc(widget.title)
          .collection(selectedCategory);

      final querySnapshot = await collectionRef
          .orderBy('TimeStamp', descending: true)
          .limit(numberOfImages.toInt())
          .get();

      for (final docSnapshot in querySnapshot.docs) {
        final imageUrl = docSnapshot.get('imageUrl') as String;
        imageUrls.add(imageUrl);
      }
    } catch (e) {
      // Handle any errors that occur during Firestore access.
      // You can show an error message or take other appropriate actions.
      print('Error fetching images from Firestore: $e');
    }

    return imageUrls;
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
          .doc("$userName+'_'$userPhoneNumber")
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

  Future<int> _countImagesInCategory(String category) async {
    // Count the number of images in the specified category
    final imageUrls = imageUrlsByCategory[category];
    return imageUrls?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.categories.length,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.grey[300],
          title: Text(
            "$selectedCategory", // Display only the selectedCategory
            style: GoogleFonts.rowdies(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            if (isSelectionMode)
              IconButton(
                onPressed: () {
                  // Handle the Share action here
                  _shareSelectedImages();
                },
                icon: const Icon(
                  Icons.share,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
          ],
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: widget.categories.map((category) {
                    return FutureBuilder<int>(
                      future: _countImagesInCategory(category),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Tab(text: "$category Loading...");
                        } else if (snapshot.hasError) {
                          return Tab(text: "$category Error");
                        } else {
                          final count = snapshot.data ?? 0;
                          return Tab(text: "$category $count");
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: widget.categories.map((category) {
                    final imageUrls = imageUrlsByCategory[category] ?? [];
                    return buildGridView(
                        imageUrls); // Return the result of buildGridView
                  }).toList(), // Convert the mapped results to a list
                ),
              ),
            ],
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
              // While fetching the URL, show the shimmer effect.
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 200, // Adjust the height as needed
                  color: Colors.white,
                ),
              );
            } else if (snapshot.hasError) {
              // Handle the error case if fetching the URL fails.
              return const Text('Error loading image');
            } else {
              final data = snapshot.data;
              final imageUrl = data?['imageUrl'];
              final id = data?['id'];
              final weight = data?['weight'];
              final isSelected = selectedImages.contains(imageUrl);
              // Custom widget implementation here instead of GridItem
              return Container(
                // padding: EdgeInsets.all(10.0),
                // margin: EdgeInsets.all(10.0),
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
                            print("slectedImages : $selectedImages");
                            if (selectedImages.isEmpty) {
                              print("slectedImages : $selectedImages");
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
                              if (isSelected) // This if condition is now inside the Stack
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

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Selected Items?'),
          content:
              const Text('Are you sure you want to delete the selected items?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement delete logic here
                for (var item in selectedItems) {
                  // Delete the selected items from your data source
                  // imageUrls.remove(item.imageUrls);
                }
                // Clear the selected items list
                selectedItems.clear();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void shareSelectedItems() {
    // Implement sharing logic here
    final List<String> selectedimageUrls =
        selectedItems.map((item) => item.imageUrls).toList();
    // Implement the logic to share selectedimageUrls with other apps (e.g., WhatsApp).
  }

  Future<Map<String, dynamic>> _getImageUrlFromReference(
      DocumentReference reference) async {
    final String refPath = reference.path;

    // Check if the image URL is already cached
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
          final weight = data['weight'] as String; // Cast to String if needed

          // Store the fetched image URL in the cache
          imageUrlCache[refPath] = {
            'imageUrl': imageUrl,
            'id': Id,
            'weight': weight, // Convert to String if needed
          };

          return imageUrlCache[refPath];
        }
      }
    } catch (e) {
      print('Error fetching image URL: $e');
    }

    return {}; // Return an empty map or handle the error case accordingly
  }
}

class SelectedItem {
  final String imageUrls;
  bool isSelected;

  SelectedItem(this.imageUrls, {this.isSelected = false});
}
