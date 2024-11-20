import 'package:flutter/material.dart';
import 'package:wellbeeapp/routes.dart';

class AddDailyGoalScreen extends StatefulWidget {
  const AddDailyGoalScreen({Key? key}) : super(key: key);

  @override
  _AddDailyGoalScreenState createState() => _AddDailyGoalScreenState();
}

class _AddDailyGoalScreenState extends State<AddDailyGoalScreen> {
  int _currentIndex = 0;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController goalController = TextEditingController();
  String? selectedCategory;
  int selectedHour = 0;
  int selectedMinute = 0;

  final List<String> categories = ['Work', 'Meal', 'Exercise', 'Self-Learning', 'Spiritual'];
  final List<int> hours = List<int>.generate(24, (index) => index);
  final List<int> minutes = List<int>.generate(60, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Add New Daily Goal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InterBold',
                      ),
                    ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0),
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterBold',
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1, // Set the desired width
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Select a category',
                      ),
                      hint: const Center(
                        child: Text(
                          'Select a category',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterBold',
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Hour'),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedHour = hours[index];
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  return Center(child: Text('${hours[index]}'));
                                },
                                childCount: hours.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Minute'),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedMinute = minutes[index];
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  return Center(child: Text('${minutes[index]}'));
                                },
                                childCount: minutes.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 300.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle add daily goal logic here
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InterBold',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    child: const Text('Create Daily Goal'),
                  ),
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
              Navigator.pushNamed(context, Routes.dailyGoal);
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