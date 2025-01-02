import 'package:flutter/material.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:wellbeeapp/widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Screen dimensions
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
              child: Stack(
                children: [
                  // Responsive Image 1
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
                        width: screenWidth * 0.30,
                        height: screenWidth * 0.30, 
                      ),
                    ),
                  ),
                  // Center Text
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
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'InterBold',
                                ),
                              ),
                              Text(
                                'Wellbee!',
                                style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
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
            const Divider(height: 32.0, thickness: 2.0),
            const SizedBox(height: 70.0),
            CustomButton(
              text: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, Routes.register);
              },
              width: 220,
              height: 60,
            ),
            const SizedBox(height: 16.0),
            CustomButton(
              text: 'Login',
              onPressed: () {
                Navigator.pushNamed(context, Routes.login);
              },
              width: 220,
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
