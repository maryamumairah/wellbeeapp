import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeeapp/global/common/toast.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  bool _isDialogShown = false;
  DateTime? lastReportDate;

  // Method to load the last report date from shared preferences
  Future<void> _loadLastReportDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load the last report date using the user's UID
    String? lastDateString = prefs.getString('lastReportDate_${user?.uid}');
    
    if (lastDateString != null) {
      lastReportDate = DateTime.parse(lastDateString);
    }
  }

  // Method to save the current date as the last report date
  Future<void> _saveLastReportDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Save the last report date with the user UID as part of the key
    await prefs.setString('lastReportDate_${user?.uid}', formattedDate);
  }

  // Method to check if the report was already submitted today
  bool _hasSubmittedReportToday() {
    if (lastReportDate == null) {
      return false;
    }
    return lastReportDate!.day == DateTime.now().day &&
        lastReportDate!.month == DateTime.now().month &&
        lastReportDate!.year == DateTime.now().year;
  }

  // Method to check if a report has already been submitted today in Firestore
  Future<bool> _hasReportInFirestore() async {
    if (user == null) return false;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('stressReports')
        .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _showStressLevelDialog() async {
    if (_hasSubmittedReportToday() || await _hasReportInFirestore()) {
      return; // Skip showing the dialog if the report was submitted today
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20), // Adjust content padding for more space
          content: Container(
            width: 400, // Adjust the width of the white container
            height: 200, // Adjust the height of the white container
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
              children: [
                const Image(
                  image: AssetImage('assets/regular_face-smile.png'), // Replace with your image asset path
                  // width: 60, // Adjust the image size
                  // height: 60, // Adjust the image size
                ),
                const SizedBox(height: 15), // Space between the image and the text
                const Text(
                  'Please report your stress level.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'InterBold',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15), // Add space between the text and buttons
                // Centered Row with Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center buttons horizontally
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Dismiss dialog
                      },
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'InterSemiBold',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Space between the buttons
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Dismiss dialog
                        Navigator.pushNamed(context, Routes.report); // Navigate to Stress Report page
                        _saveLastReportDate(); // Save the current date when proceeding with the report
                      },
                      child: const Text(
                        'Proceed',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'InterSemiBold',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Reload user data
  Future<void> _reloadUser() async {
    user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLastReportDate(); // Load the last report date
      if (!_hasSubmittedReportToday() && !_isDialogShown) {
        _showStressLevelDialog(); // Show the dialog if not submitted today
        setState(() {
          _isDialogShown = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Image(
              image: AssetImage('assets/profile.png'),
              width: 40,
              height: 40,
            ),
            const Text(
              'Wellbee',
              style: TextStyle(
                fontFamily: 'InterBold',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.userProfile).then((_) {
                  setState(() {
                    _reloadUser();
                  });
                });
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _reloadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container(
              margin: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // display greetings
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.displayName ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'InterSemiBold',
                        ),
                      ),
                      const Text(
                        'What are you planning to do today?',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  // display date and time
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // display current date
                        Text(
                          DateFormat('d MMM yyyy').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'InterBold',
                          ),
                        ),
                        // display current time
                        Row(
                          children: [
                            Text(
                              DateFormat('h:mm').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 50,
                                fontFamily: 'InterBold',
                              ),
                            ),
                            Text(
                              DateFormat('a').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'InterBold',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // display features
                  const SizedBox(height: 40),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // button Track Activity
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, Routes.activity);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: 115,
                                    height: 120,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.task_rounded,
                                            color: Color(0xFF378DF9),
                                            size: 40,
                                          ),
                                        ),
                                        Text('Track Activity',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // button Track Daily Goal
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, Routes.dailyGoal);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: 115,
                                    height: 120,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.track_changes_rounded,
                                            color: Color(0xFF378DF9),
                                            size: 40,
                                          ),
                                        ),
                                        Text('Track Daily Goal',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // button Report Stress Level
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, Routes.stress);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: 115,
                                    height: 120,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.sentiment_satisfied_alt,
                                            color: Color(0xFF378DF9),
                                            size: 40,
                                          ),
                                        ),
                                        Text('Report Stress Level', 
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
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
              break;
            case 1:
              Navigator.pushReplacementNamed(context, Routes.activity);
              break;
            case 2:
              Navigator.pushReplacementNamed(context, Routes.dailyGoal);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, Routes.stress);
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

