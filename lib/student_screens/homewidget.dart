import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homewidget extends StatefulWidget {
  const Homewidget({super.key});

  @override
  State<Homewidget> createState() => _HomewidgetState();
}

class _HomewidgetState extends State<Homewidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  Map<String, dynamic>? studentDetails;
  bool _isLoading = true;
  List<String> announcements = [
    "Welcome to the new semester!",
    "Exam schedule released",
    "Holiday on Friday"
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot studentDoc = await _firestore
          .collection('registeredStudents')
          .doc(currentUser.uid)
          .get();

      if (studentDoc.exists) {
        setState(() {
          studentDetails = studentDoc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          studentDetails = null;
          _isLoading = false;
        });
      }
    }
  }

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Display announcements if available
            if (announcements.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: announcements.map((announcement) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.lightBlue.shade50,
                      child: ListTile(
                        leading: Icon(Icons.announcement, color: Colors.blue),
                        title: Text(
                          announcement,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              Center(
                child: Text(
                  'No announcements available',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),

            // Display Student Details if available
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : studentDetails != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Student Profile",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Divider(color: Colors.grey.shade400),
                                _buildDetailTile(
                                    Icons.assignment_ind,
                                    "Roll Number",
                                    studentDetails!['rollNumber']),
                                _buildDetailTile(
                                    Icons.person,
                                    "Name",
                                    studentDetails!['firstname'] +
                                        studentDetails!['lastname']),
                                _buildDetailTile(Icons.phone, "Phone",
                                    studentDetails!['phone']),
                                _buildDetailTile(Icons.email, "Email",
                                    studentDetails!['email']),
                                _buildDetailTile(Icons.cake, "Date of Birth",
                                    studentDetails!['dateOfBirth']),
                                _buildDetailTile(
                                    Icons.book,
                                    "Registered Course",
                                    studentDetails!['registeredCourse']),
                                _buildDetailTile(
                                    Icons.class_,
                                    "Registered Section",
                                    studentDetails!['registeredSection']),
                                _buildDetailTile(
                                    Icons.calendar_today,
                                    "Registered Year",
                                    studentDetails!['registeredYear']),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          'No student details available',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),

            // Selected Tab Display
          ],
        ),
      ),
    );
  }

  // Helper function to create a ListTile for each detail
  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(value, style: TextStyle(color: Colors.black87)),
        dense: true,
      ),
    );
  }
}
