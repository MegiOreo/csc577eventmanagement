import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'signInWithEmailAndPassword_failed',
        message: 'Sign in failed. Please check your credentials.',
      );
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'createUserWithEmailAndPassword_failed',
        message: 'Failed to create user. Please try again later.',
      );
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    //await _googleSignIn.signOut(); // Ensure Google sign-out as well
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
