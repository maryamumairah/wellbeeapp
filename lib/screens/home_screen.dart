import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeeapp/global/common/toast.dart';
import 'package:wellbeeapp/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {  
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {  
  int _currentIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _reloadUser() async {
    user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
  }

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
                Navigator.pushNamed(context, Routes.userProfile).then((_) {
                  setState(() {
                    _reloadUser();
                  });
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print('Signed out');
                  Navigator.pushNamed(context, Routes.login);
                  showToast(message: 'Successfully signed out');
                });
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _reloadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container(        
              margin: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [            
                  // display greetings
                  Column(              
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.displayName ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
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
                          DateFormat('d MMM yyyy').format(DateTime.now()), 
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
                                    Navigator.pushNamed(context, Routes.activity);
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
                ],
              ),   
            );
          }
        },
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