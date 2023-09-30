//HOMESCREEN FINAL
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewellery/Screens/Search.dart';
import 'package:jewellery/Screens/diamonds_screen.dart';
import 'package:jewellery/Screens/profile.dart';
import 'gemstones_screen.dart';
import 'gold_screen.dart';
import 'rosegold_screen.dart';
import 'silver_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> images = [
    'assets/images/poster1.jpg',
    'assets/images/image 2.jpg',
    'assets/images/poster2.jpg',
    'assets/images/poster3.png',
    'assets/images/jj.jpg',
    'assets/images/poster6.jpg',
    'assets/images/poster7.jpg',
    'assets/images/poster8.jpg',
  ];

  final FocusNode _focusNode = FocusNode();

  void _showUnderDevelopmentMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Under Development"),
          content: Text("This feature is currently under development."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/images/logo9.png',
                  width: 42,
                  height: 42,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.045,
            ), // Adjust the multiplier as needed
            Text(
              "SriBalajiJewelers",
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
            SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.045), // Adjust the multiplier as needed
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.white54,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Get.to(ProfileScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKfHVThC6NDvAo7W_aBedFmduYaNv6oXl-5T0lykgFHRoznpF85SfTb5c17nw9LqJVY94&usqp=CAU',
                      width: MediaQuery.of(context).size.width *
                          0.08, // Adjust this value as needed
                      height: MediaQuery.of(context).size.width *
                          0.08, // Adjust this value as needed
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                        onTap: () {
                          _focusNode.unfocus();
                          Get.to(SearchScreen());
                        },
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        decoration: InputDecoration(
                          hintText: "Search for Ornaments",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 20),
                        ),
                        focusNode: _focusNode,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showUnderDevelopmentMessage();
                      },
                      icon: Icon(Icons.mic),
                      color: Colors.black87,
                    ),
                    IconButton(
                      onPressed: () {
                        _showUnderDevelopmentMessage();
                      },
                      icon: Icon(Icons.settings),
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            CustomCarouselSlider(images: images),
            SizedBox(height: 25),
            Container(
              height: 335,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: (200 / 274),
                children: <Widget>[
                  CategoryCard(
                    image: "assets/images/rk1.6.png",
                    title: "Gold",
                    onTap: () {
                      Get.to(GoldScreen());
                    },
                  ),
                  CategoryCard(
                    image: "assets/images/rk1.4.png",
                    title: "Silver",
                    onTap: () {
                      Get.to(SilverScreen());
                    },
                  ),
                  CategoryCard(
                    image: "assets/images/diamon.png",
                    title: "Diamond",
                    onTap: () {
                      Get.to(DiamondScreen());
                    },
                  ),
                  CategoryCard(
                    image: "assets/images/ty.jpg",
                    title: "Gemstone",
                    onTap: () {
                      Get.to(GemStonesScreen());
                    },
                  ),
                  CategoryCard(
                    image: "assets/images/rosegold1.png",
                    title: "RoseGold",
                    onTap: () {
                      Get.to(RoseGoldScreen());
                    },
                  ),
                  ExtraCategoryCard(
                    image1:
                        "https://logowik.com/content/uploads/images/297_whatsapp504.jpg",
                    image2:
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpbUffaI6NuBLZZx2ubInOAeGr_zbsJ6kMNJ41xNBUKVNUM9WimFjKZIPTFCoj4DD7258&usqp=CAU",
                    onTapImage1: () {
                      final whatsappLink =
                          'https://wa.me/919247879511?text=Hi%20Balaji%20Jewellers';
                      launch(whatsappLink);
                    },
                    onTapImage2: () {
                      final whatsappLink =
                          'https://www.facebook.com/profile.php?id=100054242660344&mibextid=ZbWKwL';
                      launch(whatsappLink);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCarouselSlider extends StatefulWidget {
  final List<String> images;

  CustomCarouselSlider({required this.images});

  @override
  _CustomCarouselSliderState createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.width * 0.48,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 4 / 3,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.images.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(.4),
                        Colors.black.withOpacity(.2),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.asset(
                        item,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.images.map((url) {
            int index = widget.images.indexOf(url);
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentIndex == index ? Colors.orange : Colors.grey[600],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CategoryCard extends StatefulWidget {
  final String image;
  final String title;
  final VoidCallback onTap;

  CategoryCard({
    required this.image,
    required this.title,
    required this.onTap,
  });

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isTapped = true;
        });
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {
            isTapped = false;
          });
          widget.onTap();
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  isTapped ? Colors.transparent : Colors.grey.withOpacity(0.01),
              spreadRadius: isTapped ? 0 : 2,
              blurRadius: isTapped ? 0 : 10,
              offset: isTapped ? Offset(0, 0) : Offset(0, 3),
            ),
          ],
          color: isTapped ? Colors.orangeAccent : Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                widget.image,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tradeWinds(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                    shadows: [
                      Shadow(
                        offset: Offset(4, 4),
                        blurRadius: 3,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExtraCategoryCard extends StatelessWidget {
  final String image1;
  final String image2;
  final VoidCallback onTapImage1;
  final VoidCallback onTapImage2;

  ExtraCategoryCard({
    required this.image1,
    required this.image2,
    required this.onTapImage1,
    required this.onTapImage2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle onTap for the entire card, if needed
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.01),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 64,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                child: GestureDetector(
                  onTap: onTapImage1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      image1,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 8,
              color: Colors.grey[300],
            ),
            Container(
              height: 64,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                child: GestureDetector(
                  onTap: onTapImage2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      image2,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
