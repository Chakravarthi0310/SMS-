import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationStatusPage extends StatefulWidget {
  @override
  _RegistrationStatusPageState createState() => _RegistrationStatusPageState();
}

class _RegistrationStatusPageState extends State<RegistrationStatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String _registrationStatus = 'No registration found';
  Map<String, dynamic> registrationDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchRegistrationStatus();
  }

  Future<void> _fetchRegistrationStatus() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('students').doc(currentUser.uid).get();

        if (doc.exists) {
          setState(() {
            registrationDetails = doc.data() as Map<String, dynamic>;
            _registrationStatus =
                registrationDetails['status'] ?? 'No status available';
            _isLoading = false;
          });
        } else {
          setState(() {
            _registrationStatus = 'No registration request found';
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching registration status: $e");
        Fluttertoast.showToast(msg: "Error fetching registration status");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Registration Status"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Registration Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Divider(),
                          _buildDetailRow("Course ID",
                              registrationDetails['courseId'] ?? 'N/A'),
                          _buildDetailRow("Academic Year",
                              registrationDetails['year'] ?? 'N/A'),
                          _buildDetailRow("Section",
                              registrationDetails['section'] ?? 'N/A'),
                          _buildDetailRow(
                              "Roll Number",
                              registrationDetails['rollNumber'] ??
                                  'Wait for approval'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        _registrationStatus == 'approved'
                            ? Icons.check_circle
                            : _registrationStatus == 'pending'
                                ? Icons.hourglass_empty
                                : Icons.cancel,
                        color: _registrationStatus == 'approved'
                            ? Colors.green
                            : _registrationStatus == 'pending'
                                ? Colors.orange
                                : Colors.red,
                      ),
                      title: Text(
                        "Status: ${_registrationStatus.capitalize()}",
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        _registrationStatus == 'approved'
                            ? "Your registration has been approved."
                            : _registrationStatus == 'pending'
                                ? "Your registration is pending approval."
                                : "No registration request found.",
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
