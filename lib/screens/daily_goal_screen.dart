import 'package:flutter/material.dart';
import 'package:wellbeeapp/routes.dart';

class DailyGoalScreen extends StatefulWidget {
  const DailyGoalScreen({Key? key}) : super(key: key);

  @override
  _DailyGoalScreenState createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends State<DailyGoalScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        // title: const Text('Daily Goal', style: TextStyle(color: Colors.black)),
        centerTitle: false, // Align the title to the left
      ),
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Daily Goal',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w800, // Make the text bold
                  fontFamily: 'InterBold',
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // navigate to daily goal analytics screen
                  },
                  backgroundColor: Colors.black,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.bar_chart, size: 40),
                ),
                const SizedBox(height: 16), // Add space between the buttons
                FloatingActionButton(
                  onPressed: () {
                    // navigate to add daily goal screen
                    Navigator.pushNamed(context, Routes.addDailyGoal);
                  },
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 40),
                ),
              ],
            )
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: const Color(0xFF378DF9),
        selectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
          switch (newIndex) {
            case 0:
              Navigator.pushNamed(context, Routes.home);
              break;
            case 1:
              Navigator.pushNamed(context, Routes.activity);
              break;
            case 2:
              //Navigator.pushNamed(context, Routes.goals);
              break;
            case 3:
              //Navigator.pushNamed(context, Routes.stress);
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_rounded),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_rounded),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied_alt),
            label: 'Stress',
          ),
        ],
      ),
    );
  }
}