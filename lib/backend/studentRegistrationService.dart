// Student Registration Service
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StudentRegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update Student Profile Details
  // Check if the student has updated their profile
  Future<bool> isProfileUpdated(String userId) async {
    try {
      // Reference to the specific student's document in Firestore
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(userId).get();

      // Check if the required fields are present and non-empty
      if (studentDoc.exists) {
        Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;

        // Check if name, phoneNumber, and dateOfBirth fields are set and non-empty
        bool isfirstNameUpdated = data.containsKey('firstname') &&
            data['firstname'] != null &&
            data['firstname'].toString().isNotEmpty;
        bool islastNameUpdated = data.containsKey('lastname') &&
            data['lastname'] != null &&
            data['lastname'].toString().isNotEmpty;
        bool isPhoneNumberUpdated = data.containsKey('phoneNumber') &&
            data['phoneNumber'] != null &&
            data['phoneNumber'].toString().isNotEmpty;
        bool isDateOfBirthUpdated = data.containsKey('dateOfBirth') &&
            data['dateOfBirth'] != null &&
            data['dateOfBirth'].toString().isNotEmpty;

        // If all fields are updated, return true
        return isfirstNameUpdated &&
            isPhoneNumberUpdated &&
            isDateOfBirthUpdated &&
            islastNameUpdated;
      }
      // If the document does not exist, consider the profile incomplete
      return false;
    } catch (e) {
      print("Error checking profile update status: $e");
      return false;
    }
  }

  Future<void> updateStudentProfile({
    required String userId,
    required String firstname,
    required String lastname,
    required String phoneNumber,
    required String dateOfBirth,
  }) async {
    try {
      // Reference to the specific student's document in Firestore
      DocumentReference studentDoc =
          _firestore.collection('students').doc(userId);

      // Update the student's details
      await studentDoc.update({
        'firstname': firstname,
        'lastname': lastname,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth,
      });
      DocumentSnapshot registeredStudentDoc =
          await _firestore.collection('registeredStudents').doc(userId).get();

      if (registeredStudentDoc.exists) {
        // Update the student's details in the 'registeredStudents' collection
        await _firestore.collection('registeredStudents').doc(userId).update({
          'firstname': firstname,
          'lastname': lastname,
          'phone': phoneNumber,
          'dateOfBirth': dateOfBirth,
        });

        print("Student profile updated successfully in registeredStudents.");
      } else {
        print("Student not found in registeredStudents collection.");
      }

      print("Student profile updated successfully.");
      Fluttertoast.showToast(msg: "Profile updated successfully");
    } catch (e) {
      print("Error updating student profile: $e");
    }
  }

  // Get user details
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      // Reference to the specific student's document in Firestore
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(userId).get();

      // Check if the document exists
      if (studentDoc.exists) {
        // Return the student details as a Map
        return studentDoc.data() as Map<String, dynamic>?;
      } else {
        print("User document does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  // Register for a course and section
  Future<void> registerForCourse(
      String courseId, String academicYear, String section) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (await isProfileUpdated(currentUser!.uid)) {
      try {
        // Fetch student document to check if already registered
        DocumentSnapshot studentDoc =
            await _firestore.collection('students').doc(currentUser.uid).get();

        if (studentDoc.exists &&
            studentDoc.data() != null &&
            (studentDoc.data() as Map<String, dynamic>)
                .containsKey('courseId')) {
          // If courseId already exists in the document, show a message that registration exists
          Fluttertoast.showToast(
            msg: "You have already registered for a course",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red, // Set the background color to red
            textColor: Colors.white, // Set the text color to white for contrast
            fontSize: 16.0,
          );
        } else {
          // Register for the course if not already registered
          await _firestore
              .collection('registrationRequests')
              .doc(currentUser.uid)
              .set({
            'studentId': currentUser.uid,
            'courseId': courseId,
            'academicYear': academicYear,
            'section': section,
            'status': 'pending', // Registration request status
          });

          // Add course details to the student's document in the students collection
          await _firestore.collection('students').doc(currentUser.uid).update({
            'courseId': courseId,
            'year': academicYear,
            'section': section,
            'status': 'pending',
          });

          // Show success message
          Fluttertoast.showToast(msg: "Registered successfully");
        }
      } catch (e) {
        print("Error registering for course: $e");
        Fluttertoast.showToast(msg: "Error during registration.");
      }
    } else {
      Fluttertoast.showToast(msg: "User is not completed his profile.");
    }
  }
}
