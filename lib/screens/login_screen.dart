import 'package:flutter/material.dart';
import 'package:wellbeeapp/global/common/toast.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeeapp/screens/home_screen.dart';
import 'package:wellbeeapp/user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isSigningIn = false;
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 15.0, thickness: 2.0),
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
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          decoration: TextDecoration.underline,
                          fontFamily: 'InterSemiBold',
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7, // Set the width to 70% of the screen width
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Set the border radius
                            ),
                          ),
                          // child: const Text('Login'),
                          child: Center(
                            child: _isSigningIn ? const CircularProgressIndicator(color: Colors.white,) : const Text('Login'),
                          )
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: _resetPasswordDialog,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0), // Add some space between the button and the row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("New User? "),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the register screen
                              Navigator.pushNamed(context, Routes.register);
                            },
                            child: const Text(
                              "Register here",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSigningIn = true;
        errorMessage = '';
      });

      String email = emailController.text;
      String password = passwordController.text;

      try {
        User? user = await _auth.signInWithEmailAndPassword(context, email, password);

        setState(() {
          _isSigningIn = false;
        });

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('User is successfully logged in'),
            ),
          );

          // Navigate to home screen and clear navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), // Replace with your home screen widget
            (route) => false, // Remove all previous routes
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isSigningIn = false;
          // if (e.code == 'user-not-found') {
          //   errorMessage = 'User not found';
          // } else if (e.code == 'wrong-password') {
          //   errorMessage = 'Incorrect password';
          // } else {
          //   errorMessage = 'Invalid email or password. Please try again.';
          // }
        });
      } catch (e) {
        setState(() {
          _isSigningIn = false;
          errorMessage = 'An error occurred. Please try again.';
        });
      }
    }
  }

  void _resetPasswordDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            onChanged: (value) {
              email = value;
            },
            decoration: const InputDecoration(
              labelText: 'Enter your email',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.values[5],
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black, fontFamily: 'InterSemiBold')),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendPasswordResetEmail(email);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.black),
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reset',
                    style: TextStyle(color: Colors.white, fontFamily: 'InterSemiBold')),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // showToast(message: 'Password reset email sent');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // showToast(message: 'No user found with this email');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user found with this email'),
          ),
        );
      } else {
        // showToast(message: 'An error occurred. Please try again.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('An error occurred. Please try again.'),
          ),
        );
      }
    }
  }

}