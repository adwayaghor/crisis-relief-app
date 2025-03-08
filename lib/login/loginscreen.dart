import 'dart:convert';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:relieflink/admin/adminpage.dart';
import 'package:relieflink/login/loginscreen2.dart';
import 'package:relieflink/login/signupscreen.dart';

import 'package:http/http.dart' as http;
import 'package:relieflink/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool itIsNgo = false;
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  // ignore: unused_field
  final _enteredPassword = '';
  // ignore: unused_field
  final _isLogin = true;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    bool shouldSend = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Send OTP?"),
        content: Text(
            "Do you want to send the OTP(One Time Password) to $_enteredEmail?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Yes")),
        ],
      ),
    );

    if (shouldSend == true) {
      if (_enteredEmail == '@admins') {
        await saveAdminStatus(true);
        adminLog = true;
        await saveIDStatus(_enteredEmail);
        universalId = _enteredEmail;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => AdminPage(
                    adminType: _enteredEmail,
                  )),
          (route) => false, // This removes all previous screens
        );
      }
      if (_enteredEmail == '@volunteer') {
        await saveAdminStatus(true);
        adminLog = true;
        await saveIDStatus(_enteredEmail);
        universalId = _enteredEmail;
        print(_enteredEmail);
        // print(universalId);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => AdminPage(
                    adminType: _enteredEmail,
                  )),
          (route) => false, // This removes all previous screens
        );
      }
      if (await verifyIfAccExists(_enteredEmail) == true) {
        sendOTP(_enteredEmail);
        if (itIsNgo) {
          await saveisNGOStatus(true);
          isNGO = true;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen2(
                    email: _enteredEmail,
                  )),
          (route) => false, // This removes all previous screens
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Email not registered. Please Sign Up.")),
        );
      }
    }
  }

  Future<bool> verifyIfAccExists(String email) async {
  final Uri url = Uri.https(
    "relieflink-e824d-default-rtdb.firebaseio.com",
    "users.json",
  ); 

  final Uri url2 = Uri.https(
    "relieflink-e824d-default-rtdb.firebaseio.com",
    "ngos.json",
  );

  bool emailFound = false;

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? users = json.decode(response.body);
      if (users != null) {
        for (var entry in users.entries) {
          var user = entry.value;
          if (user['email'] != null &&
              user['email'].toString().trim().toLowerCase() ==
                  email.trim().toLowerCase()) {
            print('Email found in users.json ✅');
            emailFound = true;
          }
        }
      }
    } else {
      print("Failed to fetch users data: ${response.statusCode}");
    }

    final response2 = await http.get(url2);
    if (response2.statusCode == 200) {
      final Map<String, dynamic>? users2 = json.decode(response2.body);
      if (users2 != null) {
        for (var entry in users2.entries) {
          var user = entry.value;
          if (user['email'] != null &&
              user['email'].toString().trim().toLowerCase() ==
                  email.trim().toLowerCase()) {
            print('Email found in ngos.json ✅');
            emailFound = true;
            itIsNgo = true; // Set NGO flag
          }
        }
      }
    } else {
      print("Failed to fetch ngos data: ${response2.statusCode}");
    }

    if (!emailFound) {
      print('Email NOT found ❌');
    }

    return emailFound;
  } catch (error) {
    print("Error: $error");
    return false;
  }
}


  void sendOTP(String email) {
    EmailOTP.config(
      appName: 'Relief Link',
      otpType: OTPType.numeric,
      expiry: 600000,
      emailTheme: EmailTheme.v6,
      appEmail: 'support@relieflink.com',
      otpLength: 4,
    );

    print(email);
    EmailOTP.sendOTP(email: email);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF2D7DD2),
        extendBody: true,
        body: Container(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Email Address'),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                  print(_enteredEmail);
                                },
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  _submit();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 50, 100, 150),
                                ),
                                child: const Text(
                                  'Send OTP',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Create an account',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
