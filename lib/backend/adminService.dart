// Admin Course Management Service
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new course
  // Add a new course with additional details
  // Add a new course and automatically create academic years as sub-collections
// Add a new course and automatically create academic years as sub-collections
  Future<void> addCourse(String courseName, String courseCode, int duration,
      String description) async {
    try {
      // Check if a course with the same courseCode already exists
      DocumentReference courseDoc =
          _firestore.collection('courses').doc(courseCode);
      DocumentSnapshot courseSnapshot = await courseDoc.get();

      if (courseSnapshot.exists) {
        Fluttertoast.showToast(
            msg: "Course code $courseCode is already taken.");
        print("Course code $courseCode is already taken.");
        throw Exception("Course code $courseCode is already taken");
      }

      // Course does not exist, proceed with adding the course
      await courseDoc.set({
        'courseCode': courseCode,
        'courseName': courseName,
        'duration': duration, // Duration in years
        'description': description,
        'noOfStudents': 0
      });

      // Automatically create academic years sub-collection based on duration
      for (int i = 1; i <= duration; i++) {
        await courseDoc.collection('academicYears').doc('Year $i').set({
          'year': 'Year $i',
        });
      }

      Fluttertoast.showToast(
          msg: "Course and academic years added successfully.");
      print("Course and academic years added successfully.");
    } catch (e) {
      print("Error adding course: $e");
    }
  }

  // Add section to a specific academic year
  Future<void> addSectionToAcademicYear({
    required String courseCode,
    required String sectionName,
    required String year,
  }) async {
    try {
      // Reference to the specific academic year document
      DocumentReference academicYearRef = _firestore
          .collection('courses')
          .doc(courseCode)
          .collection('academicYears')
          .doc(year);

      // Add a new document for the section with initial details
      await academicYearRef.collection('sections').doc(sectionName).set({
        'sectionName': sectionName,
        'studentCount': 0, // Initializing student count
      });

      print(
          "Section $sectionName added to $year in course $courseCode successfully.");
    } catch (e) {
      print("Error adding section: $e");
    }
  }

  Future<int> getTotalStudents() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('students').get();
      return snapshot
          .size; // Returns the number of documents in 'students' collection
    } catch (e) {
      print("Error getting total students: $e");
      return 0; // Return 0 if there's an error
    }
  }

  Future<int> getTotalCourses() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('courses').get();
      return snapshot
          .size; // Returns the number of documents in 'courses' collection
    } catch (e) {
      print("Error getting total courses: $e");
      return 0; // Return 0 if there's an error
    }
  }

  // Function to get the number of pending registration requests
  Future<int> getPendingRequests() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('registrationRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot
          .size; // Returns the number of documents with 'status' = 'pending'
    } catch (e) {
      print("Error getting pending requests: $e");
      return 0; // Return 0 if there's an error
    }
  }

  Future<List<Map<String, dynamic>>> getCoursesWithDetails() async {
    List<Map<String, dynamic>> coursesList = [];

    try {
      // Fetch all courses from the 'courses' collection
      QuerySnapshot coursesSnapshot =
          await _firestore.collection('courses').get();

      // Loop through each course document
      for (QueryDocumentSnapshot courseDoc in coursesSnapshot.docs) {
        Map<String, dynamic> courseData =
            courseDoc.data() as Map<String, dynamic>;

        // Initialize an empty list to store academic years and their sections
        List<Map<String, dynamic>> academicYearsList = [];

        // Fetch the academic years for the current course from the subcollection
        QuerySnapshot academicYearsSnapshot =
            await courseDoc.reference.collection('academicYears').get();

        for (QueryDocumentSnapshot yearDoc in academicYearsSnapshot.docs) {
          Map<String, dynamic> yearData =
              yearDoc.data() as Map<String, dynamic>;

          // Initialize a list to store sections with details for this academic year
          List<Map<String, dynamic>> sectionsList = [];

          // Fetch the sections from the 'sections' sub-collection within the academic year
          QuerySnapshot sectionsSnapshot =
              await yearDoc.reference.collection('sections').get();

          for (QueryDocumentSnapshot sectionDoc in sectionsSnapshot.docs) {
            Map<String, dynamic> sectionData =
                sectionDoc.data() as Map<String, dynamic>;

            // Add each section with its details
            sectionsList.add({
              'sectionName': sectionData['sectionName'],
              'studentCount': sectionData['studentCount'],
            });
          }

          // Add each academic year with its sections list
          academicYearsList.add({
            'year': yearDoc.id,
            'sections': sectionsList,
          });
        }

        // Add the course details along with academic years to the courses list
        coursesList.add({
          'courseName': courseData['courseName'],
          'courseCode': courseData['courseCode'],
          'duration': courseData['duration'],
          'description': courseData['description'],
          'noOfStudents': courseData['noOfStudents'],
          'academicYears': academicYearsList,
        });
      }
    } catch (e) {
      print("Error fetching courses: $e");
    }

    return coursesList;
  }
}

