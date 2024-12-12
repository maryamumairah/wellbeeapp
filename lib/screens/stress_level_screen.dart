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
  int _currentIndex = 3;
  String? selectedCategory;
  DateTime? selectedDate;
  String? filterCategory;
  DateTime? filterDate;

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
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
                child: Text(
                  'Stress Level',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'InterBold',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text(
                      'Filters',
                      style: TextStyle(fontSize: 16, fontFamily: 'InterSemiBold'),
                    ),
                    onPressed: () {
                      _showFilterDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              break;
            case 3:
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontFamily: 'InterBold'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCategory,
                hint: const Text(
                  'Filter by Category',
                  style: TextStyle(fontSize: 16, fontFamily: 'InterSemiBold'),
                ),
                items: [
                  'Calm',
                  'Low Stress',
                  'Moderate Stress',
                  'High Stress',
                  'Overwhelmed'
                ]
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF96C1F9),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate == null
                          ? 'Filter by Date'
                          : DateFormat('dd MMM yyyy').format(selectedDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'InterSemiBold',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    filterCategory = selectedCategory;
                    filterDate = selectedDate;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'InterSemiBold',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = null;
                    selectedDate = null;
                    filterCategory = null;
                    filterDate = null;
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(fontSize: 16, fontFamily: 'InterSemiBold'),
                ),
              ),
            ],
          ),
        );
      },
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
          .orderBy('date', descending: false) // Fetch in ascending order first
          .snapshots(),
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

          if (filterCategory != null) {
            reports = reports
                .where((report) => report.category == filterCategory)
                .toList();
          }

          if (filterDate != null) {
            reports = reports.where((report) {
              DateTime reportDate = DateTime.parse(report.date);
              return reportDate == filterDate;
            }).toList();
          }

          // Sort the reports by date in descending order
          reports.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

          _generateData(reports);

          return Column(
            children: [
              const SizedBox(height: 16),
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
            width: 40, // Reduced width for better spacing
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
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
                        reservedSize: 30, // Adjust this value to add more space for labels
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < barChartData.length) {
                            String date = DateFormat('dd MMM').format(
                              DateTime.parse(reportData[index].date),
                            );
                            return Transform.rotate(
                              angle: -0.5, // Rotate text by ~-28.6 degrees
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0), // Add spacing
                                child: Text(
                                  date,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
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
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      top: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      left: BorderSide.none,
                    ),
                  ),
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
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        reportData[index].getImagePath(),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
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
                            formattedDate.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'InterSemiBold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reportData[index].category,
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'InterBold',
                              color: Colors.black,
                            ),
                          ),
                          if (reportData[index].stressor != null &&
                              reportData[index].stressor!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${reportData[index].stressor}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'InterSemiBold',
                                fontStyle: FontStyle.italic, // To differentiate it
                              ),
                            ),
                          ],
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
  final String? stressor; // New field for stressor

  StressLevelReport(this.date, this.level, this.category, this.description, this.stressor);

  StressLevelReport.fromMap(Map<String, dynamic> map)
      : date = map['date'] ?? 'Unknown date',
        level = map['level'] ?? 0,
        category = getCategory(map['level'] ?? 0),
        description = map['description'],
        stressor = map['stressor']; // Get stressor from Firestore

  static String getCategory(int level) {
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

  String getImagePath() {
    switch (category) {
      case 'Calm':
        return 'assets/calm.png';
      case 'Low Stress':
        return 'assets/low_stress.png';
      case 'Moderate Stress':
        return 'assets/moderate_stress.png';
      case 'High Stress':
        return 'assets/high_stress.png';
      case 'Overwhelmed':
        return 'assets/overwhelmed.png';
      default:
        return 'assets/default.png';
    }
  }
}

