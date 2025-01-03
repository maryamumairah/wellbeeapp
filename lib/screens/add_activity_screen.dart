import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wellbeeapp/services/database.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddActivityScreen extends StatefulWidget {
  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController activityController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController hourController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'Add New Activity',
            style: TextStyle(fontFamily: 'InterBold',),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // activity name input field
                    const Text(
                      'Activity',
                      style: TextStyle(fontFamily: 'InterSemiBold',),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: activityController,
                      decoration: InputDecoration(
                        hintText: 'Enter activity name',
                        hintStyle: const TextStyle(fontFamily: 'Inter',),
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
                      style: TextStyle(fontFamily: 'InterSemiBold',),
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
                      hint: const Text('Select category', 
                        style: TextStyle(fontFamily: 'Inter',),
                      ),
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
                      style: TextStyle(fontFamily: 'InterSemiBold',),
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
                            hint: const Text('Hour',
                              style: TextStyle(fontFamily: 'Inter',),
                            ),
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
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            hint: const Text('Minute',
                              style: TextStyle(fontFamily: 'Inter',),
                            ),
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
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // date input field
                    const Text(
                      'Date',
                      style: TextStyle(fontFamily: 'InterSemiBold',),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        hintText: 'Select date',
                        hintStyle: const TextStyle(fontFamily: 'Inter',),
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              if (Firebase.apps.isEmpty) {
                                await Firebase.initializeApp();
                              }                      
                              
                              int activityCount = await DatabaseMethods().getActivityCount(currentUser);
                              String activityID = "A${activityCount.toString().padLeft(4, '0')}";
                                            
                              Map<String, dynamic> activityInfoMap = {
                                "activityName": activityController.text,
                                "categoryName": categoryController.text,
                                "hour": hourController.text, 
                                "minute": minuteController.text,                         
                                "date": dateController.text, 
                                "activityID": activityID,
                              };
                              await DatabaseMethods()                        
                                .addActivityDetails(currentUser, activityInfoMap)
                                .then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      content: const Text('Activity created successfully!'),
                                    ),
                                  );
                                  Navigator.pushNamed(context, Routes.activity);                                                      
                                });
                            } catch (e) {
                              print('Error creating activity: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Failed to create activity.'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Please fill all fields.'),
                              ),
                            );
                          }
                        },                  
                        child: const Text(
                          'Create Activity',
                          style: TextStyle(fontFamily: 'InterSemiBold',),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
    // User is not logged in, show a message or redirect to login screen
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Add New Activity',
          style: TextStyle(fontFamily: 'InterSemiBold',),
        ),
      ),
      body: Center(
        child: Text('Please log in to add an activity.'),
      ),
    );
  }
      

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