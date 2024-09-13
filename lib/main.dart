import 'package:flutter/material.dart';
//import 'package:wellbeeapp/screens/home_screen.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbee',
      theme: ThemeData(      
        scaffoldBackgroundColor: Colors.transparent, // Set to transparent to apply gradient          
        primaryColor: Color(0xFFB8DEFF),
        colorScheme: const ColorScheme.light(
        secondary: Color(0xFFFED072),
        ),
      ),
      initialRoute: Routes.home, //to be changed
      routes: {
        //Routes.home: (context) => const HomeScreen(), 

      },
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB8DEFF), Color(0xFFE8F4FF), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: child,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}