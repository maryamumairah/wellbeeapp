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
    _loadCounter();
    retrieveActivityTime(widget.activityID); 
  }

  Future<void> _loadCounter() async {    
    setState(() {
      _counter = 0; // initial counter
    });
  }

  Future<void> retrieveActivityTime(String activityID) async {
    try {
      DocumentSnapshot ds = await FirebaseFirestore.instance.collection('activities').doc(activityID).get();

      if (ds.exists) {
        int hour = int.parse(ds['hour']);
        int minute = int.parse(ds['minute']);

        setState(() {
          _counter = (hour * 3600) + (minute * 60);
          _initialCounter = _counter;
        });

        QuerySnapshot timerLogsSnapshot = await FirebaseFirestore.instance
            .collection('activities')
            .doc(activityID)
            .collection('timerLogs')
            .orderBy('startTime', descending: true)
            .get();

        if (timerLogsSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> fetchedRecords = timerLogsSnapshot.docs.map((doc) {
            return {
              'playDuration': doc['playDuration'],
              'start': DateFormat('h:mm a').format(doc['startTime'].toDate()),
              'end': doc['endTime'] != null ? DateFormat('h:mm a').format(doc['endTime'].toDate()) : 'N/A',
            };
          }).toList();

          setState(() {
            _timeRecords = fetchedRecords;
          });
        }
      } else {
        print('Activity document does not exist');
      }
    } catch (e) {
      print('Error retrieving activity time: $e');
    }
  }

  Future<void> _startTimer() async {
    print('Starting timer...');
    _startTime = DateTime.now(); 

    // Create timerLogID if it doesn't exist
    if (_timerLogID == null) {
      int timerLogCount = await DatabaseMethods().getTimerLogCount(widget.activityID) + 1;
      _timerLogID = "T${timerLogCount.toString().padLeft(4, '0')}";
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
          print('Timer running: $_counter seconds left');
        } else {
          _timer!.cancel();
          // _showCompletionDialog();
          print('Timer completed');
        }
      });
    });
   
    Map<String, dynamic> timerLogInfoMap = {
      'activityID': widget.activityID,
      'startTime': _startTime,
      'timerLogID': _timerLogID,
    };

    await DatabaseMethods().addTimerLogDetails(widget.activityID, timerLogInfoMap).then((value) {
      print('Timer log details (timerLogID and startTime) added successfully');
    }).catchError((error) {
      print('Error adding timer log details (timerLogID and startTime): $error');
    });
  }

  Future<void> _pauseTimer() async {
    print('Pausing timer...');
    if (_timer != null) {
      _timer!.cancel();
      _endTime = DateTime.now();

      setState(() {
        _isPaused = true; // Pause the timer
      });

      if (_startTime != null && _endTime != null) {
        int playDuration = _initialCounter - _counter;

        Map<String, dynamic> timerLogInfoMap = {
          'playDuration': FieldValue.increment(playDuration),
          'endTime': _endTime,
        };

        // Update Firestore
        try {
          QuerySnapshot latestLogSnapshot = await FirebaseFirestore.instance
              .collection('activities')
              .doc(widget.activityID)
              .collection('timerLogs')
              .orderBy('startTime', descending: true)
              .limit(1)
              .get();

          if (latestLogSnapshot.docs.isNotEmpty) {
            DocumentSnapshot latestLog = latestLogSnapshot.docs.first;

            await FirebaseFirestore.instance
                .collection('activities')
                .doc(widget.activityID)
                .collection('timerLogs')
                .doc(latestLog.id)
                .update(timerLogInfoMap);

            print('Timer log updated: playDuration: $playDuration, endTime: $_endTime');

            // Update UI records
            setState(() {
              _timeRecords.add({
                'playDuration': playDuration.toString(),
                'start': DateFormat('h:mm a').format(_startTime!),
                'end': DateFormat('h:mm a').format(_endTime!),
              });
            });
          }
        } catch (e) {
          print('Error updating Firestore: $e');
        }
      }
    }
  }


  void _resumeTimer() async {
    print('Resuming timer...');
    if (_timerLogID == null) { 
      int timerLogCount = await DatabaseMethods().getTimerLogCount(widget.activityID) + 1;
      _timerLogID = "T${timerLogCount.toString().padLeft(4, '0')}";
    }

    _startTimer();
    setState(() {
      _isPaused = false; // set the timer to resumed
      _startTime = DateTime.now(); 
    });
    // _startTimer();
    print('Timer resumed');
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
                  transform: Matrix4.rotationY(3.14159),
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
              height: 200,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Play Duration', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              Text(_formatCounter(int.tryParse(record['playDuration']?.toString() ?? '0') ?? 0)),
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