import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellbeeapp/global/common/toast.dart';
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
  final FocusNode _focusNode = FocusNode(); 

  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissal by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(18), // Adjust content padding for more space
          content: Container(
            width: 500, // Adjust the width of the white container
            height: 200, // Adjust the height of the white container
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
              children: [
                const Text(
                  'Are you sure to report this stress level?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'InterSemiBold',
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 15), // Space between the title and the next text
                const Text(
                  'You are about to add a new stress level entry.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'InterRegular',
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 20), // Space before the buttons
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
                        'Cancel',
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
                        _submitReport(); // Proceed to submit the report
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

  // Submit the report to Firebase
  Future<void> _submitReport() async {
    // Ensure the user is logged in and retrieve the UID
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null && _selectedStressor != null) {
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
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
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Report submitted successfully')
          ),
        );
        // showToast(message: 'Report submitted successfully');

        // Navigate to another screen as required
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to submit report. Please try again.')
          ),

        );
        // showToast(message: 'Failed to submit report. Please try again.');
      }
    } else {
      // Show a message if required fields are not filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill all required fields')
        ),
      );
      // showToast(message: 'Please fill all required fields');
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
  void dispose() {
    _focusNode.dispose(); // Dispose FocusNode when no longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InterBold',
                    ),
                  ),
                  Text(
                    'feeling today?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InterBold',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.blue,
                  inactiveTrackColor: Colors.white,
                  thumbColor: Colors.blue,
                  overlayColor: Colors.blue.withOpacity(0.2),
                  trackHeight: 4.0,
                ),
                child: Container(
                  width: 500,
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
                  )
              ),
              const SizedBox(height: 5),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('1', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 20),
                          Text('Calm', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('2', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 5),
                          Text('Low', style: TextStyle(fontSize: 12)),
                          Text('Stress', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('3', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 5),
                          Text('Moderate', style: TextStyle(fontSize: 12)),
                          Text('Stress', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('4', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 5),
                          Text('High', style: TextStyle(fontSize: 12)),
                          Text('Stress', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('5', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 26),
                          Text('Overwhelmed', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select a stressor',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',),
                  filled: true, // Enable the fill color
                  fillColor: _focusNode.hasFocus
                      ? Colors.white // White when focused
                      : Colors.grey.shade300, // Set the grey color for the default state (unfocused)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Border radius
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none, // Grey border when not focused
                  ),
                ),
                items: ['Work', 'Meal', 'Exercise', 'Self-learning', 'Spiritual']
                    .map((stressor) => DropdownMenuItem<String>(
                          value: stressor,
                          child: Text(stressor, 
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'InterSemiBold',
                            )
                          ),
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
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                  alignLabelWithHint: true, // This will position the label at the top
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 5,
                textAlign: TextAlign.start, // Align text to the left
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 300, // Set the desired width for the button
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showConfirmationDialog, // Show confirmation dialog when the button is pressed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary, // Set the button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size
                        fontWeight: FontWeight.bold, // Set the text weight to bold
                        fontFamily: 'InterSemiBold', // Set the font family (if needed)
                        color: Colors.black, // Set the text color to white
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
