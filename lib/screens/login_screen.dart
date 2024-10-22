import 'package:flutter/material.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                      child: const Image(
                        image: AssetImage('assets/bee1.png'),
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 20,
                    child: Container(
                      child: const Image(
                        image: AssetImage('assets/bee2.png'),
                        width: 125,
                        height: 125,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
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
            const Divider(height: 15.0, thickness: 2.0),
            const SizedBox(height: 5.0),
            Container(
              padding: EdgeInsets.all(16.0),
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
                      const SizedBox(height: 16.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7, // Set the width to 70% of the screen width
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              FirebaseAuth.instance.
                                signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text)
                                .then((value) {
                                  Navigator.pushNamed(context, Routes.home);
                                }).onError((error, stackTrace) {
                                    print("Error: ${error.toString()}");
                                });
                            };
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Set the border radius
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 30.0), // Add some space between the button and the row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("New User? "),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the register screen
                              Navigator.pushNamed(context, Routes.register);
                            },
                            child: Text(
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
}