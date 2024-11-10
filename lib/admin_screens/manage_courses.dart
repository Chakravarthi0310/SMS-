import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_management_system/backend/adminService.dart';
import 'package:student_management_system/backend/authentication.dart';

class ManageCoursesPage extends StatefulWidget {
  const ManageCoursesPage({super.key});

  @override
  _ManageCoursesPageState createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> {
  final AdminService admin = AdminService();
  List<Map<String, dynamic>> _coursesList = [];
  List<Widget> courseCards = [];
  List<Map<String, dynamic>> _filteredCoursesList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _searchController.addListener(_filterCourses);
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true; // Set to true to show loading indicator
    });
    List<Map<String, dynamic>> courses = await admin.getCoursesWithDetails();
    setState(() {
      _coursesList = courses;
      _filteredCoursesList = courses; // Initially show all courses
      _isLoading = false;
    });
  }

  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCoursesList = _coursesList.where((course) {
        return course['courseName'].toLowerCase().contains(query) ||
            course['courseCode'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCourses);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Courses"),
        actions: [
          IconButton(
              onPressed: () {
                _fetchCourses();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Courses',
                hintText: 'Enter course name or code',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator()) // Show loading widget
                : ListView(
                    padding: const EdgeInsets.only(
                        top: 80, left: 10, right: 10, bottom: 10),
                    children: _filteredCoursesList.map((course) {
                      return CourseCard(
                        courseName: course['courseName'],
                        courseCode: course['courseCode'],
                        duration: course['duration'],
                        description: course['description'],
                        academicYears: course['academicYears'],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// Course Card Widget with expandable feature to show Academic Years
class CourseCard extends StatefulWidget {
  final String courseName;
  final String courseCode;
  final int duration;
  final String description;
  final List<Map<String, dynamic>>
      academicYears; // Add academicYears as a parameter

  const CourseCard({
    required this.courseName,
    required this.courseCode,
    required this.duration,
    required this.description,
    required this.academicYears, // Add academicYears parameter
  });

  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.courseName),
            subtitle: Text(
                "Code: ${widget.courseCode} | Duration: ${widget.duration} years"),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            AcademicYearPanel(
              academicYears: widget.academicYears,
              courseCode:
                  widget.courseCode, // Pass the academicYears to the panel
            ),
        ],
      ),
    );
  }
}

// Widget for managing Academic Years and Sections
class AcademicYearPanel extends StatefulWidget {
  final List<Map<String, dynamic>> academicYears;
  final String courseCode;

  const AcademicYearPanel(
      {required this.academicYears, required this.courseCode});

  @override
  _AcademicYearPanelState createState() => _AcademicYearPanelState();
}

class _AcademicYearPanelState extends State<AcademicYearPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.academicYears.map((year) {
        return ExpansionTile(
          title: Text("Academic ${year['year']}"), // Display the academic year
          children: [
            SectionList(
              sections: List<Map<String, dynamic>>.from(
                  year['sections']), // Pass sections as a List<String>
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextButton.icon(
                  onPressed: () => _addSectionDialog(context, year['year']),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Section"),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Dialog to add a new section
  Future<void> _addSectionDialog(BuildContext context, String year) async {
    final TextEditingController sectionController = TextEditingController();
    final AdminService admin = AdminService();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Section"),
          content: TextField(
            controller: sectionController,
            decoration: const InputDecoration(hintText: "Enter section name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await admin.addSectionToAcademicYear(
                      courseCode: widget.courseCode,
                      year: year,
                      sectionName: sectionController.text.trim());
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "added successfully");
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: "An error occured while adding section $e");
                }
                setState(() {
                  // Add code here to handle adding a section
                  widget.academicYears
                      .firstWhere(
                          (element) => element['year'] == year)['sections']
                      .add(sectionController.text);
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

class SectionList extends StatelessWidget {
  final List<Map<String, dynamic>> sections;

  const SectionList({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sections
          .map((section) => ListTile(
                title: Text("Section ${section['sectionName']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_circle_right),
                      onPressed: () =>
                          _deleteSection(section['sectionName'], context),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // Dialog to edit an existing section
  Future<void> _editSectionDialog(BuildContext context, String section) async {
    final TextEditingController sectionController =
        TextEditingController(text: section);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Section"),
          content: TextField(
            controller: sectionController,
            decoration:
                const InputDecoration(hintText: "Enter new section name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Code to edit section
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a section with confirmation
  void _deleteSection(String section, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Section"),
          content: Text("Are you sure you want to delete $section?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Code to delete section
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
