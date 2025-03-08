import 'dart:convert';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/login/ngosignup.dart';
import 'package:relieflink/login/signupscreen2.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/models/users.dart';
import 'package:relieflink/screens/home_page.dart';
import 'package:relieflink/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredFirstName = '';
  String _enteredLastName = '';
  String _enteredContact = '';
  String _enteredLocation = '';
  String _emergencyDetails = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    bool shouldSend = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send OTP?"),
        content: Text("Do you want to send the OTP to $_enteredEmail?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes")),
        ],
      ),
    );
    if (shouldSend == true) {
      if (await verifyIfAccExists(_enteredEmail) == false) {
        sendOTP();
        final citizen = Citizen(
          email: _enteredEmail,
          firstName: _enteredFirstName,
          lastName: _enteredLastName,
          contact: _enteredContact,
          location: _enteredLocation,
          emergencyDetails: _emergencyDetails,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => SignUpScreen2(
                    email: _enteredEmail,
                    citizen: citizen,
                  )),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Email already registered. Please log in.")),
        );
      }
    }
  }

  void sendOTP() {
    EmailOTP.config(
      appName: 'ReliefLink',
      otpType: OTPType.numeric,
      expiry: 60000,
      emailTheme: EmailTheme.v6,
      appEmail: 'support@relieflink.com',
      otpLength: 4,
    );

    EmailOTP.sendOTP(email: _enteredEmail);
  }

  Future<bool> verifyIfAccExists(String email) async {
    final Uri url =
        Uri.https("relieflink-e824d-default-rtdb.firebaseio.com", "users.json");
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
              return true;
            }
          }
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF2D7DD2),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
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
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'First Name'),
                            onSaved: (value) {
                              _enteredFirstName = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Last Name'),
                            onSaved: (value) {
                              _enteredLastName = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Contact Number'),
                            onSaved: (value) {
                              _enteredContact = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Location'),
                            onSaved: (value) {
                              _enteredLocation = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Emergency Details'),
                            onSaved: (value) {
                              _emergencyDetails = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Send OTP'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              await saveLoginStatus(true);
                              logStatus = true;
                              print('the log status is true now');
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                                (route) => false,
                              );
                            },
                            child: const Text('Temp Login'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'I already have an Account',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NGOSignUpScreen()),
                              );
                            },
                            child: const Text(
                              'Register as an NGO',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 76, 150, 189)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
