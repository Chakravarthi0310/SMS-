import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_management_system/backend/authentication.dart';
import 'package:student_management_system/student_screens/homewidget.dart';
import 'package:student_management_system/student_screens/loginPage.dart';
import 'package:student_management_system/student_screens/profilePage.dart';
import 'package:student_management_system/student_screens/registerforCourse.dart';
import 'package:student_management_system/student_screens/registrationStatus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Global key for Scaffold

  List<String> announcements = [
    "Welcome to the new semester!",
    "Exam schedule released",
    "Holiday on Friday"
  ];

  List<Widget> screens = [
    Homewidget(),
    RegisterCoursePage(),
    RegistrationStatusPage()
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onRegisterCourse() {
    setState(() {
      _selectedIndex = 1;
    });
    print('Navigate to course registration screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Open the drawer using the key
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => ProfilePage()));
            },
          ),
        ],
        title: const Text("Home"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              child: Text('Navigation'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Register for Course'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _onRegisterCourse();
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _auth.signOut();
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subject),
            label: 'Course\nRegistration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Registration Status',
          ),
        ],
      ),
    );
  }
}
