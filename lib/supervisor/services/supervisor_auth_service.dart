import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupervisorAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the current user has the 'supervisor' role in Firestore
  Future<bool> isSupervisor(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('user').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['role'] == 'supervisor';
      }
      return false;
    } catch (e) {
      print('Error checking supervisor role: $e');
      return false;
    }
  }

  // Sign in specifically for supervisors
  Future<User?> signInSupervisor(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        bool isSup = await isSupervisor(user.uid);
        if (isSup) {
          return user;
        } else {
          // If not a supervisor, sign out immediately
          await _auth.signOut();
          throw 'Access denied: You do not have supervisor privileges.';
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current supervisor profile
  Future<DocumentSnapshot?> getSupervisorProfile(String uid) async {
    try {
      return await _firestore.collection('user').doc(uid).get();
    } catch (e) {
      print('Error getting supervisor profile: $e');
      return null;
    }
  }
}
