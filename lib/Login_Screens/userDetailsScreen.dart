import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:jewellery/Screens/home_screen.dart';
import 'package:jewellery/Screens/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userDetailsScreen extends StatefulWidget {
  String userPhoneNumber_;

  userDetailsScreen({super.key, required this.userPhoneNumber_});

  @override
  State<userDetailsScreen> createState() => _userDetailsScreenState();
}

class _userDetailsScreenState extends State<userDetailsScreen> {
  TextEditingController _userNameCtrl = TextEditingController();
  TextEditingController _userEmailCtrl = TextEditingController();
  TextEditingController _userCityCtrl = TextEditingController();
  bool isLoading = false;

  //checking wether the user exist or not
  Future<void> saveUserDataToFirestoreAndSharedPreferences() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('users').add({
        'userPhoneNumber': widget.userPhoneNumber_,
        'userName': _userNameCtrl.text,
        'userEmail': _userEmailCtrl.text,
        'userCity': _userCityCtrl.text,
        'Admin': '',
        'TimeStamp': Timestamp.now(),
      });

      // Save user data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('userPhoneNumber', _userPhoneCtrl.text);
      await prefs.setString('userName', _userNameCtrl.text);
      await prefs.setString('userEmail', _userEmailCtrl.text);
      await prefs.setString('userCity', _userCityCtrl.text);
      await prefs.setString('userPhoneNumber', widget.userPhoneNumber_);

      print('User data saved to Firestore and SharedPreferences');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 70),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Let us know about you more!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          SizedBox(height: 25),
                          _buildTextFormField(
                            labelText: "Full Name",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.name,
                            controller: _userNameCtrl,
                          ),
                          //fill name field end

                          SizedBox(height: 25),
                          _buildTextFormField(
                            labelText: "Email",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.emailAddress,
                            controller: _userEmailCtrl,
                          ),
                          //email field end

                          SizedBox(height: 25),
                          _buildTextFormField(
                            labelText: "City",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.name,
                            controller: _userCityCtrl,
                          ),
                          //city field end
                          SizedBox(
                            height: 20,
                          ),
                          //save new user details to firestore button start
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              "Getting Started",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await saveUserDataToFirestoreAndSharedPreferences();
                              setState(() {
                                isLoading = false;
                              });
                              Get.offAll(TabsScreen());
                            },
                          ),
                          //save new user details to firestore button end

                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isLoading,
                    child: Center(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      style: TextStyle(color: Colors.grey[800]),
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey[800]),
      ),
    );
  }
}
