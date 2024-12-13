import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:wellbeeapp/services/database.dart';

class TimerActivityScreen extends StatefulWidget {
  final String activityID;

  TimerActivityScreen({required this.activityID});

  @override
  _TimerActivityScreenState createState() => _TimerActivityScreenState();
}

class _TimerActivityScreenState extends State<TimerActivityScreen> {
  int _currentIndex = 1;
  Timer? _timer;
  int _counter = 0;
  int _initialCounter = 0; // Store the initial counter value for progress calculation
  bool _isPaused = true; // Initially paused
  DateTime? _startTime;
  DateTime? _endTime;
  String? _timerLogID;
  List<Map<String, dynamic>> _timeRecords = []; // List to store duration, start time, and end time

  @override
  void initState() {
    super.initState();
    retrieveActivityTime(widget.activityID);
  }

  Future<void> retrieveActivityTime(String activityID) async {
    try {
      DocumentSnapshot ds = await FirebaseFirestore.instance.collection('activities').doc(activityID).get();

      if (ds.exists) {
        // Convert hour and minute to integers if they are stored as strings
        int hour = int.parse(ds['hour']);
        int minute = int.parse(ds['minute']);

        // Print retrieved data
        print('Activity ID: $activityID');
        print('Hour: $hour');
        print('Minute: $minute');

        setState(() {
          _counter = (hour * 3600) + (minute * 60); // Initialize counter with the combination of hour and minute
          _initialCounter = _counter; // Store the initial counter value
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving activity time: $e');
    }
  }

  void _startTimer() {
    _startTime = DateTime.now(); // Record start time
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _timer!.cancel();
        }
      });
    });
  }

  // void _pauseTimer() {
  //   if (_timer != null) {
  //     _timer!.cancel();
  //     _endTime = DateTime.now(); // Record end time
  //     setState(() {
  //       _isPaused = true;
  //       if (_startTime != null && _endTime != null) {
  //         // _timeRecords.add({
  //         _timeRecords.insert(0, { // Insert at the beginning of the list
  //           'duration': _counter.toString(),
  //           'start': DateFormat('h:mm a').format(_startTime!),
  //           'end': DateFormat('h:mm a').format(_endTime!),
  //         });
  //       }
  //     });
  //   }
  // }

  void _pauseTimer() async {
  // Future<void> _pauseTimer() async {
    if (_timer != null) { // if timer is running
      _timer!.cancel(); // Cancel timer
      _endTime = DateTime.now(); // Record end time
      setState(() {
        _isPaused = true; // set the timer to paused
        if (_startTime != null && _endTime != null) {
          _timeRecords.add({ // Add time records to the list 
            'duration': _counter.toString(),
            'start': DateFormat('h:mm a').format(_startTime!),
            'end': DateFormat('h:mm a').format(_endTime!),
          });

          // Save timer log details
          Map<String, dynamic> timerLogInfoMap = { // Create a map to store timer log details
            'activityID': widget.activityID, // widget is used to access the activityID passed to the TimerActivityScreen widget
            'playDuration': _initialCounter - _counter, // Calculate play duration
            'startTime': _startTime,
            'endTime': _endTime,
          };

          DatabaseMethods().addTimerLogDetails(widget.activityID, timerLogInfoMap).then((value) {
          // await DatabaseMethods().addTimerLogDetails(widget.activityID, timerLogInfoMap).then((value) {            
            print('Timer log details added successfully');
          }).catchError((error) {
            print('Error adding timer log details: $error');
          });
          
          if (_counter == 0) {
            // _showCompletionDialog();
          }        
        }
      });
    }
  }

    void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "TIME'S UP!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Icon(Icons.timer, size: 50, color: Colors.blue),          
        );
      },
    );
  }

  // void _resumeTimer() {
  //   _startTimer();
  //   setState(() {
  //     _isPaused = false;
  //     _startTime = DateTime.now();
  //   });
  // }

  void _resumeTimer() async {
    if (_timerLogID == null) {
      // Check if timer log exists
      int timerLogCount = await DatabaseMethods().getTimerLogCount(widget.activityID) + 1;
      _timerLogID = "T${timerLogCount.toString().padLeft(4, '0')}"; // timerLogID will be T0001, T0002, T0003, etc.
    }

    _startTimer();
    setState(() {
      _isPaused = false;
      _startTime = DateTime.now();
    });
  }

  String _formatCounter(int counter) {
    final hours = (counter ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((counter % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (counter % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() { // Cancel the timer when the screen is disposed
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Timer Activity',
           style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159), // Rotate by 180 degrees
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: _initialCounter > 0 ? _counter / _initialCounter : 1.0,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
                Text(
                  _formatCounter(_counter),
                  style: TextStyle(fontSize: 48),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    onPressed: _isPaused ? null : _pauseTimer,
                  ),
                ),
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: _isPaused ? _resumeTimer : null,                   
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 200, // Set a fixed height for the ListView
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('End Time', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(thickness: 2, indent: 20, endIndent: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _timeRecords.length,
                      itemBuilder: (context, index) {
                        final record = _timeRecords[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(_formatCounter(int.parse(record['duration']))), // Format duration
                              Text('${record['start']}'),
                              Text('${record['end']}'),
                            ],
                          ),
                        );
                      },
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