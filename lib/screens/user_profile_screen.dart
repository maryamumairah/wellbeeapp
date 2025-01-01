import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellbeeapp/screens/login_screen.dart'; // Import the LoginScreen widget

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  int _currentIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  String jobPosition = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        jobPosition = userDoc['jobPosition'] ?? 'Job Position';
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is logged out successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace with your login screen widget
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Show error if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.1),
                    Container(
                      width: constraints.maxWidth * 0.5,
                      height: constraints.maxWidth * 0.5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: constraints.maxWidth * 0.25,
                        backgroundColor: Colors.transparent,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/profile.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    Text(
                      user?.displayName ?? 'Username',
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InterBold',
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Text(
                      user?.email ?? 'Email',
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.045,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Text(
                      jobPosition,
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.045,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(context, Routes.updateUserProfile);
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            user = FirebaseAuth.instance.currentUser;
                            user?.updateProfile(displayName: result['displayName'] ?? user!.displayName!);
                            user?.verifyBeforeUpdateEmail(result['email'] ?? user!.email!);
                            jobPosition = result['jobPosition'] ?? jobPosition;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.2,
                          vertical: constraints.maxHeight * 0.03,
                        ),
                        textStyle: TextStyle(
                          fontSize: constraints.maxWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InterSemiBold',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Update Profile'),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.2,
                          vertical: constraints.maxHeight * 0.03,
                        ),
                        textStyle: TextStyle(
                          fontSize: constraints.maxWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InterSemiBold',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
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
              Navigator.pushReplacementNamed(context, Routes.home);
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
