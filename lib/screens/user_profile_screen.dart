import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        // title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Center the children horizontally
              children: [
                const SizedBox(height: 100.0),
                Container(
                  width: 200, // Set the width of the container
                  height: 200, // Set the height of the container
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black, // Set the border color
                      width: 2.0, // Set the border width
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.transparent,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/profile.png') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  user?.displayName ?? 'Username',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterBold',
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  user?.email ?? 'Email',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  jobPosition, // Display the job position
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 50.0),
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
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InterSemiBold',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          ),
        ),
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