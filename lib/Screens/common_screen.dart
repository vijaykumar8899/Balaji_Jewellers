//final_Common_Screen

//final_common_screen

import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewellery/Screens/common_screen.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:fast_cached_network_image/fast_cached_network_image.dart';
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
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CommonScreen extends StatefulWidget {
  final String mainFolder;
  final String title;
  final List<String> categories;

  const CommonScreen(
      {Key? key,
      required this.title,
      required this.categories,
      required this.mainFolder})
      : super(key: key);

  @override
  _CommonScreenState createState() => _CommonScreenState();
}

class _CommonScreenState extends State<CommonScreen>
    with SingleTickerProviderStateMixin {
  // final String mainFolder = 'Gold';
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
  List<String> isInWishlist = [];
  bool isLoading = false;
  var logger = Logger();

  String? Admin;
  String? userPhoneNumber;
  String? userName;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories[0];
    _loadImagesForCategory(selectedCategory);
    tabController = TabController(
      length: widget.categories.length,
      vsync: this, // Provide the SingleTickerProviderStateMixin
    );
    tabController.addListener(_handleTabChange); // Listen to tab changes
    getUserDataFromSharedPreferences();
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Admin = prefs.getString('Admin');
      userPhoneNumber = prefs.getString('userPhoneNumber');
      userName = prefs.getString('userName');
      if (Admin!.isNotEmpty && Admin == 'Admin') {
        setState(() {
          isAdmin = true;
        });
      }
    });
  }

  void _loadImagesForCategory(String category) async {
    try {
      final QuerySnapshot categoryQuery = await FirebaseFirestore.instance
          .collection(widget.mainFolder)
          .doc(widget.title)
          .collection(category) // Use the provided category argument
          .where('imageUrl', isNotEqualTo: null)
          .get();

      final List<DocumentReference> refs = categoryQuery.docs
          .map((doc) => doc.reference)
          .where((ref) => ref != null)
          .toList();

      setState(() {
        imageUrlsByCategory[category] = refs.cast<DocumentReference>();
        print("START");
        print(imageUrlsByCategory[category]);
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

  Future<int> fetchTotalFromCatagory() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference docRef = firestore
        .collection('${widget.mainFolder}_Calculation')
        .doc(widget.title)
        .collection(selectedCategory)
        .doc('numberOfDocuments');

    try {
      await firestore.runTransaction((transaction) async {
        // Get the current document
        DocumentSnapshot docSnapshot = await transaction.get(docRef);

        // Check if the document exists
        if (docSnapshot.exists) {
          // Access the "numberOfDocuments" field
          currentCount = docSnapshot['numberOfDocuments'];
        } else {
          // If the document doesn't exist, create it with a count of 1
          transaction.set(docRef, {'numberOfDocuments': 1});
        }
      });

      print('numberOfDocuments feteched from Firestore.');
    } catch (error) {
      print('Error updating numberOfDocuments: $error');
    }

    return currentCount;
  }

  Future<void> _uploadImageToFirebase(String imageUrls) async {
    int total = await fetchTotalFromCatagory();
    print("fetched total from firestore $total");
    // Generate a new ID with updated image count

    await showNumberInputDialog(context, "Enter Weight");

    String generatedId = await _generateId(total);

    String formattedWeight = weight.toStringAsFixed(3);

    print(selectedCategory);
    final storageRef = storage.ref().child(
        '${widget.mainFolder}/${widget.title}/$selectedCategory/${widget.title + generatedId}');
    try {
      final uploadTask = storageRef.putFile(File(imageUrls));
      await uploadTask.whenComplete(() async {
        logger.i('Image uploaded successfully');

        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();

        // Store the image reference in Firestore
        await firestore
            .collection(widget.mainFolder)
            .doc(widget.title)
            .collection(selectedCategory)
            .add({
          'imageUrl': imageUrl,
          'category': selectedCategory,
          'id': generatedId,
          'weight': formattedWeight,
          'ImageName':
              widget.mainFolder + widget.title + selectedCategory + generatedId,
          'TimeStamp': Timestamp.now(),
        });

        // Reload the images for the current category
        _loadImagesForCategory(selectedCategory);

        // Update image count for the selected category
        await firestore
            .collection(widget.mainFolder)
            .doc(widget.title)
            .collection(selectedCategory)
            .doc('numberOfDocuments')
            .update({
          'numberOfDocuments': FieldValue.increment(1),
        }).then((value) {
          print('TotalChanddha updated in Firestore.');
        }).catchError((error) {
          print('Error');
        });

        //saving data in search collection
        await firestore.collection('Search').add({
          'imageUrl': imageUrl,
          'id': generatedId,
          'weight': weight.toString(),
          'ImageName': widget.title + generatedId,
          'TimeStamp': Timestamp.now(),
        }).then((value) {
          print(' updated  search collection in Firestore.');
        }).catchError((error) {
          print('Error while updaing search collection in firestore');
        });
      });
    } catch (e) {
      logger.e('Error uploading image', e);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> _generateId(int total) async {
    String mainFolderFirstLetter = widget.mainFolder.substring(0, 1);
    String titleFirstLetter =
        widget.title.split(' ').map((word) => word.substring(0, 1)).join('');
    String categoryFirstLetter = selectedCategory.substring(0, 1);

    String id =
        '$mainFolderFirstLetter$titleFirstLetter$categoryFirstLetter$total';

    return id;
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
    setState(() {
      isLoading = false;
    });
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

  Future<void> _customShare(double numberOfImages) async {
    if (numberOfImages <= 0) {
      // Handle invalid input, e.g., show an error message to the user.
      return;
    }

    try {
      final List<String> imageUrls =
          await _fetchImageUrlsFromFirestore(numberOfImages);

      if (imageUrls.isNotEmpty) {
        final List<String> imageFiles = [];

        for (final imageUrl in imageUrls) {
          final filePath = await _downloadImage(imageUrl);
          imageFiles.add(filePath);
        }

        Share.shareFiles(imageFiles,
            text: 'Sharing ${imageUrls.length} images');
      } else {
        Fluttertoast.showToast(
          msg: "No Images found in Database",
          toastLength: Toast.LENGTH_SHORT, // Duration for the toast message
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          backgroundColor: Colors.red, // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the toast text
        );
      }
    } catch (e) {
      // Handle any errors that occur during sharing or fetching images.
      print('Error sharing images: $e');
      throw e; // Rethrow the error to be caught by the FutureBuilder
    }

    setState(() {
      isLoading = false;
    });
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

  Future<void> showNumberInputDialog(BuildContext context, String name) async {
    setState(() {
      isLoading = false;
    });

    double? InputNumber;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$name'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Number'),
            onChanged: (value) {
              // Parse the input to an integer and store it in selectedNumber
              InputNumber = double.tryParse(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                switch (name) {
                  case "Enter Number":
                    if (InputNumber != null) {
                      setState(() {
                        isLoading = true;
                      });
                      _customShare(InputNumber!);
                    } else {
                      // Handle invalid input or null case
                    }
                    break;
                  case "Enter Weight":
                    if (InputNumber != null) {
                      weight = InputNumber!;
                      setState(() {
                        isLoading = true;
                      });
                    } else {
                      // Handle invalid input or null case
                    }
                    break;
                  case "Enter Wathsapp Number":
                    if (InputNumber != null) {
                    } else {
                      // Handle invalid input or null case
                    }
                    break;
                  default:
                    // Handle unknown name
                    break;
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> toggleWishlist(imageUrl, id, weight) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore
          .collection('Wishlist')
          .doc("${userName}_$userPhoneNumber")
          .collection('Wishlist');

      final existingDoc = await collection
          .where('imageUrl', isEqualTo: imageUrl)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        // Item exists in the wishlist, remove it
        await collection.doc(existingDoc.docs.first.id).delete();
        setState(() {
          isInWishlist.remove(imageUrl); // Remove from the list
        });
      } else {
        // Item does not exist in the wishlist, add it
        await collection.add({
          'imageUrl': imageUrl,
          'id': id,
          'weight': weight,
        });
        setState(() {
          isInWishlist.add(imageUrl); // Add to the list
        });
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
              widget.title, // Display only the selectedCategory
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
              if (isAdmin)
                PopupMenuButton<String>(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  offset: const Offset(40, 0),
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      // Include your PopupMenuItems here
                      PopupMenuItem<String>(
                        value: 'custom_share',
                        child: InkWell(
                          onTap: () {
                            // Handle Custom Share option
                            setState(() {
                              isLoading = true;
                            });
                            showNumberInputDialog(context, "Enter Number");
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Custom Share',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: InkWell(
                          onTap: () {
                            // Handle Delete option
                            showDeleteConfirmationDialog();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
            ],
            elevation: 0,
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
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
                          color: Colors.orangeAccent,
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
              Visibility(
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
            ],
          ),
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  onPressed: () async {
                    final pickedImage = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      _uploadImageToFirebase(pickedImage.path);
                    }
                  },
                  child: const Icon(Icons.add),
                )
              : null),
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
              final isInWish = isInWishlist.contains(imageUrl);
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
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              if (isSelected) // This if condition is now inside the Stack
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.orangeAccent,
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
                                        isInWish
                                            ? Icons.favorite
                                            : Icons.favorite_outline,
                                        size: 30,
                                        color: isInWish
                                            ? Colors.red
                                            : Colors.black,
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
    final firestore = FirebaseFirestore.instance;
    final collection = firestore
        .collection(widget.mainFolder)
        .doc(widget.title)
        .collection(selectedCategory);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Selected Items?'),
          content:
              const Text('Are you sure you want to delete the selected items?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Implement delete logic here
                for (var imageUrl in selectedImages) {
                  try {
                    final existingDoc = await collection
                        .where('imageUrl', isEqualTo: imageUrl)
                        .limit(1)
                        .get();

                    if (existingDoc.docs.isNotEmpty) {
                      // Item exists in the wishlist, remove it
                      await collection.doc(existingDoc.docs.first.id).delete();
                      imageUrlCache
                          .remove(existingDoc.docs.first.reference.path);
                      setState(() {
                        imageUrlCache;
                      });
                    } else {
                      print('Error  Deleting images: ');
                    }
                  } catch (e) {
                    print('Error Deleting images: $e');
                  }
                }
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
        print(data);
        if (data.isNotEmpty && data.containsKey('imageUrl')) {
          final imageUrl = data['imageUrl'] as String;
          final Id = data['id'] as String;
          final weight = data['weight'] as String; // Cast to String if needed

          try {
            final querySnapshot = await FirebaseFirestore.instance
                .collection('Wishlist')
                .doc("$userName+'_'$userPhoneNumber")
                .collection('Wishlist')
                .where('imageUrl', isEqualTo: imageUrl)
                .get();

            if (querySnapshot.docs.isNotEmpty) {
              // If there are any documents with the same imageUrl, it's in the Wishlist
              isInWishlist.add(imageUrl);
            }

            // If there are any documents with the same imageUrl, it's in the Wishlist
          } catch (e) {
            print('Error checking imageUrl in Wishlist: $e');
            // Handle the error case accordingly
          }

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
