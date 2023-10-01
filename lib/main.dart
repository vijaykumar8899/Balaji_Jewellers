//main

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jewellery/Login_Screens/signin_screen.dart';
import 'package:jewellery/Login_Screens/userDetailsScreen.dart';
import 'package:jewellery/Screens/home_screen.dart';
import 'package:jewellery/Login_Screens/user_check.dart';
import 'package:jewellery/Screens/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userPhoneNumber = prefs.getString('userPhoneNumber');

  final AuthService authService = AuthService();

  if (userPhoneNumber != null) {
    final bool phoneNumberExists =
        await authService.doesUserPhoneNumberExist(userPhoneNumber);

    if (!phoneNumberExists) {
      // Clear userPhoneNumber from SharedPreferences
      await prefs.remove('userPhoneNumber');
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: TabsScreen(),
      title: "Balaji Jewellers",
    );
  }
}
