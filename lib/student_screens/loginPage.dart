import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:student_management_system/admin_screens/admin_login.dart';
import 'package:student_management_system/backend/authentication.dart';
import 'package:student_management_system/student_screens/home_screen.dart';
import 'package:student_management_system/student_screens/signupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _header(context),
              _inputField(context),
              _forgotPassword(context),
              _adminLogin(context),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credentials to login"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.only(top: 3, left: 3),
            child: ElevatedButton(
              onPressed: () async {
                await _loginWithEmail();
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            )),
        const Center(child: Text("Or")),
        Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.purple,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: TextButton(
            onPressed: () {
              _loginWithGoogle();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30.0,
                  width: 30.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image:
                            AssetImage('assets/images/login_signup/google.png'),
                        fit: BoxFit.cover),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 18),
                const Text(
                  "Sign In with Google",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loginWithEmail() async {
    try {
      User? user = await auth.loginWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Fluttertoast.showToast(msg: "Login successful");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => HomePage()));
      } else {
        Fluttertoast.showToast(msg: "Login failed. Check credentials.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  void _loginWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Google sign-in canceled");
        return;
      }

      User? user = await auth.signInWithGoogle('student');
      Fluttertoast.showToast(msg: "Signin successful");
      Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
    } catch (e) {
      Fluttertoast.showToast(msg: "an error occured $e");
      print("Google sign-in error: $e");
    }
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {
        // Implement forgot password functionality if needed
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.purple),
      ),
    );
  }

  _adminLogin(context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const AdminLoginPage()));
      },
      child: const Text(
        "Admin Login",
        style: TextStyle(color: Colors.purple),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const SignupPage()));
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: Colors.purple),
            ))
      ],
    );
  }
}