// Admin Approval Service
class AdminApprovalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Approve registration request and handle registration steps
  Future<void> approveRegistrationRequest(String requestId) async {
    try {
      DocumentReference requestDoc =
          _firestore.collection('registrationRequests').doc(requestId);
      DocumentSnapshot requestSnapshot = await requestDoc.get();

      if (requestSnapshot.exists) {
        // Get the necessary details from the registration request
        String studentId = requestSnapshot['studentId'];
        String courseId = requestSnapshot['courseId'];
        String section = requestSnapshot['section'];
        String year = requestSnapshot['academicYear'];

        // Retrieve the student document to fetch personal details
        DocumentSnapshot studentDoc =
            await _firestore.collection('students').doc(studentId).get();
        Map<String, dynamic> studentData =
            studentDoc.data() as Map<String, dynamic>;

        // Generate a unique roll number
        String rollNumber = await _generateRollNumber();

        // Add to registered students collection
        await _firestore.collection('registeredStudents').doc(studentId).set({
          'firstname': studentData['firstname'],
          'lastname': studentData['lastname'],
          'phone': studentData['phoneNumber'],
          'email': studentData['email'],
          'dateOfBirth': studentData['dateOfBirth'],
          'rollNumber': rollNumber,
          'registeredCourse': courseId,
          'registeredSection': section,
          'registeredYear': year,
        });

        // Update student document with roll number and registration info
        await _firestore
            .collection('students')
            .doc(studentId)
            .update({'rollNumber': rollNumber, 'status': "approved"});

        // Delete the registration request after approval
        await _firestore
            .collection('students')
            .doc(studentId)
            .update({'rollNumber': rollNumber, 'status': "approved"});

        // Increment the noOfStudents in the course document
        DocumentReference courseDoc =
            _firestore.collection('courses').doc(courseId);
        await courseDoc.update({
          'noOfStudents': FieldValue.increment(1),
        });

        // Increment the studentCount in the section document
        DocumentReference sectionDoc = courseDoc
            .collection('academicYears')
            .doc(year)
            .collection('sections')
            .doc(section);
        await sectionDoc.update({
          'studentCount': FieldValue.increment(1),
        });

        // Delete the registration request after approval
        await requestDoc.delete();
        await requestDoc.delete();

        print("Registration request approved and processed successfully.");
      } else {
        print("Request document does not exist.");
      }
    } catch (e) {
      print("Error approving registration request: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getRegisteredStudents() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('registeredStudents').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching registered students: $e");
      return [];
    }
  }

  // Helper function to generate unique roll number
  Future<String> _generateRollNumber() async {
    // Fetch all registered students and generate the next roll number
    QuerySnapshot snapshot =
        await _firestore.collection('registeredStudents').get();
    int rollCount = snapshot.size + 1; // Increment for the new student

    // Format roll number as SMS000000, SMS000001, etc.
    String rollNumber = "SMS${rollCount.toString().padLeft(6, '0')}";
    return rollNumber;
  }

  // Reject registration request
  Future<void> rejectRegistrationRequest(String requestId) async {
    try {
      await _firestore
          .collection('registrationRequests')
          .doc(requestId)
          .update({
        'status': 'rejected',
      });
    } catch (e) {
      print("Error rejecting registration request: $e");
    }
  }

  // Get all registration requests for admin
  Future<List<Map<String, dynamic>>> getRegistrationRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('registrationRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching registration requests: $e");
      return [];
    }
  }
}
