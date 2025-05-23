import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellbeeapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityScreen extends StatefulWidget {  
  const ActivityScreen({Key? key}) : super(key: key);
  
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

enum MenuItem { edit, delete }

class _ActivityScreenState extends State<ActivityScreen> {  
  int _currentIndex = 1;
  Stream? activityStream;

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  getontheload()async{ 
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      activityStream = await DatabaseMethods().getActivityDetails(currentUser); // Pass currentUser as argument
      setState(() {});
    }
  }

  Widget showActivitiesList(){
    return StreamBuilder(stream: activityStream, builder:(context, AsyncSnapshot snapshots){
      return snapshots.hasData? ListView.builder( // if there is data in the collection of activities
        padding: const EdgeInsets.only(bottom: 150.0),       
        scrollDirection: Axis.vertical,
        itemCount: snapshots.data.docs.length, itemBuilder: (BuildContext context, int index) { // get number of documents in the collection of activities
          DocumentSnapshot ds = snapshots.data.docs[index]; 
          String activityID = ds.id;
                   
          return Container(
            margin: const EdgeInsets.all(20.0),        
            
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ds["activityName"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'InterSemiBold',
                              ),
                            ),

                            // popup menu for edit and delete                            
                            PopupMenuButton<MenuItem>(
                              onSelected: (MenuItem item) async {
                                switch (item) {
                                  case MenuItem.edit:                                                                     
                                    Navigator.pushNamed(
                                      context,
                                      Routes.editActivity,
                                      arguments: ds,
                                    );
                                    break;
                                  case MenuItem.delete:
                                    _showDeleteConfirmationDialog(context, activityID);

                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                                const PopupMenuItem<MenuItem>(
                                  value: MenuItem.edit,
                                  child: Text('Edit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'InterSemiBold',
                                  )),
                                ),
                                const PopupMenuItem<MenuItem>(
                                  value: MenuItem.delete,
                                  child: Text('Delete',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'InterSemiBold',
                                  )),
                                ),
                              ],
                            ),                            
                          ],
                        ),
                        Container(                          
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration:BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(                            
                            ds["categoryName"],
                            style: const TextStyle(
                              fontSize: 16,     
                              color: Colors.white,
                              fontFamily: 'Inter',                       
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(                                                   
                          DateFormat('d MMM yyyy').format(DateTime.parse(ds["date"])),                                                
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter', 
                          ),                    
                        ),                 
                        Row(
                          children: [
                            Text(
                              ds["hour"],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter', 
                              ),                    
                            ),
                            const Text(
                              ' hrs',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter', 
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ds["minute"],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter', 
                              ),                    
                            ),
                            const Text(
                              ' mins',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter', 
                              ),
                            ),
                            
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          onPressed: () {
                            // Debugging prints
                            print('Document ID: ${ds.id}');
                            print('Document Data: ${ds.data()}');
                           
                            Navigator.pushNamed(
                              context,
                              Routes.timerActivity,                              
                              arguments: ds.id,
                            );
                          },
                        ),
                      ),
                    ),                  
                  ],
                )
              ),
            // ),
          );
        }, 
      ): Container();
      }
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [            
            Text(
              'Activities',
              style: TextStyle(
              fontFamily: 'InterBold',
              ),
            ),            
          ],
        ),
      ),    

      body: showActivitiesList(),        
 
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {            
              Navigator.pushNamed(context, Routes.analyticsActivity);     
            },         
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: const Icon(Icons.bar_chart, size: 40),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {              
              Navigator.pushNamed(context, Routes.addActivity);      
            },         
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 40),
          ),
        ],
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

  void _showDeleteConfirmationDialog(BuildContext context, String activityID) {
    User? currentUser = FirebaseAuth.instance.currentUser; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.black,
                size: 40
              ),
              SizedBox(height: 10),
              Text(
                'Are you sure?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This will delete the activity permanently.', 
              style: TextStyle(color: Colors.black,
              fontFamily: 'Inter',)),
              SizedBox(height: 2),
              Text('You cannot undo this action.',
              style: TextStyle(color: Colors.black,
              fontFamily: 'Inter',)),
            ],
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.values[5],
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                      const Text('Cancel',style: TextStyle(color: Colors.black, fontFamily: 'InterSemiBold')),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        if (currentUser != null) {
                          await DatabaseMethods().deleteActivity(currentUser, activityID); // delete from database
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Activity deleted', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.pop(context); // Close the dialog
                          Navigator.pushReplacementNamed(context, Routes.activity); // Redirect to home screen
                        } else {
                          throw Exception('User not logged in');
                        }                       
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete activity: $e', style: const TextStyle(color: Colors.white, fontFamily: 'Inter')),
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      side: const BorderSide(color: Colors.black),
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Delete', style: TextStyle(color: Colors.white, fontFamily: 'InterSemiBold')),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}