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

  // Variables to hold the total durations
  double durationWork = 0;
  double durationMeal = 0;
  double durationSpiritual = 0;

  double playDurationWork = 0;
  double playDurationMeal = 0;
  double playDurationSpiritual = 0;

  // Loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _retrieveData(); 
  }
  
    // Retrieve data from Firebase
  Future<void> _retrieveData() async {
    if (currentUser != null) {
      // Get activities collection for the current user
      var activitiesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .get();

      // Print all activityCategories in the activities collection
      for (var doc in activitiesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Data from Firestore: $data');
        final category = data['categoryName'] ?? '';
        print('Category: $category');
      }

      // Variables to hold the calculated durations and play durations
      double workDuration = 0;
      double mealDuration = 0;
      double spiritualDuration = 0;

      double workPlayDuration = 0;
      double mealPlayDuration = 0;
      double spiritualPlayDuration = 0;

      // Iterate over all activities
      for (var doc in activitiesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Data from Firestore: $data');

        final category = data['categoryName'] ?? '';
        final hour = data['hour'] ?? 0;
        final minute = data['minute'] ?? 0;
        final duration = (hour is num ? hour : int.parse(hour.toString())) * 60 + (minute is num ? minute : int.parse(minute.toString()));

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

        switch (category) {
          case 'Work':
            workDuration += duration;
            workPlayDuration += latestPlayDuration;
            break;
          case 'Meal':
            mealDuration += duration;
            mealPlayDuration += latestPlayDuration;
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
      print('Total Duration Spiritual: $spiritualDuration, Total Play Duration Spiritual: $spiritualPlayDuration');

      // Update the UI with the calculated values
      setState(() {
        durationWork = workDuration;
        durationMeal = mealDuration;
        durationSpiritual = spiritualDuration;

        playDurationWork = workPlayDuration;
        playDurationMeal = mealPlayDuration;
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
                fontWeight: FontWeight.bold,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActivityCategory(
                      context,
                      icon: Icons.work,
                      category: 'Work',
                      duration: durationWork,
                      playDuration: playDurationWork,
                    ),
                    _buildActivityCategory(
                      context,
                      icon: Icons.restaurant,
                      category: 'Meal',
                      duration: durationMeal,
                      playDuration: playDurationMeal,
                    ),                    
                    _buildActivityCategory(
                      context,
                      icon: Icons.self_improvement,
                      category: 'Spiritual',
                      duration: durationSpiritual,
                      playDuration: playDurationSpiritual,
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: SfCircularChart(
                        legend: Legend(isVisible: true, position: LegendPosition.bottom),
                        series: <CircularSeries>[
                          RadialBarSeries<ChartData, String>(
                            dataSource: [
                              ChartData('Work', playDurationWork / durationWork),
                              ChartData('Meal', playDurationMeal / durationMeal),
                              ChartData('Spiritual', playDurationSpiritual / durationSpiritual),
                            ],
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,                            
                            // dataLabelSettings: DataLabelSettings(isVisible: true), 
                            dataLabelMapper: (ChartData data, _) => '${(data.y * 100).toStringAsFixed(1)}%',                           
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

  Widget _buildActivityCategory(BuildContext context, {required IconData icon, required String category, required double duration, required double playDuration}) {
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 35, color: Colors.black),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 16),
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