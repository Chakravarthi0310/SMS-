import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_management_system/backend/studentRegistrationService.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StudentRegistrationService stu = StudentRegistrationService();
  String getFirstName = "";
  String getLastName = "";
  String getPhoneNumber = "";
  String getDateofBirth = "";
  Map<String, dynamic>? userDetails;
  bool is_updated = false;
  bool is_loading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> getprofile() async {
    setState(() {
      is_loading = true;
    });
    is_updated = await stu.isProfileUpdated(_auth.currentUser!.uid);
    userDetails = await stu.getUserDetails(_auth.currentUser!.uid);
    setState(() {
      is_loading = false;
    });
    if (is_updated) {
      setState(() {
        getFirstName = userDetails?['firstname'] ?? "";
        getLastName = userDetails?['lastname'] ?? "";
        getPhoneNumber = userDetails?['phoneNumber'] ?? "";
        getDateofBirth = userDetails?['dateOfBirth'] ?? "";
      });
    } else {
      Fluttertoast.showToast(
          msg: "Profile is not updated. Please complete your profile.");
      // Optionally, you could show a message or redirect the user to update the profile
      print("Profile is not updated. Please complete your profile.");
    }
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();

  TextEditingController phoneNumber = TextEditingController();

  TextEditingController dateOfBirth = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getprofile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Complete Your Profile"),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  TextFormField(
                    controller: firstname,
                    decoration: InputDecoration(
                      labelText:
                          getFirstName != "" ? getFirstName : 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: lastname,
                    decoration: InputDecoration(
                      labelText: getLastName != "" ? getLastName : 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),

                  // Phone Number Field
                  TextFormField(
                    controller: phoneNumber,
                    decoration: InputDecoration(
                      labelText: getPhoneNumber != ""
                          ? getPhoneNumber
                          : 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),

                  // Email Field

                  SizedBox(height: 16.0),

                  // Date of Birth Field
                  TextFormField(
                    controller: dateOfBirth,
                    decoration: InputDecoration(
                      labelText: getDateofBirth != ""
                          ? getDateofBirth
                          : 'Date of Birth',
                      hintText: 'DD/MM/YYYY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your date of birth';
                      } else if (!RegExp(
                              r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$')
                          .hasMatch(value)) {
                        return 'Enter date as DD/MM/YYYY';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.0),

                  // Save Profile Button
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await stu.updateStudentProfile(
                            userId: _auth.currentUser!.uid,
                            firstname: firstname.text.trim(),
                            lastname: lastname.text.trim(),
                            phoneNumber: phoneNumber.text.trim(),
                            dateOfBirth: dateOfBirth.text.trim());
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (is_loading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ]),
    );
  }
}
