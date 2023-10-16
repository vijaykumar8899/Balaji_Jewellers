import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jewellery/Login_Screens/welcome_screen.dart';
import 'package:jewellery/Login_Screens/user_check.dart';
import 'package:jewellery/Screens/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jewellery/api/push_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userPhoneNumber = prefs.getString('userPhoneNumber');

  final FirebaseApi firebaseApi = FirebaseApi(); // Creating an instance
  await firebaseApi
      .initNotifications(); // Calling the notification function inside api/push_notifications using  instance

  final AuthService authService = AuthService();
  bool userLoggedIn = false;
  if (userPhoneNumber != null) {
    userLoggedIn = await authService.doesUserPhoneNumberExist(userPhoneNumber);

    if (!userLoggedIn) {
      // Clear userPhoneNumber from SharedPreferences
      await prefs.remove('userPhoneNumber');
    }
  }

  runApp(MyApp(userLoggedIn: userLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool userLoggedIn;

  const MyApp({Key? key, required this.userLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: userLoggedIn ? TabsScreen() : WelcomeScreen(),
      title: "Balaji Jewellers",
    );
  }
}
