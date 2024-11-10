import 'package:flutter/material.dart';
import 'package:student_management_system/admin_screens/admin_login.dart';
import 'package:student_management_system/admin_screens/dash_board.dart';
import 'package:student_management_system/admin_screens/manage_courses.dart';
import 'package:student_management_system/backend/adminService.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final AdminService _dashboardService = AdminService();
  int totalStudents = 0;
  int totalCourses = 0;
  int pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    totalStudents = await _dashboardService.getTotalStudents();
    totalCourses = await _dashboardService.getTotalCourses();
    pendingRequests = await _dashboardService.getPendingRequests();
    setState(() {}); // Update UI
  }

  final List<Widget> _pages = [
    DashBoard(), // Dashboard page
    ManageCoursesPage(), // Replace with your Courses Management widget
    Text(
        "Registration Requests Page"), // Replace with your Registration Requests widget
    Text("Settings Page"), // Replace with your Settings widget
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Show profile details and options
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Admin Menu",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              title: Text("Dashboard"),
              onTap: () {
                _onItemTapped(0);
              },
            ),
            ListTile(
              title: Text("Logout"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => AdminLoginPage()));
              },
            ),
            ListTile(
              title: Text("Settings"),
              onTap: () {
                _onItemTapped(3);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      // Footer
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(onPressed: () {}, child: Text("Help Center")),
                TextButton(onPressed: () {}, child: Text("Privacy Policy")),
                TextButton(onPressed: () {}, child: Text("Contact Support")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCard(String title, String description) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
