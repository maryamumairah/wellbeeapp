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
            const Divider(height: 32.0, thickness: 2.0),
            const SizedBox(height: 90.0),
            CustomButton(
                text: 'Register',
                onPressed: () {
                Navigator.pushNamed(context, Routes.register);
                },
                width: 220, // Set the button width
                height: 60, // Set the button height
            ),
            const SizedBox(height: 16.0),
            CustomButton(
                text: 'Login',
                onPressed: () {
                Navigator.pushNamed(context, Routes.login);
                },
                width: 220, // Set the button width
                height: 60, // Set the button height
            ),
          ],
        ),
      ),
    );
  }
}