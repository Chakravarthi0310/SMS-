import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_management_system/admin_screens/admin_dashboard.dart';
import 'package:student_management_system/backend/adminService.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController courseDescriptionController = TextEditingController();

  int? courseDuration;
  bool isLoading = false;

  final AdminService admin = AdminService();

  void _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      // Save the course to Firestore
      try {
        await admin.addCourse(
          courseNameController.text,
          courseCodeController.text,
          courseDuration!,
          courseDescriptionController.text,
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => AdminDashboard()));
      } catch (e) {
        Fluttertoast.showToast(msg: "An error occurred: $e");
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  void dispose() {
    courseNameController.dispose();
    courseCodeController.dispose();
    courseDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Course"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Course Name Field
              TextFormField(
                controller: courseNameController,
                decoration: const InputDecoration(
                  labelText: "Course Name",
                  hintText: "e.g., B Tech, MBA, BBA, Psychology",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Course Code Field
              TextFormField(
                controller: courseCodeController,
                decoration: const InputDecoration(
                  labelText: "Course Code",
                  hintText: "e.g., BT101, MBA202",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Course Duration Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Course Duration (Years)",
                ),
                value: courseDuration,
                items: [1, 2, 3, 4].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value Year${value > 1 ? 's' : ''}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    courseDuration = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select the course duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Course Description Field
              TextFormField(
                controller: courseDescriptionController,
                decoration: const InputDecoration(
                  labelText: "Course Description",
                  hintText: "Briefly describe the course",
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 10) {
                    return 'Course description should be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: isLoading ? null : _saveCourse,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
