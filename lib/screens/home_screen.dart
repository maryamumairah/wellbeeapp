import 'package:flutter/material.dart';
import 'package:wellbeeapp/routes.dart';

class HomeScreen extends StatefulWidget {  
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {  
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {                
              },
            ),
            const Text('Wellbee'),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                //Navigator.pushNamed(context, Routes.);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [        
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hello, addusernamehere!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What are you planning to do today?',
                    style: TextStyle(
                      fontSize: 15,                      
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFFFED072),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'adddate and timehere',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),            
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.checklist,
                            color: Color(0xFF378DF9),
                            size: 30,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Track Activity'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), // Add border radius here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.flag,
                            color: Color(0xFF378DF9),
                            size: 30,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Track Daily Goal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), // Add border radius here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.sentiment_satisfied_alt,
                            color: Color(0xFF378DF9),
                            size: 30,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Report Stress Level'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Color(0xFF378DF9),
        selectedItemColor: Theme.of(context).colorScheme.secondary,
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
              //Navigator.pushNamed(context, Routes.);
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Goals',
          ),
                    BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Stress',
          ),
        ],
        
      ),
    );
  }
}