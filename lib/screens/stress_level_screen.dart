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
      body: SingleChildScrollView( // Wrap the body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding to improve layout
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
            color: Colors.blue,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildChart(BuildContext context, List<StressLevelReport> reportData) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width * 0.9,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 5,
              barGroups: barChartData,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < reportData.length) {
                        return Text(
                          DateFormat('dd MMM').format(
                            DateTime.parse(reportData[index].date),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling
          shrinkWrap: true, // Ensure the ListView does not take infinite height
          itemCount: reportData.length,
          itemBuilder: (context, index) {
            String formattedDate = DateFormat('dd MMM yyyy')
                .format(DateTime.parse(reportData[index].date));
            return Container( // Wrap ListTile with Container
              margin: const EdgeInsets.symmetric(vertical: 8.0), // Add margin around the box
              padding: const EdgeInsets.all(16.0), // Add padding inside the box
              decoration: BoxDecoration(
                color: Colors.white, // Set the background color to white
                borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4), // Shadow offset
                  ),
                ],
              ),
              child: ListTile(
                title: Text(formattedDate),
                subtitle: Text(
                  '${reportData[index].category}${reportData[index].description != null && reportData[index].description!.isNotEmpty ? '\n${reportData[index].description}' : ''}',
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
