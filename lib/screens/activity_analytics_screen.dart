import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:wellbeeapp/services/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityPlan {
  final String activity;
  final double hours;

  ActivityPlan(this.activity, this.hours);
}

class ActivityAnalyticsScreen extends StatefulWidget {
  const ActivityAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _ActivityAnalyticsScreenState createState() => _ActivityAnalyticsScreenState();
}

class _ActivityAnalyticsScreenState extends State<ActivityAnalyticsScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  int _currentIndex = 1; // BottomNavigationBar index for Activities
  List<ActivityPlan> planData = [];
  DateTime activityDate = DateTime.now(); // Add this line to store the activity date

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _retrieveData();
  }   

  Future<void> _retrieveData() async {
    try {
      if (currentUser != null) {
        // Get activities for the current date (activityDate)
        String formattedDate = DateFormat('yyyy-MM-dd').format(activityDate);

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .where('date', isEqualTo: formattedDate) // Compare against the formatted date
            .get();

        planData.clear();

        for (var doc in snapshot.docs) {
          String activityName = doc['activityName'];
          String hourString = doc['hour'];
          String minuteString = doc['minute'];
          double hours = double.parse(hourString) + (double.parse(minuteString) / 60);
          planData.add(ActivityPlan(activityName, hours));
        }

        setState(() {
          isLoading = false;
        });

        // Show a message if no activities are found
        if (planData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No activities found for ${DateFormat('d MMM yyyy').format(activityDate)}.', 
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                )
              ),
            ),
          );
        }
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error fetching activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch activities data.', 
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
            )
          ),
        ),
      );
    }
  }
 
  List<BarChartGroupData> _generateData(List<ActivityPlan> plans) {
    return plans.asMap().entries.map((entry) {
      int index = entry.key;
      ActivityPlan plan = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: plan.hours,
            color: const Color(0xFF96C1F9),
            width: 40,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(4),
              topRight: const Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
  
  Widget _buildChartPlan(BuildContext context, List<ActivityPlan> planData) {
    double maxHours = planData.fold(0, (prev, element) {
      return (element.hours > prev) ? element.hours : prev;
    });

    double chartMaxY = maxHours - 0.3;

    return SizedBox(
      height: 500,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              minY: 0, // Ensure the horizontal grid lines start at 0
              maxY: chartMaxY + 1,
              barGroups: _generateData(planData),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 40, // Adjusted to prevent overflow
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < planData.length) {
                        // Split the activity name into words and arrange them vertically
                        List<String> words = planData[index].activity.split(' ');
                        return Transform.rotate(
                          angle: -0.5, // Rotate the entire column
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: words.map((word) {
                              return Text(
                                word,
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              );
                            }).toList(),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const style = TextStyle(
                        color: Colors.black,
                        fontFamily: 'InterSemiBold',
                        fontSize: 8,
                      );
                      String text;
                      if (value == 0) {
                        text = '0 hr';
                      } else if (value == 1) {
                        text = '1 hr';
                      } else {
                        text = '${value.toInt()} hrs';
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 1,
                        child: Text(text, style: style),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Activity Analytics', 
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'InterBold',
            )
        ),
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : planData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No activities found for ${DateFormat('d MMM yyyy').format(activityDate)}.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'InterSemiBold',
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.filter_list, color: Colors.white),
                          label: const Text("Filter",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'InterSemiBold',
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9887FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () {
                            _showFilterDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'InterBold',
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display the date of the activity below the filter button
                  Text(
                    DateFormat('d MMM yyyy').format(activityDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'InterSemiBold',
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Center the chart
                  Center(
                    child: _buildChartPlan(context, planData),
                  ),
                ],
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

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();

        return AlertDialog(
          title: const Text("Filter Activities", 
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'InterSemiBold',
            )
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                      Navigator.pop(context);
                      _filterActivitiesByDate(selectedDate);
                    });
                  }
                },
                child: const Text("Select Date",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'InterSemiBold',
                  )
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    activityDate = DateTime.now(); // Reset to the current date
                  });
                  Navigator.pop(context);
                  _retrieveData(); // Fetch activities for the current date
                },
                child: const Text("Reset Filter",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'InterSemiBold',
                  )
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _filterActivitiesByDate(DateTime date) async {
    if (currentUser != null) {
      try {
        // Format the selected date to match the format in the database
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .where('date', isEqualTo: formattedDate) // Compare the date field directly
            .get();

        setState(() {
          if (snapshot.docs.isNotEmpty) {
            // If activities are found, update the planData and activityDate
            planData.clear();
            for (var doc in snapshot.docs) {
              String activityName = doc['activityName'];
              String hourString = doc['hour'];
              String minuteString = doc['minute'];
              double hours = double.parse(hourString) + (double.parse(minuteString) / 60);
              planData.add(ActivityPlan(activityName, hours));
            }
            activityDate = date;
          } else {
            // If no activities are found, retain the current date's data
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('No activities found for ${DateFormat('d MMM yyyy').format(date)}.', 
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                  )
                ),
              ),
            );
          }
        });
      } catch (e) {
        print('Error filtering activities by date: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch activities for the selected date.', 
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
              )
            ),
          ),
        );
      }
    }
  }
}
