import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeeapp/global/common/toast.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateUserProfileScreen extends StatefulWidget {
  const UpdateUserProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateUserProfileScreenState createState() => _UpdateUserProfileScreenState();
}

class _UpdateUserProfileScreenState extends State<UpdateUserProfileScreen> {
  int _currentIndex = 0;
  
  final User? user = FirebaseAuth.instance.currentUser;
  
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController jobPositionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (user != null) {
      usernameController.text = user!.displayName ?? '';
      emailController.text = user!.email ?? '';
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        jobPositionController.text = userDoc['jobPosition'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await user?.updateProfile(displayName: usernameController.text);
        if (emailController.text != user?.email) {
          await user?.verifyBeforeUpdateEmail(emailController.text);
        }
        if (passwordController.text.isNotEmpty) {
          await user?.updatePassword(passwordController.text);
        }
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'jobPosition': jobPositionController.text,
        });
        await user?.reload();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Profile updated successfully')
          ),
        );
        // showToast(message: 'Profile updated successfully');
        Navigator.pop(context, {
          'displayName': usernameController.text,
          'email': emailController.text,
          'jobPosition': jobPositionController.text,
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to update profile: $e')
          ),
        );
        // showToast(message: 'Failed to update profile: $e');
      }
    }
  }

  Future<void> _deleteProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This will delete the profile permanently. You cannot undo this action.'),
          actions: <Widget>[
            Center(
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.values[5],
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                      const Text('Cancel',style: TextStyle(color: Colors.black, fontFamily: 'InterSemiBold')),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        // Get the reference to the user's stressReports subcollection
                        CollectionReference stressReportsRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('stressReports');
                  
                        // Get all documents in the stressReports subcollection
                        QuerySnapshot stressReportsSnapshot = await stressReportsRef.get();
                  
                        // Delete each document in the stressReports subcollection
                        for (DocumentSnapshot doc in stressReportsSnapshot.docs) {
                          await doc.reference.delete();
                        }

                      CollectionReference activitiesRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('activities');
                  
                        // Get all documents in the activities subcollection
                        QuerySnapshot activitiesSnapshot = await activitiesRef.get();
                  
                        // Delete each document in the activities subcollection
                        for (DocumentSnapshot activityDoc in activitiesSnapshot.docs) {
                          // Get the reference to the timerLogs subcollection for each activity
                          CollectionReference timerLogsRef = activityDoc.reference.collection('timerLogs');
                          
                          // Get all documents in the timerLogs subcollection
                          QuerySnapshot timerLogsSnapshot = await timerLogsRef.get();
                          
                          // Delete each document in the timerLogs subcollection
                          for (DocumentSnapshot timerLogDoc in timerLogsSnapshot.docs) {
                            await timerLogDoc.reference.delete();
                          }
                          
                          // Delete the activity document
                          await activityDoc.reference.delete();
                        }
                  
                        // Delete the user document
                        await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
                        await user?.delete();
                  
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
                        // showToast(message: 'User profile deleted successfully');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User profile deleted successfully')
                          ),
                        );
                      } catch (e) {
                        Navigator.of(context).pop(); // Close the dialog
                        // showToast(message: 'Failed to delete profile and stress reports: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Failed to delete user profile')
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      side: const BorderSide(color: Colors.black),
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'InterSemiBold',
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Update Profile', style: TextStyle(color: Colors.black, fontFamily: 'InterBold')),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Center the children horizontally
              children: [
                const SizedBox(height: 30.0),
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // border: Border.all(
                    //   color: Colors.black, // Set the border color
                    //   width: 2.0, // Set the border width
                    // ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/profile.png') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 50.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjust the padding to make the height smaller
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: jobPositionController,
                          decoration: const InputDecoration(
                            labelText: 'Job Position',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your job position';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 200.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'InterBold',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Update'),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton(
                          onPressed: _deleteProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), backgroundColor: Colors.red,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'InterBold',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Delete Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}