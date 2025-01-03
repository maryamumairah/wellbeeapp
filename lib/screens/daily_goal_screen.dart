import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellbeeapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyGoalScreen extends StatefulWidget {
  const DailyGoalScreen({Key? key}) : super(key: key);

  @override
  _DailyGoalScreenState createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends State<DailyGoalScreen> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  User? currentUser = FirebaseAuth.instance.currentUser;

  int _currentIndex = 2;

  // Variables to hold the calculated durations and play durations
  double durationWork = 0;
  double durationMeal = 0;
  double durationExercise = 0;
  double durationSelfLearning = 0;
  double durationSpiritual = 0;

  double playDurationWork = 0;
  double playDurationMeal = 0;
  double playDurationExercise = 0;
  double playDurationSelfLearning = 0;
  double playDurationSpiritual = 0;  

  // Loading state
  bool isLoading = true;

  DateTime? _displayedDate;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _retrieveData(DateTime.now()); // Set default date to current date
  }
  
    // Retrieve data from Firebase
  // Future<void> _retrieveData() async {
  Future<void> _retrieveData([DateTime? pickedDate]) async {
    if (currentUser != null) {

      // DateTime selectedDate = pickedDate ?? DateTime.now();
      // String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    DateTime selectedDate;

    if (pickedDate != null) {
      selectedDate = pickedDate;
    } else {
      // Fetch the latest date from Firestore
      var latestDateSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (latestDateSnapshot.docs.isNotEmpty) {
        final latestDate = latestDateSnapshot.docs.first.data()['date'];
        selectedDate = DateFormat('yyyy-MM-dd').parse(latestDate);
      } else {
        // Default to the current date if no data is found
        selectedDate = DateTime.now();
      }
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);      

      // Get activities collection for the current user
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .where('date', isEqualTo: formattedDate) // Assuming 'date' is stored in Firestore
          .get();

      //store existing categories
      Set<String> existingCategories = {};          

      // Variables to hold the calculated durations and play durations
      double workDuration = 0;
      double mealDuration = 0;
      double exerciseDuration = 0;
      double selfLearningDuration = 0;
      double spiritualDuration = 0;

      double workPlayDuration = 0;
      double mealPlayDuration = 0;
      double exercisePlayDuration = 0;
      double selfLearningPlayDuration = 0;
      double spiritualPlayDuration = 0;              

      // // Print all activityCategories in the activities collection
      // for (var doc in activitiesSnapshot.docs) {
      //   final data = doc.data() as Map<String, dynamic>;
      //   print('Data from Firestore: $data');
      //   final category = data['categoryName'] ?? '';
      //   print('Category: $category');
      // }

      // Iterate over all activities
      for (var doc in activitiesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Data from Firestore: $data');

        final category = data['categoryName'] ?? '';
        final hour = data['hour'] ?? 0;
        final minute = data['minute'] ?? 0;
        final duration = (hour is num ? hour : int.parse(hour.toString())) * 60 + (minute is num ? minute : int.parse(minute.toString()));

        existingCategories.add(category);

        // Fetch timer logs subcollection
        var timerLogsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(doc.id)
            .collection('timerLogs')
            .orderBy('timerLogID')
            .get();

        final timerLog = timerLogsSnapshot.docs.map((doc) => doc.data()).toList();

        print('Timer Log: $timerLog');

        // Sort timerLog by timerLogID
        timerLog.sort((a, b) {
          final aID = a['timerLogID'] ?? '';
          final bID = b['timerLogID'] ?? '';
          return aID.compareTo(bID);
        });

        final latestPlayDuration = (timerLog.isNotEmpty ? timerLog.last['playDuration'] ?? 0 : 0) / 60;

        print('Category: $category, Duration: $duration, Latest Play Duration: $latestPlayDuration');
          // 'Work', 'Meal', 'Exercise', 'Self-learning', 'Spiritual'


        switch (category) {
          case 'Work':
            workDuration += duration;
            workPlayDuration += latestPlayDuration;
            break;
          case 'Meal':
            mealDuration += duration;
            mealPlayDuration += latestPlayDuration;
            break;
          case 'Exercise':
            exerciseDuration += duration;
            exercisePlayDuration += latestPlayDuration;
            break;
          case 'Self-learning':
            selfLearningDuration += duration;
            selfLearningPlayDuration += latestPlayDuration;
            break;
          case 'Spiritual':
            spiritualDuration += duration;
            spiritualPlayDuration += latestPlayDuration;
            break;
          default:
            break;
        }
      }

      print('Total Duration Work: $workDuration, Total Play Duration Work: $workPlayDuration');
      print('Total Duration Meal: $mealDuration, Total Play Duration Meal: $mealPlayDuration');
      print('Total Duration Exercise: $exerciseDuration, Total Play Duration Exercise: $exercisePlayDuration');
      print('Total Duration Self-learning: $selfLearningDuration, Total Play Duration Self-learning: $selfLearningPlayDuration');
      print('Total Duration Spiritual: $spiritualDuration, Total Play Duration Spiritual: $spiritualPlayDuration');        

      // Update the UI with the calculated values
      setState(() {
        _displayedDate = selectedDate;

        durationWork = workDuration;
        durationMeal = mealDuration;
        durationExercise = exerciseDuration;
        durationSelfLearning = selfLearningDuration;
        durationSpiritual = spiritualDuration;

        playDurationWork = workPlayDuration;
        playDurationMeal = mealPlayDuration;
        playDurationExercise = exercisePlayDuration;
        playDurationSelfLearning = selfLearningPlayDuration;
        playDurationSpiritual = spiritualPlayDuration;

        isLoading = false; // Data has been loaded
      });
    } else {
      print('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [            
            Text(
              'Daily Goal',
              style: TextStyle(
                fontFamily: 'InterBold',
              ),
            ),            
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_month , color: Colors.white),
                          label: const Text(
                            'Filter Date',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'InterSemiBold',
                            ),
                          ),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              _retrieveData(pickedDate);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9887FF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_displayedDate != null)
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          // 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_displayedDate!)}',
                          '${DateFormat('d MMM yyyy').format(_displayedDate!)}',
                          style: const TextStyle(fontSize: 20, fontFamily: 'InterSemiBold'),
                          textAlign: TextAlign.center,
                        ),
                      ),                    
                      // Center(
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 16.0),
                      //     child: Text(
                      //       DateFormat('yyyy-MM-dd').format(selectedDate!),
                      //       style: const TextStyle(
                      //         fontSize: 18,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     DateTime? pickedDate = await showDatePicker(
                  //       context: context,
                  //       initialDate: DateTime.now(),
                  //       firstDate: DateTime(2000),
                  //       lastDate: DateTime(2101),
                  //     );
                  //     if (pickedDate != null) {
                  //       _retrieveData(pickedDate);
                  //     }
                  //   },
                  //   child: Text('Select Date'),
                  // ),                         
                    if (durationWork > 0)
                      _buildActivityCategory(
                        context,
                        icon: Icons.work,
                        category: 'Work',
                        duration: durationWork,
                        playDuration: playDurationWork,
                        color: Colors.black,
                      ),
                    if (durationMeal > 0)
                      _buildActivityCategory(
                        context,
                        icon: Icons.restaurant,
                        category: 'Meal',
                        duration: durationMeal,
                        playDuration: playDurationMeal,
                        color: Colors.black,
                      ),    
                    if (durationExercise > 0)
                      _buildActivityCategory(
                        context,
                        icon: Icons.fitness_center_rounded,
                        category: 'Exercise',
                        duration: durationExercise,
                        playDuration: playDurationExercise,
                        color: Colors.black,
                      ),
                    if (durationSelfLearning > 0)
                      _buildActivityCategory(
                        context,
                        icon: Icons.school_rounded,
                        category: 'Self-learning',
                        duration: durationSelfLearning,
                        playDuration: playDurationSelfLearning,
                        color: Colors.black,
                      ),
                    if (durationSpiritual > 0)                 
                      _buildActivityCategory(
                        context,
                        icon: Icons.self_improvement,
                        category: 'Spiritual',
                        duration: durationSpiritual,
                        playDuration: playDurationSpiritual,
                        color: Colors.black,
                      ),                                   
                      // if (durationWork == 0 && durationMeal == 0 && durationSpiritual == 0) ...[
                      if (durationWork == 0 && durationMeal == 0 && durationExercise == 0 && durationSelfLearning == 0 && durationSpiritual == 0) ...[
                        const SizedBox(height: 16.0),
                        const Center(
                          child: Text(
                            'No daily goal data available. Choose another date.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    const SizedBox(height: 16.0),                    
                    Divider(thickness: 3, indent: 20, endIndent: 20, color: Color(0xFFB8DEFF)),

                    Container(
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(8),
                      //   border: Border.all(color: Colors.white, width: 2),              
                      // ),
                      child: SfCircularChart(
                        // legend: Legend(isVisible: true, position: LegendPosition.bottom),
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        series: <CircularSeries>[
                          RadialBarSeries<ChartData, String>(
                            radius: '100%',
                            dataSource: [
                              // ChartData('Work', playDurationWork / durationWork),
                              // ChartData('Meal', playDurationMeal / durationMeal),
                              // ChartData('Spiritual', playDurationSpiritual / durationSpiritual), 

                              if (durationWork > 0)
                                // ChartData('Work', playDurationWork / durationWork),
                                ChartData('Work', (playDurationWork / durationWork) * 100),
                              if (durationMeal > 0)
                                // ChartData('Meal', playDurationMeal / durationMeal),
                                ChartData('Meal', (playDurationMeal / durationMeal) * 100),
                              if (durationExercise > 0)
                                // ChartData('Exercise', playDurationExercise / durationExercise),
                                ChartData('Exercise', (playDurationExercise / durationExercise) * 100),
                              if (durationSelfLearning > 0)
                                // ChartData('Self-learning', playDurationSelfLearning / durationSelfLearning),
                                ChartData('Self-learning', (playDurationSelfLearning / durationSelfLearning) * 100),
                              if (durationSpiritual > 0)
                                // ChartData('Spiritual', playDurationSpiritual / durationSpiritual),
                                ChartData('Spiritual', (playDurationSpiritual / durationSpiritual) * 100),
                            ],
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,                            
                            // dataLabelSettings: DataLabelSettings(isVisible: true), 
                            // dataLabelMapper: (ChartData data, _) => '${(data.y * 100).toStringAsFixed(0)}%',  
                            dataLabelMapper: (ChartData data, _) => '${data.y.toStringAsFixed(0)}%',

                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),                              
                            ),
                            pointColorMapper: (ChartData data, _) {
                              switch (data.x) {
                                case 'Work':
                                  return Colors.red;
                                case 'Meal':
                                  return Colors.blue;
                                case 'Exercise':
                                  return Colors.green;
                                case 'Self-learning':
                                  return Colors.orange;
                                case 'Spiritual':
                                  return Colors.yellow;
                                default:
                                  return Colors.white;
                              }
                            },
                            cornerStyle: CornerStyle.bothCurve,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () {               
      //         // Navigator.pushNamed(context, Routes.analyticsActivity);     
      //       },         
      //       backgroundColor: Colors.black,
      //       shape: const CircleBorder(),
      //       child: const Icon(Icons.bar_chart, size: 40),
      //     ),          
      //   ],
      // ), 
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

  Widget _buildActivityCategory(BuildContext context, {required IconData icon, required String category, required double duration, required double playDuration, required Color color}) {
    final int hour = duration ~/ 60;
    final int minute = (duration % 60).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                // child: Icon(icon, size: 35, color: Colors.black),
                child: Icon(icon, size: 35, color: color),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontSize: 18, fontFamily: 'InterSemiBold',),
                    ),
                    const SizedBox(height: 8.0),
                    LinearProgressIndicator(
                      value: playDuration / duration,
                      backgroundColor: Colors.white,
                      color: Colors.blue,
                      minHeight: 8.0,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Duration: ${hour > 0 ? '${hour}hr ' : ''}${minute > 0 ? '${minute}m' : ''}', // Modified line
                      style: const TextStyle(fontSize: 16, 
                      fontFamily: 'Inter',),
                    ),                    
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );    
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}