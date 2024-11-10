import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_management_system/admin_screens/RegistrationRequests.dart';
import 'package:student_management_system/admin_screens/add_course.dart';
import 'package:student_management_system/admin_screens/manage_courses.dart';
import 'package:student_management_system/admin_screens/registeredStudentsPage.dart';
import 'package:student_management_system/backend/adminService.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Panel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Overview",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: loadDashboardData, icon: Icon(Icons.refresh))
              ],
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildOverviewCard("Total Students", "$totalStudents"),
                  _buildOverviewCard("Total Courses", "$totalCourses"),
                  _buildOverviewCard("Pending Requests", "$pendingRequests"),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Quick Actions
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildActionCard("Add Course", Icons.add),
              ],
            ),
            SizedBox(height: 20),
            // Courses Management Card
            _buildSectionTitle("Courses Management"),
            _buildCard(
                "Manage Courses",
                "Overview of all courses with options to add, edit, or delete.",
                ManageCoursesPage()),

            // Registration Requests Card
            _buildSectionTitle("Student Registration Requests"),
            _buildCard(
                "Pending Registration Requests",
                "Approve or reject student registrations.",
                AdminPendingRequestsPage()),
            _buildSectionTitle("Student Registration Requests"),
            _buildCard("Registered Students", "Check the registered students.",
                RegisteredStudentsPage()),
          ],
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
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => AddCoursePage()));
      },
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

  Widget _buildCard(String title, String description, Widget Screen) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => Screen));
        },
      ),
    );
  }
}
