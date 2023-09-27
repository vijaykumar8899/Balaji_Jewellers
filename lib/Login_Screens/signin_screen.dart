import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:jewellery/Login_Screens/userDetailsScreen.dart';
import 'package:jewellery/Screens/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _phoneNumberCtrl = TextEditingController();
  TextEditingController _otpCtrl = TextEditingController();
  bool showOTPField = false; // Initially hide OTP field
  String _verificationId = '';
  bool isLoading = false;
  //checking wether the user exist or not
  Future<void> saveUserDataToSharedPreferences(String _userPhoneNumber) async {
    print('phoneNumber inside existing user check $_userPhoneNumber');
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Query the 'users' collection for the provided phone number
      QuerySnapshot querySnapshot = await usersCollection
          .where('userPhoneNumber', isEqualTo: _userPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a document with the provided phone number exists, fetch its data
        DocumentSnapshot document = querySnapshot.docs.first;
        print('Document data: ${document.data()}');

        String userPhoneNumber = document['userPhoneNumber'];
        String userName = document['userName'];
        String userCity = document['userCity'];
        String userEmail = document['userEmail'];
        String Admin = document['Admin'];

        // Save user data to SharedPreferences

        // Save user data to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPhoneNumber', userPhoneNumber);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userName', userName);
        await prefs.setString('userCity', userCity);
        await prefs.setString('Admin', Admin);

        print('User data saved to SharedPreferences');
        Get.offAll(TabsScreen());
        isLoading = false;
      } else {
        // If the phone number does not exist in the 'users' collection, return null
        print('User not found in Firestore');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => userDetailsScreen(
              userPhoneNumber_: _userPhoneNumber,
            ),
          ),
        );
        isLoading = false;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> loginWithPhone() async {
    String PhoneNumber = formatPhoneNumber(_phoneNumberCtrl.text);
    print(PhoneNumber);
    // userPhoneNumber = _phoneNumberCtrl.text;
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: PhoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
          // This callback will be called when the verification is completed automatically
          // using the auto-retrieval method.
        },
        verificationFailed: (FirebaseAuthException authException) {
          print('Phone verification failed. Code: ${authException.code}');
          // Handle the error, e.g., show an error message to the user.
        },
        codeSent: (String verificationId, [int? forceResendingToken]) {
          // verifyOTP(verificationId);
          _verificationId = verificationId;
          print('verificationId : $verificationId');
          print('_verificationId : $_verificationId');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout, handle the situation here
        },
      );
    } catch (e) {
      print('Error sending OTP: $e');
      Get.showSnackbar(GetBar(
        message: e.toString(),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> verifyOTP(String otp) async {
    String PhoneNumber = formatPhoneNumber(_phoneNumberCtrl.text);

    try {
      if (_verificationId.isNotEmpty) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: otp,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          // If OTP is verified successfully, navigate to the next screen
          // ignore: use_build_context_synchronously
          await saveUserDataToSharedPreferences(PhoneNumber);
        } else {
          print('Error verifying OTP');
          Get.showSnackbar(GetBar(
            message: 'Incorrect OTP',
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        print("Sending OTP failed");
        Get.showSnackbar(GetBar(
          message: "Sending OTP failed, Retry after some time",
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      Get.showSnackbar(GetBar(
        message: e.toString(),
        duration: Duration(seconds: 2),
      ));
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    // Remove any non-numeric characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (!phoneNumber.startsWith('91')) {
      phoneNumber = '91$phoneNumber';
    }

    if (phoneNumber.length == 10 && phoneNumber.startsWith('91')) {
      phoneNumber = '91$phoneNumber';
    }

    // Check if the number starts with a leading plus (+)
    if (!phoneNumber.startsWith('+')) {
      // Add the leading plus for international format
      phoneNumber = '+$phoneNumber';
    }
    print('phoneNumber : $phoneNumber');
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        "Welcome Back!",
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
                        labelText: "Phone Number",
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        controller: _phoneNumberCtrl,
                      ),

                      // Phone number input end

                      if (showOTPField) // Show OTP field conditionally
                        ...[
                        Column(
                          children: [
                            SizedBox(height: 15),
                            _buildTextFormField(
                              labelText: "OTP",
                              prefixIcon: Icons.security,
                              keyboardType: TextInputType.number,
                              controller: _otpCtrl,
                            ),
                            SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                "Verify OTP",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                isLoading = true;
                                verifyOTP(
                                    _otpCtrl.text); // Pass verificationId here
                                print('_otpCtrl : $_otpCtrl');
                              },
                            ),
                          ],
                        ),
                      ] else ...[
                        Column(
                          // Wrap the else block in a Column
                          children: [
                            SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                "Send OTP",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                loginWithPhone();
                                setState(() {
                                  showOTPField = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ]
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
