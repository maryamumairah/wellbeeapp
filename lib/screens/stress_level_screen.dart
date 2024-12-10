import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeeapp/routes.dart';

class StressLevelScreen extends StatefulWidget {
  const StressLevelScreen({Key? key}) : super(key: key);

  @override
  _StressLevelScreenState createState() => _StressLevelScreenState();
}

class _StressLevelScreenState extends State<StressLevelScreen> {
  List<BarChartGroupData> barChartData = [];
  int _currentIndex = 3; // Set the initial index to the stress level screen (index 3)
  String? selectedCategory;
  DateTimeRange? selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
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
                    fontFamily: 'InterBold',
                  ),
                ),
              ),
              _buildFilterControls(),
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
              // Navigator.pushNamed(context, Routes.goals);
              break;
            case 3:
              // No action needed for the stress level screen since it's already here
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

  Widget _buildFilterControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: selectedCategory,
                hint: const Text('Filter by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'InterSemiBold')),
                items: ['Calm', 'Low Stress', 'Moderate Stress', 'High Stress', 'Overwhelmed']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16), // Spacing between filters
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Show a popup date picker
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDateRange = DateTimeRange(
                        start: pickedDate,
                        end: pickedDate,
                      ); // Single date wrapped in a range
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200], 
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  selectedDateRange == null
                      ? 'Filter by Date'
                      : 'Date: ${DateFormat('dd MMM yyyy').format(selectedDateRange!.start)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'InterSemiBold'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // Spacing below the filters
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                selectedCategory = null;
                selectedDateRange = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text('Reset Filters', 
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view your stress data.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('stressReports')
          .orderBy('date', descending: false) // Sorting by date in Firestore (ascending)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data.'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No stress data available.'));
        } else {
          // Convert the documents into StressLevelReport objects
          List<StressLevelReport> reports = snapshot.data!.docs
              .map((documentSnapshot) =>
                  StressLevelReport.fromMap(documentSnapshot.data() as Map<String, dynamic>))
              .toList();

          // Apply filters
          if (selectedCategory != null) {
            reports = reports
                .where((report) => report.category == selectedCategory)
                .toList();
          }

          if (selectedDateRange != null) {
            reports = reports.where((report) {
              DateTime reportDate = DateTime.parse(report.date);
              return reportDate.isAtSameMomentAs(selectedDateRange!.start) || // Matches the start date
                    reportDate.isAtSameMomentAs(selectedDateRange!.end) ||   // Matches the end date
                    (reportDate.isAfter(selectedDateRange!.start) && 
                      reportDate.isBefore(selectedDateRange!.end));          // Falls within the range
            }).toList();
          }

          reports.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

          _generateData(reports);

          return Column(
            children: [
              const SizedBox(height: 16), // Space between Reset Filters and Bar Chart
              _buildChart(context, reports),
            ],
          );
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
            width: 40,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildChart(BuildContext context, List<StressLevelReport> reportData) {
    int maxLevel = reportData.fold(0, (prev, element) {
      return (element.level > prev) ? element.level : prev;
    });

    double chartMaxY = maxLevel >= 5 ? maxLevel.toDouble() : 5.0;

    return Column(
      children: [
        SizedBox(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY + 1,
                  barGroups: barChartData,
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
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 1 == 0) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
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
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular container for the image
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Adjust the padding to resize the image inside
                      child: Image.asset(
                        reportData[index].getImagePath(),
                        fit: BoxFit.contain, // Ensures the image fits within the circle
                        alignment: Alignment.center, // Center-align the image
                      ),
                    ),
                  ),
                ),
                // Rectangular container for the list item content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate.toUpperCase(), // Convert to uppercase
                            style: const TextStyle(
                              fontSize: 12, 
                              fontFamily: 'InterSemiBold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reportData[index].category, // Larger and bold category text
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'InterBold',
                              color: Colors.black,
                            ),
                          ),
                          if (reportData[index].description != null &&
                              reportData[index].description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              reportData[index].description!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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

  String getImagePath() {
    switch (level) {
      case 1:
        return 'assets/calm.png';
      case 2:
        return 'assets/low_stress.png';
      case 3:
        return 'assets/moderate_stress.png';
      case 4:
        return 'assets/high_stress.png';
      case 5:
        return 'assets/overwhelmed.png';
      default:
        return 'assets/unknown.png';
    }
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
