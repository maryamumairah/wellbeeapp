import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:wellbeeapp/services/database.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityAnalyticsScreen extends StatefulWidget {
  const ActivityAnalyticsScreen({Key? key}) : super(key: key);

  // final String activityID;

  @override
  _ActivityAnalyticsScreenState createState() => _ActivityAnalyticsScreenState();
}

class _ActivityAnalyticsScreenState extends State<ActivityAnalyticsScreen> {
  int _currentIndex = 1; // BottomNavigationBar index for Activities

  final List<ActivityPlan> planData = [
    ActivityPlan('Design Prototype', 4),
    ActivityPlan('Lunch', 1.5),
    ActivityPlan('Revise Report', 2.5),
  ];

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

    double chartMaxY = maxHours >= 8 ? maxHours : 8.0;

    return SizedBox(
      height: 350,
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
        // padding: const EdgeInsets.only(left: 5.0, right: 16.0, top: 16.0, bottom: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: chartMaxY + 1, 
              barGroups: _generateData(planData),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 1, // display horizontal line
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
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < planData.length) {
                        return Text(
                          planData[index].activity,
                          style: const TextStyle(fontSize: 10), 
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
                        fontWeight: FontWeight.bold,
                        fontSize: 8.5,
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
                        space: 1, // space from axis y line to text
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
        title: const Text(
          'Activities',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Text( 
                // kiv use date from firebase                                    
                    DateFormat('d MMM yyyy').format(DateTime.now()), 
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ), 
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10.0),             
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline  
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Container(
                  //   height: 100,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     // border: Border.all(color: Colors.grey),
                  //     borderRadius: BorderRadius.circular(10.0),
                  //   ),                    
                  // ),
                  _buildChartPlan(context, planData),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10.0),              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline  
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,                      
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ],
              ),
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
              Navigator.pushNamed(context, Routes.home);
              break;
            case 1:
              Navigator.pushNamed(context, Routes.activity);
              break;
            case 2:
              //Navigator.pushNamed(context, Routes.);
              break;
            case 3:
              //Navigator.pushNamed(context, Routes.);
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

class ActivityPlan {
  final String activity;
  final double hours;

  ActivityPlan(this.activity, this.hours);
}