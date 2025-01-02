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
  List<FlSpot> lineChartData = [];
  int _currentIndex = 3;
  String? selectedCategory;
  DateTime? selectedDate;
  String? filterCategory;
  DateTime? filterDate;
  String? _sortOrder; // Default: Sort by last updated (descending)
  bool _isFilterApplied = false;


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
                    icon: Icon(_isFilterApplied ? Icons.filter_alt : Icons.filter_alt_outlined, color: Colors.white),
                    label: const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.white,
                        fontFamily: 'InterSemiBold'),
                    ),
                    onPressed: () {
                      _showFilterDialog();
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
              Navigator.pushReplacementNamed(context, Routes.home);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, Routes.activity);
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
                    if (selectedCategory != null || selectedDate != null) {
                      filterCategory = selectedCategory;
                      filterDate = selectedDate;
                      _isFilterApplied = true;
                    }
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
                    _isFilterApplied = false;
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
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading data.', 
              style: TextStyle(
                fontSize: 16, 
                fontFamily: 'InterSemiBold',
              )
            )
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No stress data available.', 
              style: TextStyle(
                fontSize: 16, 
                fontFamily: 'InterSemiBold'
              )
            )
          );
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
            // Normalize both dates by setting the time to midnight (00:00:00)
            DateTime normalizedReportDate = DateTime(reportDate.year, reportDate.month, reportDate.day);
            DateTime normalizedFilterDate = DateTime(filterDate!.year, filterDate!.month, filterDate!.day);
            
            return normalizedReportDate == normalizedFilterDate;
          }).toList();
        }

        _sortReports(reports);

          // Check if there are no results after filtering
        if (reports.isEmpty) {
          return const Center(
            child: Text(
              'No data available for the selected filters.',
              style: TextStyle(fontSize: 16, fontFamily: 'InterSemiBold'),
            ),
          );
        }

          Map<String, List<StressLevelReport>> groupedReports = _groupReportsByDate(reports);

          List<String> dates = groupedReports.keys.toList();
          dates.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 450, // Fixed height for the bar chart
                  child: PageView.builder(
                    controller: PageController(
                      initialPage: dates.indexWhere((date) {
                        // Normalize the dates for comparison
                        DateTime parsedDate = DateTime.parse(date);
                        DateTime normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
                        DateTime today = DateTime.now();
                        DateTime normalizedToday = DateTime(today.year, today.month, today.day);
                        return normalizedDate == normalizedToday;
                      }).clamp(0, dates.length - 1), // Ensure index is within valid range
                    ),
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      String date = dates[index];
                      return _buildChart(context, groupedReports[date]!, date);
                    },
                  ),
                ),
                Column(
                  children: [
                    // _buildSortOptions(), // Add sort UI above ListView
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        return _buildReportItem(context, reports[index]);
                      },
                    ),
                    const SizedBox(height: 100), // Extra space at the bottom
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _sortReports(List<StressLevelReport> reports) {
    if (_sortOrder == "First Updated") {
      reports.sort((a, b) {
        return DateTime.parse(a.date).compareTo(DateTime.parse(b.date)); // Ascending
      });
    } else if (_sortOrder == "Last Updated") {
      reports.sort((a, b) {
        return DateTime.parse(b.date).compareTo(DateTime.parse(a.date)); // Descending
      });
    }
  }

  Widget _buildSortOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the far right
        children: [
          SizedBox(
            width: 150, // Adjust the width of the dropdown field
            child: DropdownButtonFormField<String>(
              value: _sortOrder,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true, 
                fillColor: Colors.white, 
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Removes border color
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Removes border color when focused
                  borderRadius: BorderRadius.circular(15),
                ),
                // Add shadow to the dropdown field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: const Text(
                "Sort by", // Placeholder text
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'InterSemiBold',
                  color: Colors.black, // Placeholder text color
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Last Updated",
                  child: Text(
                    "Newest First",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'InterSemiBold',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: "First Updated",
                  child: Text(
                    "Oldest First",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'InterSemiBold',
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _sortOrder = value!;
                });
              },
              dropdownColor: Colors.white, // Background color for dropdown menu
              borderRadius: BorderRadius.circular(15), // Border radius for dropdown items
              alignment: Alignment.centerLeft, // Align dropdown options to the left
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, StressLevelReport report) {
    String formattedTime = DateFormat('HH:mm').format(DateTime.parse(report.date));
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(report.date));
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
                report.getImagePath(),
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
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'InterSemiBold',
                    ),
                  ),
                  Text(
                    formattedDate.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'InterSemiBold',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.category,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'InterBold',
                      color: Colors.black,
                    ),
                  ),
                  if (report.stressor != null && report.stressor!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${report.stressor}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'InterSemiBold',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (report.description != null && report.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      report.description!,
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
  }

  Map<String, List<StressLevelReport>> _groupReportsByDate(List<StressLevelReport> reports) {
    Map<String, List<StressLevelReport>> groupedReports = {};
    
    for (var report in reports) {
      // Extract only the date part (e.g., "2024-12-16")
      String dateOnly = DateFormat('yyyy-MM-dd').format(DateTime.parse(report.date));
      if (!groupedReports.containsKey(dateOnly)) {
        groupedReports[dateOnly] = [];
      }
      groupedReports[dateOnly]!.add(report);
    }

    // Sort each group by the time within the day
    groupedReports.forEach((date, reports) {
      reports.sort((a, b) {
        DateTime timeA = DateTime.parse(a.date);
        DateTime timeB = DateTime.parse(b.date);
        return timeA.compareTo(timeB); // Sort in ascending order of time
      });
    });

    return groupedReports;
  }



  void _generateData(List<StressLevelReport> reports) {
    lineChartData = reports.asMap().entries.map((entry) {
      int index = entry.key;
      StressLevelReport report = entry.value;
      return FlSpot(index.toDouble(), report.level.toDouble());
    }).toList();
  }

  Widget _buildChart(BuildContext context, List<StressLevelReport> reportData, String date) {
    // Ensure y-axis shows full values (1, 2, 3, 4, 5)
    double chartMaxY = 5.5;

    // Generate data for the specific day
    _generateData(reportData);

    return Column(
      children: [
        Text(
          DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
          style: const TextStyle(
            fontSize: 18, 
            fontFamily: 'InterBold',),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(12), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Light shadow
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10), // Padding around the chart
          margin: const EdgeInsets.symmetric(horizontal: 5), // Margin for spacing
          child: Row(
            children: [
              // Title "Stress Level" rotated vertically
              const RotatedBox(
                quarterTurns: 3, // Rotate the text by 90 degrees counter-clockwise
                child: Text(
                  "Stress Level",
                  style: TextStyle(
                    fontSize: 13, 
                    fontFamily: 'InterSemiBold', 
                  ),
                ),
              ),
              const SizedBox(width: 16), // Space between title and chart
              // LineChart inside the container
              Expanded(
                child: SizedBox(
                  height: 350, // Fixed height for the chart
                  child: LineChart(
                    LineChartData(
                      maxY: chartMaxY, // Ensure maxY is 5.5 to show full y-axis values
                      minY: 1, // Ensure minY is 1 to show full y-axis values
                      lineBarsData: [
                        LineChartBarData(
                          spots: lineChartData,
                          isCurved: true,
                          color: const Color(0xFF96C1F9),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.blueAccent,
                              strokeWidth: 0,
                              strokeColor: Colors.white,
                            );
                          }),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        horizontalInterval: 1, // Lines at every integer value
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.3), // Standard grey line
                            strokeWidth: 1, // Normal line thickness
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
                            reservedSize: 30,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < reportData.length) {
                                String formattedTime = DateFormat('HH:mm').format(
                                  DateTime.parse(reportData[index].date),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Transform.rotate(
                                    angle: -0.5,
                                    child: Text(
                                      formattedTime,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Inter',
                                      ),
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
                              if (value % 1 == 0 && value >= 1 && value <= 5) {
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
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (LineBarSpot touchedSpot) {
                            // Customize color dynamically if needed
                            return const Color(0xFF96C1F9); // Replace with logic if dynamic colors are needed
                          },
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              final report = reportData[touchedSpot.spotIndex];
                              return LineTooltipItem(
                                report.category,
                                const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'InterSemiBold',
                                ),
                              );
                            }).toList();
                          },
                          fitInsideHorizontally: true, // Ensure tooltip fits inside the chart horizontally
                          fitInsideVertically: true, // Ensure tooltip fits inside the chart vertically
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

