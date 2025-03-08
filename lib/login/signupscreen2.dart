import 'dart:convert';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:relieflink/login/successscreen.dart';
import 'package:relieflink/models/users.dart';
import 'package:relieflink/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:http/http.dart' as http;

bool isSigningIn = false;

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key, required this.citizen, required this.email});

  final String email;
  final Citizen citizen;

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  final _form = GlobalKey<FormState>();
  String _otp = '';

  int _endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
  bool _isResendEnabled = false;

  late Citizen citizen; // Declare citizen variable
  late String _enteredEmail;

  @override
  void initState() {
    super.initState();
    citizen = widget.citizen; // Assign the citizen object from the widget
    _enteredEmail = widget.email;
  }

  void resendOTP() {
    print("OTP Resent!");
    EmailOTP.config(
      appName: 'Relief Link',
      otpType: OTPType.numeric,
      expiry: 60000,
      emailTheme: EmailTheme.v6,
      appEmail: 'adway.aghor23@pccoepune.org',
      otpLength: 4,
    );
    EmailOTP.sendOTP(email: _enteredEmail);
    setState(() {
      _endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
      _isResendEnabled = false; // Disable button until countdown ends
    });
  }

  void _submit() async {
    _form.currentState!.save();

    if (EmailOTP.verifyOTP(otp: _otp)) {
      isSigningIn = true;
      await saveIDStatus(_enteredEmail);
      universalId = _enteredEmail;
      addUser(citizen);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const SuccessScreen(),
        ),
      );
      return;
    }
    verifyEmailOTP(_enteredEmail, _otp);
  }

  void addUser(Citizen citizen) async {
    final Uri url = Uri.https(
      "relieflink-e824d-default-rtdb.firebaseio.com",
      "users.json",
    ); // .json is required for Firebase API

    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': citizen.email,
          'first_name': citizen.firstName,
          'last_name': citizen.lastName,
          'contact': citizen.contact,
          'location': citizen.location,
          'emergency_details': citizen.emergencyDetails,
        }) // Convert citizen to JSON
        );

    if (response.statusCode == 200) {
      print("User added successfully: ${response.body}");
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<void> verifyEmailOTP(String email, String otp) async {
    try {
      print('User signed in with OTP!');
    } catch (e) {
      print('Invalid OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            PinCodeTextField(
                              appContext: context,
                              length: 4, // OTP length
                              validator: (value) {
                                if (value == null || value.trim().length != 4) {
                                  return 'Please enter a valid 4-digit OTP.';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _otp = value; // Save the entered OTP
                              },
                              keyboardType: TextInputType.number,
                              textStyle: const TextStyle(fontSize: 20),
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                selectedColor: Colors.black,
                                activeColor: const Color.fromARGB(255, 0, 0, 0),
                                inactiveColor:
                                    const Color.fromARGB(255, 50, 100, 150),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: Colors.white,
                              ),
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                            _isResendEnabled
                                ? const Text("Didn't receive OTP?")
                                : CountdownTimer(
                                    endTime: _endTime,
                                    widgetBuilder: (_, time) {
                                      if (time == null) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          setState(() {
                                            _isResendEnabled = true;
                                          });
                                        });
                                        return const Text("You can resend now");
                                      }
                                      return Text("Resend in ${time.sec} sec");
                                    },
                                  ),
                            TextButton(
                              onPressed: _isResendEnabled ? resendOTP : null,
                              child: Text(
                                "Resend OTP",
                                style: TextStyle(
                                  color: _isResendEnabled
                                      ? Colors.blue
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 50, 100, 150),
                              ),
                              child: const Text(
                                'SignUp',
                                style: TextStyle(color: Colors.white),
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
    );
  }
}
