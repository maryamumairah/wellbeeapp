import 'package:flutter/material.dart';
import 'package:wellbeeapp/screens/home_screen.dart';
import 'package:wellbeeapp/screens/register_screen.dart';
// import 'package:wellbeeapp/screens/activity_screen.dart';
// import 'package:wellbeeapp/screens/add_activity_screen.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbee',

      theme: ThemeData(      
        scaffoldBackgroundColor: Colors.transparent, // Set to transparent to apply gradient          
        primaryColor: const Color(0xFFB8DEFF),
        colorScheme: const ColorScheme.light(
          secondary: Color(0xFFFED072),
          tertiary: Color(0xFF378DF9),        
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: const Color(0xFFFED072),
            textStyle: const TextStyle(fontSize: 16.0),
          ),
        ),
      ),

      initialRoute: Routes.register, //to be changed
      routes: {
        Routes.register: (context) => const RegisterScreen(),
        Routes.home: (context) => const HomeScreen(), 
        // Routes.activity: (context) => const ActivityScreen(),
        // Routes.addActivity: (context) => AddActivityScreen(),
        // Routes.test: (context) => const BottomSheetExampleApp(),

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