import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportStressLevelScreen extends StatefulWidget {
  const ReportStressLevelScreen({Key? key}) : super(key: key);

  @override
  _ReportStressLevelScreenState createState() =>
      _ReportStressLevelScreenState();
}

class _ReportStressLevelScreenState extends State<ReportStressLevelScreen> {
  double _stressLevel = 1;
  String? _selectedStressor;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitReport() async {
    // Ensure the user is logged in and retrieve the UID
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null && _selectedStressor != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      try {
        // Store the report under the user's UID in a subcollection
        await FirebaseFirestore.instance
            .collection('users') // Top-level collection for all users
            .doc(currentUser.uid) // Document for the current user (using their UID)
            .collection('stressReports') // Subcollection for stress reports
            .add({
          'date': formattedDate, // Ensure date is not null
          'level': _stressLevel.round(), // Ensure level is not null and is an integer
          'stressor': _selectedStressor, // Ensure stressor is a string
          'description': _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text, // Allow description to be null
          'timestamp': FieldValue.serverTimestamp(), // Automatically set the timestamp
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );

        // Navigate to another screen as required
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report. Please try again.')),
        );
      }
    } else {
      // Show a message if required fields are not filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  String getCategory(double level) {
    switch (level.round()) {
      case 1:
        return 'Calm';
      case 2:
        return 'Low Stress';
      case 3:
        return 'Moderate Stress';
      case 4:
        return 'High Stress';
      case 5:
        return 'Overwhelmed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'How are you',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterBold',
                  ),
                ),
                Text(
                  'feeling today?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterBold',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Updated Slider wrapped in SliderTheme to change the color to blue
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.blue, // Active part of the slider
                inactiveTrackColor: Colors.white, // Inactive part of the slider
                thumbColor: Colors.blue, // Thumb (draggable part) color
                overlayColor: Colors.blue.withOpacity(0.2), // Color when thumb is pressed
                trackHeight: 4.0, // Track height (optional)
              ),
              child: Slider(
                value: _stressLevel,
                min: 1,
                max: 5,
                divisions: 4,
                label: getCategory(_stressLevel),
                onChanged: (value) {
                  setState(() {
                    _stressLevel = value;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) => Text((index + 1).toString())),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calm', style: TextStyle(fontSize: 12)),
                Text('Low Stress', style: TextStyle(fontSize: 12)),
                Text('Moderate Stress', style: TextStyle(fontSize: 12)),
                Text('High Stress', style: TextStyle(fontSize: 12)),
                Text('Overwhelmed', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select a stressor',
                border: OutlineInputBorder(),
              ),
              items: ['Work', 'Meal', 'Exercise', 'Self-learning', 'Spiritual']
                  .map((stressor) => DropdownMenuItem<String>(
                        value: stressor,
                        child: Text(stressor),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStressor = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Describe here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
