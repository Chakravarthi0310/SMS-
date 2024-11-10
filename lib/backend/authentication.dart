import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register with Email and Password
  Future<User?> registerWithEmailPassword(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Save user data in Firestore in respective collection
      await _firestore.collection(role == 'student' ? 'students' : 'admins').doc(user?.uid).set({
        'email': email,
        'role': role,
      });
      return user;
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // Login with Email and Password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle(String role) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      // Check if user exists in Firestore, else create a record
      DocumentSnapshot doc = await _firestore.collection(role == 'student' ? 'students' : 'admins').doc(user?.uid).get();
      if (!doc.exists) {
        await _firestore.collection(role == 'student' ? 'students' : 'admins').doc(user?.uid).set({
          'email': user?.email,
          'role': role,
        });
      }
      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Check user role
  Future<String?> getUserRole(User user) async {
    DocumentSnapshot studentDoc = await _firestore.collection('students').doc(user.uid).get();
    DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(user.uid).get();

    if (studentDoc.exists) return 'student';
    if (adminDoc.exists) return 'admin';
    return null;
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
