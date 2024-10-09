import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/routes.dart';

class HomeScreen extends StatefulWidget {  
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {  
  int _currentIndex = 0;

  // display ongoing activity test 2
  // void _showBottomSheet(BuildContext context) {
  //   showBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: const EdgeInsets.all(16),
  //         width: double.infinity,
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [Color(0xFFC0B5FF), Color(0xFFDAD5FC), Colors.white],
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //           ),
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(20),
  //             topRight: Radius.circular(20),
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black26,
  //               blurRadius: 7,
  //               offset: Offset(0, 3), // changes position of shadow
  //             ),
  //           ],
  //         ),
  //         child: const Column(
  //           crossAxisAlignment: CrossAxisAlignment.start, 
  //           children: [
  //             Text(
  //               'Continue',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Text(
  //                   'activitynamehere',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Icon(
  //                   Icons.arrow_forward_rounded,
  //                   color: Colors.black,
  //                   size: 40,
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Image(
              image: AssetImage('assets/profile.png'),
              width: 40,
              height: 40,
            ),
            const Text(
              'Wellbee',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                //Navigator.pushNamed(context, Routes.);
              },
            ),
          ],
        ),
      ),
      body: Container(        
        margin: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            // display greetings
            const Column(              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    'Hello, addusernamehere!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
    
                  Text(
                    'What are you planning to do today?',
                    style: TextStyle(
                      fontSize: 16,                      
                    ),
                  ),
              ],
            ),

            //display date and time
            const SizedBox(height: 20),
            Container(                                  
              padding: const EdgeInsets.all(16),
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //display current date
                  Text(                                     
                    DateFormat('dd MMM yyyy').format(DateTime.now()), 
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ), 
                   
                  //display current time                   
                  Row(
                    children: [
                      Text(                    
                        DateFormat('h:mm').format(DateTime.now()), 
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(                    
                        DateFormat('a').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //display features
            const SizedBox(height: 40),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),          
                  
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //button Track Activity                      
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              //Navigator.pushNamed(context, Routes.activity);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),                           
                              width: 115,
                              height: 120,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(             
                                      Icons.task_rounded,
                                      color: Color(0xFF378DF9),
                                      size: 40,
                                    ),
                                  ),
                                  Text('Track Activity'),                                 
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      //button Track Daily Goal
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              //Navigator.pushNamed(context, Routes. );
                            },
                            child: Container( 
                              padding: const EdgeInsets.all(10),                           
                              width: 115,
                              height: 120,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.track_changes_rounded,
                                      color: Color(0xFF378DF9),
                                      size: 40,
                                    ),
                                  ),
                                  Text('Track Daily Goal'),                                 
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      //button Report Stress Level                      
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              //Navigator.pushNamed(context, Routes. );
                            },
                            child: Container(  
                              padding: const EdgeInsets.all(10),                           
                              width: 115,
                              height: 120,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.sentiment_satisfied_alt,
                                      color: Color(0xFF378DF9),
                                      size: 40,
                                    ),
                                  ),
                                  Text('Report Stress Level'),                                 
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),                                        
                ],
              )
            ),

           //display ongoing activity test 1
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Container(              
            //     //margin: const EdgeInsets.all(20),
            //     padding: const EdgeInsets.all(16),
            //     width: double.infinity,
            //     decoration: const BoxDecoration(
            //       //color: Color(0xFFC0B5FF),
            //       gradient: LinearGradient(
            //         colors: [Color(0xFFC0B5FF), Color(0xFFDAD5FC), Colors.white],
            //         begin: Alignment.centerLeft,
            //         end: Alignment.centerRight,
            //       ),                                           
            //       borderRadius: BorderRadius.only(                  
            //         topLeft: Radius.circular(20),
            //         topRight: Radius.circular(20),
            //       ),                 
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black26,                      
            //           blurRadius: 7,
            //           offset: Offset(0, 3), // changes position of shadow
            //         ),
            //       ],
                
            //     ),            
            //     child: const Column(
            //       crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
            //       children: [
            //         Text(                                     
            //           'Continue',
            //           style: TextStyle(
            //             fontSize: 16,                      
            //             color: Colors.white
            //           ),
            //         ),                     
            //         Row(                      
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text(                    
            //               'activitynamehere',
            //               style: TextStyle(
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold
            //               ),
            //             ),
            //             Icon(
            //               Icons.arrow_forward_rounded,
            //               color: Colors.black,
            //               size: 40
            //             ),                        
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ), 
            
           // display ongoing activity test 3       
          //   ElevatedButton(
          //   child: const Text('showBottomSheet'),
          //   onPressed: () {
          //     showBottomSheet(
          //       context: context,
          //       //sheetAnimationStyle: _animationStyle,
          //       builder: (BuildContext context) {
          //         return Container(
          //           height: 120, // Set the desired height here
          //           width: 300,
          //           color: Colors.purple, // Optional: set a background color
          //           //child: Center(
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceAround,
          //               mainAxisSize: MainAxisSize.min,
          //               children: <Widget>[
          //                 const Text('Bottom sheet'),
          //                 ElevatedButton(
          //                   child: const Text('Close'),
          //                   onPressed: () => Navigator.pop(context),
          //                 ),
          //               ],
          //             ),
          //           //),
          //         );
          //       },
          //     );
          //   },
          // ),

          // display ongoing activity test 2 
          // to be removed after testing
            // const SizedBox(height: 20),              
            // ElevatedButton(
            //   onPressed: () => _showBottomSheet(context),
            //   child: const Text('Show Bottom Sheet'),              
            // ),
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
              // Navigator.pushNamed(context, Routes.home);
              break;
            case 1:
              //Navigator.pushNamed(context, Routes.activity);
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