import 'package:flutter/material.dart';
import '../widgets/custom_buttons.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Welcome Page'),
      // ),
      body: Column(
        children:[ Expanded(
          flex: 1,
          child: Container(
            color: Colors.blue,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                      fontWeight: FontWeight.bold, // Make the text bold
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    'Wellbee!',
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                      fontWeight: FontWeight.bold, // Make the text bold
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              )
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            // color: Colors.white, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Register',
                  width: 235,
                  height: 75,
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
                const SizedBox(height: 37),
                CustomButton(
                  text: 'Login',
                  width: 235,
                  height: 75,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}