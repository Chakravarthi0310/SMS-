import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_management_system/backend/adminService.dart';

class AdminPendingRequestsPage extends StatefulWidget {
  const AdminPendingRequestsPage({Key? key}) : super(key: key);

  @override
  _AdminPendingRequestsPageState createState() =>
      _AdminPendingRequestsPageState();
}

class _AdminPendingRequestsPageState extends State<AdminPendingRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AdminApprovalService admin = AdminApprovalService();

  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  List<String> _sections = ['All'];
  List<String> _years = ['All'];
  String _searchText = '';
  String _selectedSection = 'All';
  String _selectedYear = 'All';
  bool is_loading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
    _fetchUniqueValues();
  }

  // Fetch pending requests from Firestore
  Future<void> _fetchPendingRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('registrationRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      setState(() {
        _pendingRequests = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _filteredRequests =
            List.from(_pendingRequests); // Initialize filtered requests
      });
    } catch (e) {
      print("Error fetching pending requests: $e");
    }
  }

  // Fetch unique sections and years for dropdown filters
  Future<void> _fetchUniqueValues() async {
    try {
      QuerySnapshot sectionSnapshot = await _firestore
          .collection('registrationRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      List<String> sections = ['All'];
      List<String> years = ['All'];

      for (var doc in sectionSnapshot.docs) {
        final section = doc['section'];
        final year = doc['academicYear'];
        if (section != null && !sections.contains(section)) {
          sections.add(section);
        }
        if (year != null && !years.contains(year)) {
          years.add(year);
        }
      }

      setState(() {
        _sections = sections;
        _years = years;
      });
    } catch (e) {
      print("Error fetching unique values: $e");
    }
  }

  // Approve request handler
  Future<void> _approveRequest(String requestId) async {
    setState(() {
      is_loading = true;
    });
    try {
      await admin.approveRegistrationRequest(_auth.currentUser!.uid);
      Fluttertoast.showToast(msg: "Accepted successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occured $e");
    }
    setState(() {
      is_loading = false;
    });
    // Call your approveRegistrationRequest function here
  }

  // Reject request handler
  Future<void> _rejectRequest(String requestId) async {
    // Call your rejectRegistrationRequest function here
    setState(() {
      is_loading = true;
    });
    try {
      await admin.approveRegistrationRequest(_auth.currentUser!.uid);
      Fluttertoast.showToast(msg: "rejected successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occured $e");
    }
    setState(() {
      is_loading = false;
    });
    // Call
  }

  // Filter requests based on search text, section, and year
  void _filterRequests() {
    setState(() {
      _filteredRequests = _pendingRequests.where((request) {
        final matchesSearch = request['studentId']
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            request['courseId']
                .toLowerCase()
                .contains(_searchText.toLowerCase());
        final matchesSection =
            _selectedSection == 'All' || request['section'] == _selectedSection;
        final matchesYear =
            _selectedYear == 'All' || request['academicYear'] == _selectedYear;
        return matchesSearch && matchesSection && matchesYear;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Registration Requests"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchPendingRequests();
              _fetchUniqueValues();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Pending Requests: ${_filteredRequests.length}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Search TextField
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search by Student ID or Course',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _searchText = value;
                          _filterRequests();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Section Dropdown Filter
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Section',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSection,
                        items: _sections
                            .map((section) => DropdownMenuItem(
                                  value: section,
                                  child: Text(section),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSection = value!;
                            _filterRequests();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Year Dropdown Filter
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Year',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedYear,
                        items: _years
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                            _filterRequests();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student ID')),
                        DataColumn(label: Text('Course')),
                        DataColumn(label: Text('Academic\nYear')),
                        DataColumn(label: Text('Section')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredRequests.map((request) {
                        return DataRow(cells: [
                          DataCell(Text(request['studentId'] ?? '')),
                          DataCell(Text(request['courseId'] ?? '')),
                          DataCell(Text(request['academicYear'] ?? '')),
                          DataCell(Text(request['section'] ?? '')),
                          DataCell(
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _approveRequest(request['studentId']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    minimumSize: Size(50, 30),
                                  ),
                                  child: const Text("Approve",
                                      style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () =>
                                      _rejectRequest(request['studentId']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: Size(50, 30),
                                  ),
                                  child: const Text("Reject",
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (is_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
