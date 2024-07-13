import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class AuthNewTeacher {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Save the current user (headmaster)
      User? currentUser = _firebaseAuth.currentUser;

      // Create the new teacher user
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
      });

      // Sign out the newly registered teacher
      await _firebaseAuth.signOut();

      // Sign in the headmaster back
      if (currentUser != null) {
        await _firebaseAuth.signInWithEmailAndPassword(email: currentUser.email!, password: password); // Ensure you have the headmaster's password or use a different authentication method
      }
    } catch (e) {
      throw FirebaseAuthException(
        code: 'createUserWithEmailAndPassword_failed',
        message: 'Failed to create user. Please try again later.',
      );
    }
  }


// Future<User?> signInWithGoogle() async {
//   try {
//     // Trigger the Google sign-in flow
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//
//     if (googleUser == null) {
//       // User canceled the sign-in
//       return null;
//     }
//
//     // Obtain the authentication details from the Google user
//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//
//     // Sign in to Firebase with the obtained credential
//     final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
//     return userCredential.user;
//   } catch (e) {
//     throw FirebaseAuthException(
//       code: 'signInWithGoogle_failed',
//       message: 'Failed to sign in with Google: $e',
//     );
//   }
// }
}
