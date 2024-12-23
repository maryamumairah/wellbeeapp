import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wellbeeapp/firebase_options.dart';
import 'package:wellbeeapp/screens/home_screen.dart';
import 'package:wellbeeapp/screens/activity_screen.dart';
import 'package:wellbeeapp/screens/add_activity_screen.dart';
import 'package:wellbeeapp/screens/edit_activity_screen.dart';
import 'package:wellbeeapp/screens/timer_activity_screen.dart';
import 'package:wellbeeapp/screens/activity_analytics_screen.dart';
import 'package:wellbeeapp/screens/daily_goal_screen.dart';
import 'package:wellbeeapp/screens/add_daily_goal_screen.dart';
// import 'package:wellbeeapp/screens/daily_goal_analytics_screen.dart';
import 'routes.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(); 
  try {
    // await Firebase.initializeApp();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );    
  } catch (e) {
    print('Error initializing Firebase: $e');
    
  }
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

      initialRoute: Routes.home, //to be changed
      routes: {
        Routes.home: (context) => const HomeScreen(), 
        Routes.activity: (context) => const ActivityScreen(),
        Routes.addActivity: (context) => AddActivityScreen(),
        // Routes.editActivity: (context) => EditActivityScreen( ), // error
        // Routes.timerActivity: (context) => TimerActivityScreen(),
        // Routes.timerActivity: (context) => TimerActivityScreen(activityID: 'activityID'),
        Routes.analyticsActivity: (context) => ActivityAnalyticsScreen(),
        Routes.dailyGoal: (context) => DailyGoalScreen(),
        Routes.addDailyGoal: (context) => AddDailyGoalScreen(),
        // Routes.analyticsDailyGoal: (context) => DailyGoalAnalyticsScreen(),

      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.editActivity:
            // final args = settings.arguments as Map<String, dynamic>;
            final args = settings.arguments as DocumentSnapshot;
            return MaterialPageRoute(
              builder: (context) => EditActivityScreen(activity: args),
            );
          case Routes.timerActivity:
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TimerActivityScreen(activityID: args),
            );
          default:
            return null;
        }
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




