import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_management_system/backend/adminService.dart';

class RegisteredStudentsPage extends StatefulWidget {
  @override
  _RegisteredStudentsPageState createState() => _RegisteredStudentsPageState();
}

class _RegisteredStudentsPageState extends State<RegisteredStudentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AdminApprovalService admin = AdminApprovalService();
  final TextEditingController _searchController = TextEditingController();
  List<String> _courses = ['All'];
  List<String> _years = ['All'];
  List<String> _sections = ['All'];
  String? _selectedCourse = 'All';
  String? _selectedYear = 'All';
  String? _selectedSection = 'All';
  String _searchQuery = '';

  // Store the fetched students list here
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch students and store them in the list
  Future<void> _fetchStudents() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('registeredStudents').get();
      List<Map<String, dynamic>> s = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {
        students = s;
      });

      // Find unique values for the dropdowns
      List<String> courses = ['All'];
      List<String> years = ['All'];
      List<String> sections = ['All'];
      for (var student in students) {
        final courseId = student['registeredCourse'];
        final year = student['registeredYear'];
        final section = student['registeredSection'];
        if (courseId != null && !courses.contains(courseId)) {
          courses.add(courseId);
        }
        if (year != null && !years.contains(year)) {
          years.add(year);
        }
        if (section != null && !sections.contains(section)) {
          sections.add(section);
        }
      }
      setState(() {
        _courses = courses;
        _years = years;
        _sections = sections;
      });
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registered Students"),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by roll number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Filters Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDropdown(
                  hint: 'Course',
                  value: _selectedCourse,
                  items: _courses,
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                    });
                  },
                ),
                _buildDropdown(
                  hint: 'Year',
                  value: _selectedYear,
                  items: _years,
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
                _buildDropdown(
                  hint: 'Section',
                  value: _selectedSection,
                  items: _sections,
                  onChanged: (value) {
                    setState(() {
                      _selectedSection = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildFilteredStudentsList(),
          ),
        ],
      ),
    );
  }

  // Generate the filtered and sorted list of students
  Widget _buildFilteredStudentsList() {
    var filteredStudents = students;

    // Apply search filter by roll number
    if (_searchQuery.isNotEmpty) {
      filteredStudents = filteredStudents
          .where((student) => student['rollNumber']
              .toString()
              .toLowerCase()
              .contains(_searchQuery))
          .toList();
    }

    // Apply filters based on course, year, and section
    if (_selectedCourse != 'All') {
      filteredStudents = filteredStudents
          .where((student) => student['registeredCourse'] == _selectedCourse)
          .toList();
    }
    if (_selectedYear != 'All') {
      filteredStudents = filteredStudents
          .where((student) => student['registeredYear'] == _selectedYear)
          .toList();
    }
    if (_selectedSection != 'All') {
      filteredStudents = filteredStudents
          .where((student) => student['registeredSection'] == _selectedSection)
          .toList();
    }

    // Sort students by roll number
    filteredStudents
        .sort((a, b) => a['rollNumber'].toString().compareTo(b['rollNumber']));

    // Create a list of widgets for the filtered and sorted students
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Roll Number")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Course")),
          DataColumn(label: Text("Year")),
          DataColumn(label: Text("Section")),
          DataColumn(label: Text("Contact Number")),
          DataColumn(label: Text("Email Id")),
          DataColumn(label: Text("Actions")),
        ],
        rows: filteredStudents.map((studentData) {
          return DataRow(
            cells: [
              DataCell(Text(studentData['rollNumber'] ?? 'N/A')),
              DataCell(Text(
                  "${studentData['firstname']} ${studentData['lastname']}")),
              DataCell(Text(studentData['registeredCourse'] ?? 'N/A')),
              DataCell(Text(studentData['registeredYear'] ?? 'N/A')),
              DataCell(Text(studentData['registeredSection'] ?? 'N/A')),
              DataCell(Text(studentData['phone'] ?? 'N/A')),
              DataCell(Text(studentData['email'] ?? 'N/A')),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmDelete(context, studentData['rollNumber']),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButton<String>(
      hint: Text(hint),
      value: value,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _confirmDelete(BuildContext context, String rollNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this student?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Call delete function here
                // await admin.deleteRegisteredStudent(rollNumber);
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
