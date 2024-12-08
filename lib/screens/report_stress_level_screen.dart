import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:intl/intl.dart';

class ReportStressLevelScreen extends StatefulWidget {
  const ReportStressLevelScreen({Key? key}) : super(key: key);

  @override
  _ReportStressLevelScreenState createState() => _ReportStressLevelScreenState();
}

class _ReportStressLevelScreenState extends State<ReportStressLevelScreen> {
  double _stressLevel = 1;
  String? _selectedStressor;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitReport() async {
    if (_selectedStressor != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await FirebaseFirestore.instance.collection('stressLevel').add({
        'date': formattedDate, // Ensure date is not null
        'level': _stressLevel.round(), // Ensure level is not null and is an integer
        'stressor': _selectedStressor, // Ensure stressor is a string
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text, // Allow description to be null
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
      Navigator.pushNamed(context, Routes.stress);
    } else {
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
        title: const Text('Report Stress Level'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Slider(
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
