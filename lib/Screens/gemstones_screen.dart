//final_silver_screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:jewellery/Screens/common_screen.dart';

class GemStonesScreen extends StatefulWidget {
  const GemStonesScreen({Key? key}) : super(key: key);

  @override
  State<GemStonesScreen> createState() => _GemStonesScreenState();
}

class _GemStonesScreenState extends State<GemStonesScreen> {
  int currentTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  String selectedCategory = '';
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final String mainFolder = 'GemStones';

  final List<String> titles = [
    'Navaratnallu',
    'Even more GemStones',
  ];

  final List<List<String>> categoriesForTitles = [
    [
      'Kempu',
      'Diamond',
      'Blue Safare',
      'Yellow Safare',
      'Hessonite',
      'Cats Eye',
      'Paral',
      'Koral',
      'Emerold',
    ],
    [
      'Rudrakshalu',
      'Spatikalu',
      'Semi Freshes',
    ],
  ];

  final Map<String, String> itemImages = {
    'Kempu': 'gemstones KEMPU.PNG',
    'Diamond': 'gemstones diamond.jpg',
    'Blue Safare': 'gemstone bluesafare.jpg',
    'Yellow Safare': 'gemstones yellowsafare.PNG',
    'Hessonite': 'gemstone hessonite.jpg',
    'Cats Eye': 'gemstone catseye.jpg',
    'Paral': 'gemstone paral.PNG',
    'Koral': 'gemstone koral.jpg',
    'Emerold': 'gemstone emerold.PNG',
    'Rudrakshalu': 'gemstone rudhraksha.jpg',
    'Spatikalu': 'gemstone spatikalu.PNG',
    'Semi Freshes': 'gemstone semifreshes.jpg',
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToCategory(String category) {
    final index = categoriesForTitles[currentTabIndex].indexOf(category);
    if (index != -1) {
      // Scroll to the selected category
      _scrollController.animateTo(
        index.toDouble() * 95.0, // Adjust for your itemHeight
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.grey[300],
        title: Center(
          child: Text(
            mainFolder,
            style: GoogleFonts.rowdies(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () async {
                await showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(
                    categoriesForTitles: categoriesForTitles[currentTabIndex],
                  ),
                ).then(
                  (selectedCategory) {
                    if (selectedCategory != null &&
                        selectedCategory.isNotEmpty) {
                      scrollToCategory(selectedCategory);
                      setState(() {
                        this.selectedCategory = selectedCategory;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // CUSTOM TABBAR
          Container(
            margin: EdgeInsets.all(10),
            width: double.infinity,
            height: 60,
            child: ListView.builder(
              itemCount: titles.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentTabIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(3),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: currentTabIndex == index
                          ? Colors.orange
                          : Colors.white70,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: currentTabIndex == index
                            ? Colors.orange
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        titles[index],
                        style: GoogleFonts.mateSc(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: currentTabIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // MAIN BODY
          Expanded(
            child: AnimatedList(
              key: _listKey,
              controller: _scrollController,
              initialItemCount: categoriesForTitles[currentTabIndex].length,
              itemBuilder: (context, itemIndex, animation) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate the item height based on the constraints

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommonScreen(
                                  title: categoriesForTitles[currentTabIndex]
                                      [itemIndex],
                                  categories:
                                      categoriesForTitles[currentTabIndex],
                                  mainFolder: mainFolder,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.all(7.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/${itemImages[currentTabIndex]?[itemIndex]}',
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                    border: Border.all(
                                      color: Colors.black26,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        categoriesForTitles[currentTabIndex]
                                            [itemIndex],
                                        style: GoogleFonts.vollkorn(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.double_arrow),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
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

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<String> categoriesForTitles;

  CustomSearchDelegate({required this.categoriesForTitles});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Perform the search and display results
    final suggestionList = categoriesForTitles
        .where(
            (category) => category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index]),
          onTap: () {
            close(context, suggestionList[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as the user types
    final suggestionList = categoriesForTitles
        .where(
            (category) => category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index]),
          onTap: () {
            close(context, suggestionList[index]);
          },
        );
      },
    );
  }
}
