import 'package:flutter/material.dart';
import 'package:wellbeeapp/routes.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:random_string/random_string.dart';
// import 'package:wellbeeapp/services/database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                        image: AssetImage('assets/bee1.png'),
                        width: 100,
                        height: 100,
                    ),
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.black,
                        fontWeight: FontWeight.w100, // Make the text bold
                        fontFamily: 'InterBold',
                      ),
                    ),
                    Text(
                      'Wellbee!',
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.black,
                        fontWeight: FontWeight.w100, // Make the text bold
                        fontFamily: 'InterBold',
                      ),
                    ),
                    const Image(
                        image: AssetImage('assets/bee2.png'),
                        width: 100,
                        height: 100,
                    ),
                  ],
                ),
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
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                          fontFamily: 'Inter',
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
                              Navigator.pushNamed(context, Routes.home);
                            }
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
                              // Navigator.pushNamed(context, Routes.register);
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

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);  
    
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//     final _formKey = GlobalKey<FormState>();
    
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();
    
//     // @override
//     // Widget build(BuildContext context) {
//     //     return Scaffold(
//     //     appBar: AppBar(
//     //         backgroundColor: Theme.of(context).primaryColor,
//     //         title: const Text(
//     //         'Login',
//     //         style: TextStyle(fontWeight: FontWeight.bold),
//     //         ),
//     //     ),
//     //     body: Container(
//     //         padding: const EdgeInsets.all(16.0),
//     //         child: Form(
//     //         key: _formKey,
//     //         child: Column(
//     //             crossAxisAlignment: CrossAxisAlignment.start,
//     //             children: [
//     //             // email input field
//     //             const Text(
//     //                 'Email',
//     //                 style: TextStyle(fontWeight: FontWeight.bold),
//     //             ),
//     //             const SizedBox(height: 8.0),
//     //             TextFormField(
//     //                 controller: emailController,
//     //                 decoration: InputDecoration(
//     //                 hintText: 'Enter email',
//     //                 filled: true,
//     //                 fillColor: Colors.white,
//     //                 border: OutlineInputBorder(
//     //                     borderRadius: BorderRadius.circular(8.0),
//     //                 ),
//     //                 ),
//     //                 validator: (value) {
//     //                 if (value!.isEmpty) {
//     //                     return 'Please enter email';
//     //                 }
//     //                 return null;
//     //                 },
//     //             ),
//     //             const SizedBox(height: 16.0),
//     //             // password input field
//     //             const Text(
//     //                 'Password',
//     //                 style: TextStyle(fontWeight: FontWeight.bold),
//     //             ),
//     //             const SizedBox(height: 8.0),
//     //             TextFormField(
//     //                 controller: passwordController,
//     //                 decoration: InputDecoration(
//     //                 hintText: 'Enter password',
//     //                 filled: true,
//     //                 fillColor: Colors.white,
//     //                 border: OutlineInputBorder(
//     //                     borderRadius: BorderRadius.circular(8.0),
//     //                 ),
//     //                 ),
//     //                 validator: (value) {
//     //                 if (value!.isEmpty) {
//     //                     return 'Please enter password';
//     //                 }
//     //                 return null;
//     //                 },
//     //             ),
//     //             const SizedBox(height: 16.0),
//     //             // login button
//     //             ElevatedButton(
//     //                 // onPressed: () async {
//     //                 //     if (_formKey.currentState!.validate()) {
//     //                 //         await Firebase.initializeApp();
//     //                 //         final user = await Database.login(
//     //                 //             emailController.text,
//     //                 //             passwordController.text,
//     //                 //         );
//     //                 //         if (user != null) {
//     //                 //             // Add entry to Firestore
//     //                 //             CollectionReference entry = FirebaseFirestore.instance.collection('login');
//     //                 //             entry.add({
//     //                 //             'email': emailController.text,
//     //                 //             'timestamp': FieldValue.serverTimestamp(),
//     //                 //             });

//     //                 //             Navigator.pushNamed(context, Routes.home);
//     //                 //         }
//     //                 //     }
//     //                 // },
//     //                 onPressed: () {
//     //                     Navigator.pushNamed(context, Routes.home);
//     //                 },
//     //                 child: const Text('Login'),
//     //             ),
//     //             ],
//     //         ),
//     //         ),
//     //     ),
//     //     );
//     // }

//     @override
//     Widget build(BuildContext context) {
//         return Scaffold(
//         body: SingleChildScrollView(
//             child: Column(
//             children: [
//                 Container(
//                 height: MediaQuery.of(context).size.height * 0.4,
//                 color: Colors.blue,
//                 child: const Center(
//                     child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                         Text(
//                         'Welcome to',
//                         style: TextStyle(
//                             fontSize: 35,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold, // Make the text bold
//                             fontFamily: 'Inter',
//                         ),
//                         ),
//                         Text(
//                         'Wellbee!',
//                         style: TextStyle(
//                             fontSize: 35,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold, // Make the text bold
//                             fontFamily: 'Inter',
//                         ),
//                         ),
//                     ],
//                     ),
//                 ),
//                 ),
//                 Container(
//                 padding: EdgeInsets.all(16.0),
//                 child: Form(
//                     key: _formKey,
//                     child: Container(
//                         width: MediaQuery.of(context).size.width * 0.8, // Set the width to 80% of the screen width
//                         child: Column(
//                             children: [
//                                 Text(
//                                     'Login',
//                                     style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: 'Inter',
//                                     ),
//                                 ),
//                                 const Divider(height: 32.0, thickness: 2.0),
//                                 TextFormField(
//                                     controller: emailController,
//                                     decoration: const InputDecoration(
//                                         labelText: 'Email',
//                                     ),
//                                     validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                             return 'Please enter your email';
//                                         }
//                                         return null;
//                                     },
//                                 ),
//                                 const SizedBox(height: 16.0),
//                                 TextFormField(
//                                     controller: passwordController,
//                                     decoration: const InputDecoration(
//                                         labelText: 'Password',
//                                     ),
//                                     obscureText: true,
//                                     validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                             return 'Please enter your password';
//                                         }
//                                         return null;
//                                     },
//                                 ),
//                                 const SizedBox(height: 16.0),
//                                 ElevatedButton(
//                                     onPressed: () {
//                                         if (_formKey.currentState!.validate()) {
//                                             Navigator.pushNamed(context, Routes.home);
//                                         }
//                                     },
//                                     child: const Text('Login'),
//                                 ),
//                             ],
//                         ),
//                     ),
//                 ),
//             ),
//             ],
//         ),
//         ),
//         );
//     }
// }