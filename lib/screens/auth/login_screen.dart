import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phara_driver/screens/auth/signup_screen.dart';

import '../../utils/colors.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../widgets/toast_widget.dart';
import '../splashtohome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgotPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isRetrievingPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      body: Form(
        key: _formKey,
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/back.png'),
                  fit: BoxFit.cover)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  TextBold(text: 'Todacash', fontSize: 58, color: Colors.white),
                  const SizedBox(
                    height: 75,
                  ),
                  TextRegular(text: 'Login', fontSize: 24, color: Colors.white),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    hint: 'Username',
                    label: 'Username',
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a user';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    showEye: true,
                    isObscure: true,
                    hint: 'Password',
                    label: 'Password',
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      final hasUppercase = value.contains(RegExp(r'[A-Z]'));
                      final hasLowercase = value.contains(RegExp(r'[a-z]'));
                      final hasNumber = value.contains(RegExp(r'[0-9]'));
                      if (!hasUppercase || !hasLowercase || !hasNumber) {
                        return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      child: TextRegular(
                        text: 'Forgot Password?',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: _isLoading
                        ? Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextRegular(
                                  text: 'Logging in...',
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        : ButtonWidget(
                            color: black,
                            label: 'Login',
                            onPressed: (() {
                              if (_formKey.currentState!.validate()) {
                                login(context);
                              }
                            }),
                          ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextRegular(
                          text: "New to Todacash?",
                          fontSize: 12,
                          color: Colors.white),
                      TextButton(
                        onPressed: (() {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()));
                        }),
                        child: TextBold(
                            text: "Signup Now",
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: TextBold(
                  text: 'Retrieve Password', fontSize: 18, color: Colors.black),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextRegular(
                    text: 'Enter your username to retrieve your password',
                    fontSize: 14,
                    color: Colors.grey[700]!,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: forgotPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  if (_isRetrievingPassword)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Retrieving password...'),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    forgotPasswordController.clear();
                  },
                  child: TextRegular(
                    text: 'Cancel',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isRetrievingPassword
                      ? null
                      : () async {
                          setState(() {
                            _isRetrievingPassword = true;
                          });

                          final success = await _retrievePassword(context);

                          setState(() {
                            _isRetrievingPassword = false;
                          });

                          if (success) {
                            Navigator.of(context).pop();
                            forgotPasswordController.clear();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: TextRegular(
                    text: 'Retrieve Password',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _retrievePassword(BuildContext context) async {
    final username = forgotPasswordController.text.trim();

    if (username.isEmpty) {
      showToast('Please enter your username');
      return false;
    }

    try {
      // Query Firestore to find the user by username (email field)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .where('email', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        showToast('No user found with that username');
        return false;
      }

      final userData = querySnapshot.docs.first.data();
      final password = userData['password'] as String?;

      if (password == null || password.isEmpty) {
        showToast('Password not found for this user');
        return false;
      }

      // Show password in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: TextBold(
                text: 'Your Password', fontSize: 18, color: Colors.black),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextRegular(
                  text: 'Username: $username',
                  fontSize: 14,
                  color: Colors.grey[700]!,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextBold(
                          text: password,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: password));
                          showToast('Password copied to clipboard');
                        },
                        icon: const Icon(Icons.copy, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextRegular(
                  text:
                      'Please copy this password and use it to login. Consider changing it after logging in for security.',
                  fontSize: 12,
                  color: Colors.red[600]!,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: TextRegular(
                  text: 'OK',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      );

      return true;
    } catch (e) {
      showToast('An error occurred: $e');
      return false;
    }
  }

  login(context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${emailController.text}@driver.phara',
          password: passwordController.text);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashToHomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("No user found with that username.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid username provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
