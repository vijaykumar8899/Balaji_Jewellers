//final_silver_screen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:jewellery/Screens/common_screen.dart';

class SilverScreen extends StatefulWidget {
  const SilverScreen({Key? key}) : super(key: key);

  @override
  State<SilverScreen> createState() => _SilverScreenState();
}

class _SilverScreenState extends State<SilverScreen> {
  final String mainFolder = 'Silver';
  int currentTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  String selectedCategory = '';
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<String> titles = [
    'Silver Articles',
    'Sterling Silver',
    'Temple Items'
  ];
  final List<List<String>> categoriesForTitles = [
    [
      'Plates',
      'Glasses',
      'Stand Kundhulu',
      'Pancha Patra',
      'Vodharani',
      'AshtaLakshmi Chombu',
      'Plain Chambu',
      'Vigraharalu',
      'Simhasanalu',
      'Short Kundhulu',
      'Agarabathi Stand',
      'Pula Butta',
      'Powder Box',
      'Pattilu',
      'Kadiyalu',
      'Molathallu',
      'Gantalu',
      'Harathi Stands',
      'Pens',
      'Jugs',
      'Bindhalu',
      'Chains',
      'Flowers',
      'Photo Frames',
      'Seta Gopuram',
      'Kiritalu',
      'Bowls',
      'Kunkama Barani',
      'Thamalapakulu',
      'Arati Chetlu',
      'Kobbari Chetlu',
      'Dinner Sets',
      'Eyes', /* ... Add your items here ... */
    ],
    [
      'Ladies Rings',
      'Gents Rings',
      'Necllace',
      'Chains',
      'Harams',
      'Bangles',
      'Chowker Lockets',
      'Chain Lockets',
      'Vadranam',
      'Aravanki',
      'Bracelets',
      'Kadiyalu',
      'Nallapursalu',
      'DD Balls Chains',
      'Black Beats',
      'Jukalu',
      'Buttalu',
      'Diddulu',
      'Chandh Bali',
      'Saniya Rings',
      'Matilu',
      'Champaswaralu',
      'Chevi Chutlu',
      'Chandra Haralu', /* ... Add your items here ... */
    ],
    [
      'Kireetalu',
      'Hasthalu',
      'Vakshasthalam',
      'Kaallu',
      'Nagum Podagalu',
      'paadhalu',
      'kallu',
      'Makarathoranalu',
      'Petalu',
      'Simhasanalu', /* ... Add your items here ... */
    ],
  ];

  final List<List<String>> itemImages = [
    [
      'silverplate.jpg',
      'silverglass.jpg',
      'silverkundhulu.jpg',
      'silverpanchapatra.jpg',
      'silver ashtalakshmichombu.jpg',
      'silver ashtalakshmichombu.jpg',
      'silver plainchombu.jpg',
      'silver vigraharalu.jpg',
      'silver simhasanam.jpg',
      'silver kundhulu.jpg',
      'silver agarabathistand2.png',
      'silver pulabutta.jpg',
      'silver powderbox.png',
      'silver pattilu.PNG',
      'silver kadiyalu.PNG',
      'silver molathallu.jpg',
      'silver ganta.jpg',
      'silver harathistand.jpg',
      'silver pen.jpg',
      'silver jug.PNG',
      'silver binda.jpg',
      'silver chain.PNG',
      'silver flower.jpg',
      'silver photoframe.PNG',
      'silver setagopuram.jpg',
      'silver kireetalu.jpg',
      'silver bowl.jpg',
      'silver kunkuma barani.jpg',
      'silver thamalapakulu.jpg',
      'silver bananatree.jpg',
      'silver coconuttree.jpg',
      'silver dinnerset.jpg',
      'silver eyes.jpg',
      'item7_image.png',
      'item8_image.png', /* ... Add your image paths here ... */
    ],
    [
      's silver ladies ring.PNG',
      's silver mens ring.jpg',
      's silver chains.jpg',
      's silver chain2.jpg',
      's silver haram.jpg',
      's silver bangles.jpg',
      's silver chowkar lockets.png',
      's silver chain lockets.jpg',
      's silver vadranam.png',
      's silver aravanki.jpg',
      's siver bracelets.jpg',
      's silver kadiyalu.jpg',
      's silver nallapursalu.jpg',
      's silver dd ball chains.jpg',
      's silver black beats.PNG',
      's silver jukalu.PNG',
      's silver buttalu.jpg',
      's silver diddulu.PNG',
      's silver chandh bali.jpg',
      's silver saniya rings.PNG',
      's silver matilu.jpg',
      's silver champaswaralu.PNG',
      's silver chevi chutlu.jpg',
      's silver chandra haralu.PNG', /* ... Add your image paths here ... */
    ],
    [
      't-silver-kireetalu.png',
      't silver hastham.PNG',
      'silver vakshasthalam.jpg',
      't silver kaallu.jpg',
      't silver nagumpodagalu.jpg',
      't silver paadhalu.jpg',
      't silver kallu.jpg',
      't silver makarathoranalu.PNG',
      't silver peta.jpg',
      't silver simhasanalu.jpg', /* ... Add your image paths here ... */
    ],
  ];

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
                                  title: titles[currentTabIndex],
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
                                        'assets/images/${itemImages[currentTabIndex][itemIndex]}',
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
