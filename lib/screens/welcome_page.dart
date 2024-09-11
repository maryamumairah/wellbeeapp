import 'package:flutter/material.dart';
import '../widgets/custom_buttons.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Page'),
      ),
      body: Column(
        children:[ Expanded(
          flex: 1,
          child: Container(
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Welcome to the App',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.red, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Login',
                  width: 235,
                  height: 75,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                const SizedBox(height: 37),
                CustomButton(
                  text: 'Register',
                  width: 235,
                  height: 75,
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
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