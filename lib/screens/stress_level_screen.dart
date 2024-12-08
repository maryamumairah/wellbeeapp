import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';

class StressLevelScreen extends StatefulWidget {
  const StressLevelScreen({Key? key}) : super(key: key);
  @override
  _StressLevelScreenState createState() => _StressLevelScreenState();
}

class _StressLevelScreenState extends State<StressLevelScreen> {
  List<BarChartGroupData> barChartData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Stress Level',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildBody(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.report);
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 40),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stressLevel').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data.'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No stress data available.'));
        } else {
          List<StressLevelReport> reports = snapshot.data!.docs
              .map((documentSnapshot) =>
                  StressLevelReport.fromMap(documentSnapshot.data() as Map<String, dynamic>))
              .toList();

          // Sort the reports by date in ascending order
          reports.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

          _generateData(reports);
          return _buildChart(context, reports);
        }
      },
    );
  }

  void _generateData(List<StressLevelReport> reports) {
    barChartData = reports.asMap().entries.map((entry) {
      int index = entry.key;
      StressLevelReport report = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: report.level.toDouble(),
            color: const Color(0xFF96C1F9),
            width: 30, // Increase the width of each bar
            borderRadius: BorderRadius.zero, // Make the bars rectangular
          ),
        ],
      );
    }).toList();
  }

  Widget _buildChart(BuildContext context, List<StressLevelReport> reportData) {
    return Column(
      children: [
        SizedBox(
          height: 400, // Adjust the height of the container to make it bigger
          width: MediaQuery.of(context).size.width * 0.9, // Adjust width if needed
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // White background for the container
              borderRadius: BorderRadius.circular(16), // Border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Shadow position
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0), // Add padding to create space inside the container
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Ensure the bar chart fits the rounded corners
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5, // Set the max Y value to 5
                  barGroups: barChartData,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3), // Light grey lines
                        strokeWidth: 1,
                      );
                    },
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide top labels
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide right labels
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < barChartData.length) {
                            return Text(
                              DateFormat('dd MMM').format(
                                DateTime.parse(reportData[index].date),
                              ),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, // Set interval to 1 to show each label
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 1 == 0) {
                            return Text(
                              value.toStringAsFixed(0), // Display only whole numbers
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false), // Remove border around the chart itself
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reportData.length,
          itemBuilder: (context, index) {
            String formattedDate = DateFormat('dd MMM yyyy')
                .format(DateTime.parse(reportData[index].date));
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(formattedDate),
                subtitle: Text(
                  '${reportData[index].category}${reportData[index].description != null &&
                              reportData[index].description!.isNotEmpty
                          ? '\n${reportData[index].description}'
                          : ''}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

}

class StressLevelReport {
  final String date;
  final int level;
  final String category;
  final String? description;

  StressLevelReport(this.date, this.level, this.category, this.description);

  StressLevelReport.fromMap(Map<String, dynamic> map)
      : date = map['date'] ?? 'Unknown date',
        level = map['level'] ?? 0,
        category = getCategory(map['level'] ?? 0),
        description = map['description'];

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'level': level,
      'category': category,
      'description': description,
    };
  }
}

String getCategory(int level) {
  switch (level) {
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
