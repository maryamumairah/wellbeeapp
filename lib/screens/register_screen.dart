import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeeapp/global/common/toast.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:wellbeeapp/screens/home_screen.dart';
import 'package:wellbeeapp/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart'; // For date formatting

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSigningUp = false;
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController jobPositionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String passwordError = '';
  String confirmPasswordError = '';

  @override
  void dispose() {
    usernameController.dispose();
    jobPositionController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack( // Use Stack here
                children: [
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Container(
                      child: Image(
                        image: const AssetImage('assets/bee1.png'),
                        width: screenWidth * 0.25, // 25% of screen width
                        height: screenWidth * 0.25, // 25% of screen width
                      ),
                    ),
                  ),
                  // Responsive Image 2
                  Positioned(
                    bottom: 50,
                    right: 20,
                    child: Container(
                      child: Image(
                        image: const AssetImage('assets/bee2.png'),
                        width: screenWidth * 0.30, // 30% of screen width
                        height: screenWidth * 0.30, // 30% of screen width
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome to',
                                style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800, // Make the text bold
                                  fontFamily: 'InterBold',
                                ),
                              ),
                              Text(
                                'Wellbee!',
                                style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800, // Make the text bold
                                  fontFamily: 'InterBold',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, thickness: 2.0),
            const SizedBox(height: 5.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // Set the width to 80% of the screen width
                  child: Column(
                    children: [
                      const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 24,
                          decoration: TextDecoration.underline,
                          fontFamily: 'InterSemiBold',
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(usernameController, 'Username', TextInputType.text),
                      const SizedBox(height: 16.0),
                      _buildTextField(jobPositionController, 'Job Position', TextInputType.text),
                      const SizedBox(height: 16.0),
                      _buildTextField(emailController, 'Email', TextInputType.emailAddress),
                      const SizedBox(height: 16.0),
                      _buildPasswordField(passwordController, 'Password'),
                      if (passwordError.isNotEmpty)
                        _buildErrorText(passwordError),
                      const SizedBox(height: 16.0),
                      _buildPasswordField(confirmPasswordController, 'Confirm Password'),
                      if (confirmPasswordError.isNotEmpty)
                        _buildErrorText(confirmPasswordError),
                      const SizedBox(height: 16.0),
                      _buildRegisterButton(),
                      const SizedBox(height: 30.0),
                      _buildLoginRedirect(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          fillColor: Colors.white,
          filled: true,
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          fillColor: Colors.white,
          filled: true,
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildErrorText(String errorText) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 20.0),
        child: Text(
          errorText,
          style: TextStyle(
            color: errorText.contains('strong') || errorText.contains('matches') ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSigningUp ? const CircularProgressIndicator(color: Colors.white,) : const Text('Register'),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.login);
          },
          child: const Text(
            "Login here",
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blue,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  void _register() async {
    setState(() {
      isSigningUp = true;
    });

    // Trigger form validation
    if (!_formKey.currentState!.validate()) {
      setState(() {
        isSigningUp = false;
      });
      return; // If validation fails, do not proceed
    }

    String username = usernameController.text;
    String jobPosition = jobPositionController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Check password validity
    // if (password.isEmpty) {
    //   setState(() {
    //     passwordError = 'Please enter a password';
    //     isSigningUp = false;
    //   });
    //   return;
    // }
    // if (password.length < 6) {
    //   setState(() {
    //     passwordError = 'Password must be at least 6 characters';
    //     isSigningUp = false;
    //   });
    //   return;
    // } else {
    //   setState(() {
    //     passwordError = 'Password is strong';
    //   });
    // }

    if (password != confirmPassword) {
      setState(() {
        confirmPasswordError = 'Password does not match';
        isSigningUp = false;
      });
      return;
    } else {
      setState(() {
        confirmPasswordError = 'Password matches';
      });
    }

    // Creating user via Firebase Authentication
    User? user = await _auth.signUpWithEmailAndPassword(context, email, password);

    if (user != null) {
      int userCount = await FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((snapshot) => snapshot.docs.length);
      String userID = "U${userCount.toString().padLeft(4, '0')}";

      await user.updateProfile(displayName: username);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userID': userID,
        'displayName': username,
        'email': email,
        'jobPosition': jobPosition,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('User registered successfully'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } 

    setState(() {
      isSigningUp = false;
    });
  }
}
