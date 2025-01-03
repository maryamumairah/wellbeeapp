import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:random_string/random_string.dart';
import 'package:wellbeeapp/services/database.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EditActivityScreen extends StatefulWidget {  
  final Map<String, dynamic> activity;
  // final DocumentSnapshot activity; 

  EditActivityScreen({Key? key, required this.activity}) : super(key: key); // constructor to receive activity details

  @override
  _EditActivityScreenState createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController activityController = TextEditingController();
  late TextEditingController categoryController = TextEditingController();
  late TextEditingController hourController = TextEditingController();
  late TextEditingController minuteController = TextEditingController();
  late TextEditingController dateController = TextEditingController();

  final DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  void initState() {
    activityController.text = widget.activity['activityName'];
    categoryController.text = widget.activity['categoryName'];
    hourController.text = widget.activity['hour'];
    minuteController.text = widget.activity['minute'];
    dateController.text = widget.activity['date'];

    // super.initState(); // to initialize the text controllers with the existing activity details
  }
  
  @override
  void dispose() {
    activityController.dispose();
    categoryController.dispose();
    hourController.dispose();
    minuteController.dispose();
    dateController.dispose();

    super.dispose(); 
  }  

  Future<void> _updateActivity() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser; // Added line to get current user

        if (currentUser != null) { // Added check for current user
          int hours = int.parse(hourController.text);
          int minutes = int.parse(minuteController.text);
          // int activityDuration = (hours * 60) + minutes;

          Map<String, dynamic> activityInfoMap = {
            "activityName": activityController.text,
            "categoryName": categoryController.text,
            "hour": hourController.text,
            "minute": minuteController.text,
            "date": dateController.text,
          };

          await DatabaseMethods().updateActivityDetails(currentUser, activityInfoMap, widget.activity["activityID"]).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                content: const Text('Activity updated successfully!'),
              ),
            );
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('User not logged in.'),
            ),
          );
        }
      } catch (e) {
        print('Error updating activity: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to update activity.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Edit Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // activity name input field
              const Text(
                'Activity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: activityController,
                decoration: InputDecoration(
                  hintText: 'Enter activity name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter activity name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // category input field
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                //display the selected category
                hint: const Text('Select category'),
                value: categoryController.text,        
                // items: ['Work', 'Meal', 'Spiritual'].map((String category) {
                items: ['Work', 'Meal', 'Exercise', 'Self-learning', 'Spiritual'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  categoryController.text = newValue!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // duration input field
              const Text(
                'Duration',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      // display the selected hour
                      hint: const Text('Hour'),
                      value: int.parse(hourController.text),                      
                      items: List.generate(24, (index) => index).map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        hourController.text = newValue.toString();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an hour';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  Text('hr'),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      // display the selected minute
                      hint: const Text('Minute'),
                      value: int.parse(minuteController.text),
                      items: List.generate(60, (index) => index).map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        minuteController.text = newValue.toString();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a minute';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  Text('min'),                  
                ],
              ),
              const SizedBox(height: 16.0),

              // date input field
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                readOnly: true,
                onTap: () {
                  _selectDate();
                },
              ),
              const SizedBox(height: 16.0),

              // create activity button
              Center(  
                child: ElevatedButton(
                  onPressed: _updateActivity,
                  child: const Text('Update Activity'),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = picked.toString().split(" ")[0];
      });
    }
  }
}