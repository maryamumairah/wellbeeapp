import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:wellbeeapp/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimerActivityScreen extends StatefulWidget {
  final String activityID;

  TimerActivityScreen({required this.activityID});

  @override
  _TimerActivityScreenState createState() => _TimerActivityScreenState();
}

class _TimerActivityScreenState extends State<TimerActivityScreen> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  User? currentUser = FirebaseAuth.instance.currentUser;

  int _currentIndex = 1;
  Timer? _timer;
  int _counter = 0;
  int _initialCounter = 0; // Store the initial counter value for progress calculation
  int initialCounterActivity = 0;
  bool _isPaused = true; // Initially paused
  DateTime? _startTime;
  DateTime? _endTime;
  String? _timerLogID;
  List<Map<String, dynamic>> _timeRecords = []; // List to store duration, start time, and end time
  int initialCounterProgress = 0;

  @override
  void initState() {
    super.initState();
    retrieveActivityTime(widget.activityID); 
    retrieveTimerLogs(widget.activityID);
    retrieveInitialCounterProgress(widget.activityID);
  }

  Future<void> retrieveActivityTime(String activityID) async {
    try {
      if (currentUser != null) {
        DocumentSnapshot ds = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(activityID)
            .get();

        if (ds.exists) {

          int hour = int.parse(ds['hour']);
          int minute = int.parse(ds['minute']);

          int initialCounterActivity = (hour * 3600) + (minute * 60);

          setState(() {
            _counter = initialCounterActivity;
            _initialCounter = _counter;
          });

          QuerySnapshot timerLogsSnapshot = await FirebaseFirestore.instance // to retrieve the timer logs
              .collection('users')
              .doc(currentUser!.uid)
              .collection('activities')
              .doc(activityID)
              .collection('timerLogs')
              .orderBy('startTime', descending: true)
              .limit(1)
              .get();

          if (timerLogsSnapshot.docs.isEmpty) {
            // If timer logs don't exist
            setState(() {
              _counter = initialCounterActivity;
              _initialCounter = _counter;
            });
          } else { // timer logs exist
            DocumentSnapshot latestLog = timerLogsSnapshot.docs.first;
            Map<String, dynamic> data = latestLog.data() as Map<String, dynamic>;
            
            DateTime startTime = (data['startTime'] as Timestamp).toDate();
            print('Latest timerLogID startTime: $startTime');
            DateTime? endTime = data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null;
          
            int playDuration = data.containsKey('playDuration') ? data['playDuration'].toInt() : 0; // if the key exists, get the value, else return 0

            if (endTime == null) {
              // if endTime doesn't exist, timer is playing and haven't paused yet

              QuerySnapshot timerLogsSnapshot = await FirebaseFirestore.instance // to retrieve the timer logs
              .collection('users')
              .doc(currentUser!.uid)
              .collection('activities')
              .doc(activityID)
              .collection('timerLogs')
              .get();

              setState(() {
                //total of all playDuration from all timerlogs
                int totalPlayDuration = 0;
                for (var doc in timerLogsSnapshot.docs) {
                  Map<String, dynamic> logData = doc.data() as Map<String, dynamic>;
                  if (logData.containsKey('playDuration')) {
                    totalPlayDuration += (logData['playDuration'] as num).toInt();
                  }
                  print('playDuration: ${logData['playDuration']}');
                }                
                
                _counter = initialCounterActivity - totalPlayDuration - DateTime.now().difference(startTime).inSeconds;   
                print('counter: $_counter');
                print('initialCounterActivity: $initialCounterActivity');
                print('totalPlayDuration: $totalPlayDuration'); //kiv               
                     
                print(DateTime.now());
                print('startTime: $startTime');

                print(DateTime.now().difference(startTime).inSeconds);

                _resumeTimer();
              });
            } else {
              // If endTime exists, timer played and paused
              setState(() {
                int playDuration = data.containsKey('playDuration') ? data['playDuration'] : 0; // if the key exists, get the value, else return 0          

                if (initialCounterActivity == playDuration) { // timer completed
                  _counter = initialCounterActivity;
                  _initialCounter = _counter;                
                } else { // If endTime exists, timer played and paused
                  _counter = initialCounterActivity - playDuration;
                  _initialCounter = _counter;                

                }
             
              });

              
            }
          }  
        } else {
          print('Activity document does not exist');
        }
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error retrieving activity time: $e');
    }
  }

  Future<void> retrieveTimerLogs(String activityID) async {
    try {
      if (currentUser != null) {
        QuerySnapshot timerLogsSnapshot = await FirebaseFirestore.instance // to retrieve the timer logs
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(activityID)
            .collection('timerLogs')
            .get();

        if (timerLogsSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> fetchedRecords = timerLogsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?; // Ensure data is not null

            return {
            'playDuration': data != null && data.containsKey('playDuration') ? data['playDuration'] : 0,
            'start': data != null && data.containsKey('startTime') ? DateFormat('h:mm a').format((data['startTime'] as Timestamp).toDate()) : '              ',
            'end': data != null && data.containsKey('endTime') ? DateFormat('h:mm a').format((data['endTime'] as Timestamp).toDate()) : '              ',
            };
          }).toList();

          setState(() {
            _timeRecords = fetchedRecords;
          });
        }        
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error retrieving timer logs: $e');
    }
  }

  Future<int> retrieveInitialCounterProgress(String activityID) async {
    try {
      if (currentUser != null) {
        DocumentSnapshot ds = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(activityID)
            .get();

        if (ds.exists) {
          int hour = int.parse(ds['hour']);
          int minute = int.parse(ds['minute']);
          int initialCounterProgress = (hour * 3600) + (minute * 60);

          return initialCounterProgress;
        } else {
          print('initialCounterProgress does not exist');
          return 0;
        }
      } else {
        print('User not logged in');
        return 0;
      }
    } catch (e) {
      print('Error retrieving timer logs: $e');
      return 0;
    }
  }

  Future<void> _startTimer() async {
    print('Starting timer...');
    try {
      if (currentUser != null) {
        // check timerLogDetails exist
        QuerySnapshot timerLogsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(widget.activityID)
            .collection('timerLogs')
            .orderBy('startTime', descending: true)
            .limit(1)
            .get();

        if (timerLogsSnapshot.docs.isEmpty) {
          // timerLogDetails null

          setState(() {
            _isPaused = false; // resume timer
            _startTime = DateTime.now(); 
          });

          Map<String, dynamic> timerLogInfoMap = {
            'activityID': widget.activityID,
            'startTime': _startTime,
            'timerLogID': _timerLogID,
          };

          // add new timerLogID with its new timerLogDetails
          int timerLogCount = await DatabaseMethods().getTimerLogCount(currentUser!, widget.activityID) + 1;
          _timerLogID = "T${timerLogCount.toString().padLeft(4, '0')}";

          await DatabaseMethods().addTimerLogDetails(currentUser!, widget.activityID, timerLogInfoMap).then((value) {
            print('Timer log details (timerLogID and startTime) added successfully');
          }).catchError((error) {
            print('Error adding timer log details (timerLogID and startTime): $error');
          });          

          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              if (_counter > 0) {
                _counter--;
                print('Timer running: $_counter seconds left');
              } else { // if _counter is 0
                _timer!.cancel();
                _showCompletionDialog();
                print('Timer completed');
              }
            });
          });          
        } else { // timerLogsSnapshot.docs.isNotEmpty          
          // timerLogDetails exist
          _pauseTimer();
        }         
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error starting timer: $e');
    }
  } 

  Future<void> _pauseTimer() async {
    print('Pausing timer...');
    try{
      if (currentUser != null){
        _timer!.cancel();
        _endTime = DateTime.now();

        setState(() {
          _isPaused = true; // Pause the timer
        });      

        DocumentSnapshot ds = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .doc(widget.activityID)
          .get();

        int hour = int.parse(ds['hour']);
        int minute = int.parse(ds['minute']);

        int playDuration = ((hour * 3600) + (minute * 60)) - _counter;

        Map<String, dynamic> timerLogInfoMap = {
          'playDuration': FieldValue.increment(playDuration),
          'endTime': _endTime,
        };          

        // check latest timerLogID
        QuerySnapshot latestLogSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(widget.activityID)
            .collection('timerLogs')
            .orderBy('startTime', descending: true)
            .limit(1)
            .get(); 

        DocumentSnapshot latestLog = latestLogSnapshot.docs.first;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(widget.activityID)
            .collection('timerLogs')
            .doc(latestLog.id)
            .update(timerLogInfoMap);        
   
        print('in pauseTimer, Timer log updated: playDuration: $playDuration, endTime: $_endTime');  

        // update fetched records
        retrieveTimerLogs(widget.activityID);

      } else {
        print('User not logged in');
      }


    } catch (e) {
      print('Error pausing timer: $e');
    }
  }


  void _resumeTimer() async {
    print('Resuming timer...');
    try {
      if (currentUser != null) {
        // check timerLogDetails exist
        QuerySnapshot timerLogsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('activities')
            .doc(widget.activityID)
            .collection('timerLogs')
            .orderBy('startTime', descending: true)
            .limit(1)
            .get();

        if (timerLogsSnapshot.docs.isNotEmpty) {
          // timerLogDetails exist

          setState(() {
            _isPaused = false; // resume timer
            _startTime = DateTime.now(); 
          });

          Map<String, dynamic> timerLogInfoMap = {
            'activityID': widget.activityID,
            'startTime': _startTime,
            'timerLogID': _timerLogID,
          };

          // check latest timerLogID
          int timerLogCount = await DatabaseMethods().getTimerLogCount(currentUser!, widget.activityID) + 1;
          _timerLogID = "T${timerLogCount.toString().padLeft(4, '0')}";
          print('in resumeTimer, Timer log ID created: $_timerLogID');
          
          await DatabaseMethods().addTimerLogDetails(currentUser!, widget.activityID, timerLogInfoMap).then((value) {
            print('in resumeTimer, Timer log details (timerLogID and startTime) added successfully');
          }).catchError((error) {
            print('in resumeTimer, Error adding timer log details (timerLogID and startTime): $error');
          });

          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              if (_counter > 0) {
                _counter--;
                print('Timer running: $_counter seconds left');
              } else { // if _counter is 0
                _timer!.cancel();
                _showCompletionDialog();
                print('Timer completed');
              }
            });
          });                    

        } else { // timerLogsSnapshot.docs.isEmpty          
          // timerLogDetails is null
          _startTimer();
        }         
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error resuming timer: $e');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,                      
                child: IconButton(
                  icon: Icon(Icons.close, size: 30),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, Routes.activity);
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "TIME'S UP!",
                      style: TextStyle(fontSize: 30, fontFamily: 'InterSemiBold', color: Colors.blue),
                    ),
                    const SizedBox(height: 9),
                    const Icon(Icons.timer, size: 50, color: Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),                    
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
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Timer Activity',
          style: TextStyle(fontFamily: 'InterBold',),
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
                    child: FutureBuilder<int>(
                      future: retrieveInitialCounterProgress(widget.activityID),
                      builder: (context, snapshot) {
                          int initialCounterProgress = snapshot.data ?? 0;
                          return CircularProgressIndicator(                        
                            value: initialCounterProgress > 0 ? _counter / initialCounterProgress : 1.0, // 1.0 is the default value if initialCounterProgress is 0
                            strokeWidth: 10,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                            backgroundColor: Colors.white,
                          );      
                      },
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
                      Text('Play Duration', style: TextStyle(fontFamily: 'InterSemiBold',)),
                      Text('Start Time', style: TextStyle(fontFamily: 'InterSemiBold',)),
                      Text('End Time', style: TextStyle(fontFamily: 'InterSemiBold',)),
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
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Timer Activity'),
        ),
        body: Center(
          child: Text('Please log in to start a timer.'),
        ),
      );
    }
  }
}