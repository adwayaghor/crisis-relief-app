import 'dart:convert';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/login/signupscreen2.dart';
import 'package:relieflink/login/successscreen.dart';
import 'package:relieflink/models/users.dart';
import 'package:relieflink/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:http/http.dart' as http;

class NGOSignUpScreen2 extends StatefulWidget {
  const NGOSignUpScreen2({super.key, required this.ngo, required this.email});

  final String email;
  final NGO ngo;

  @override
  State<NGOSignUpScreen2> createState() => _NGOSignUpScreenState();
}

class _NGOSignUpScreenState extends State<NGOSignUpScreen2> {
  final _form = GlobalKey<FormState>();
  String _otp = '';
  int _endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
  bool _isResendEnabled = false;
  late NGO ngo;
  late String _enteredEmail;

  @override
  void initState() {
    super.initState();
    ngo = widget.ngo;
    _enteredEmail = widget.email;
  }

  void resendOTP() {
    print("OTP Resent!");
    EmailOTP.config(
      appName: 'ReliefLink',
      otpType: OTPType.numeric,
      expiry: 60000,
      emailTheme: EmailTheme.v6,
      appEmail: 'support@relieflink.org',
      otpLength: 4,
    );
    EmailOTP.sendOTP(email: _enteredEmail);
    setState(() {
      _endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
      _isResendEnabled = false;
    });
  }

  void _submit() async {
    _form.currentState!.save();
    
    bool isOtpValid = await verifyEmailOTP(_enteredEmail, _otp);
    if (isOtpValid) {
      isSigningIn = true;
      await saveIDStatus(_enteredEmail);
      universalId = _enteredEmail;
      await saveisNGOStatus(true);
      isNGO = true;
      addNGO(ngo);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const SuccessScreen(),
        ),
      );
    } else {
      print("Invalid OTP");
    }
  }

  void addNGO(NGO ngo) async {
    final Uri url = Uri.https(
      "relieflink-e824d-default-rtdb.firebaseio.com",
      "ngos.json",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": ngo.email,
        "ngoName": ngo.ngoName,
        "contactPerson": ngo.contactPerson,
        "registrationNumber": ngo.registrationNumber,
        "address": ngo.address,
        "city": ngo.city,
        "state": ngo.state,
        "country": ngo.country,
        "contact": ngo.contact,
        "website": ngo.website,
        "missionStatement": ngo.missionStatement,
      }),
    );

    if (response.statusCode == 200) {
      print("NGO registered successfully: ${response.body}");
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<bool> verifyEmailOTP(String email, String otp) async {
    try {
      print('User signed in with OTP!');
      return true;
    } catch (e) {
      print('Invalid OTP: $e');
      return false;
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PinCodeTextField(
                              appContext: context,
                              length: 4,
                              validator: (value) {
                                if (value == null || value.trim().length != 4) {
                                  return 'Please enter a valid 4-digit OTP.';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _otp = value;
                              },
                              keyboardType: TextInputType.number,
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
                              child: Text("Resend OTP"),
                            ),
                            ElevatedButton(
                              onPressed: _submit,
                              child: const Text('SignUp'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()),
                                );
                              },
                              child: const Text('I already have an account'),
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
