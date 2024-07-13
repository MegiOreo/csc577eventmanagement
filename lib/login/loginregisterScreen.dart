//import 'package:eventmanagement//login/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import 'auth.dart';
// import 'package:tasknotetimetable/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> forgotPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _controllerEmail.text);
      setState(() {
        errorMessage = 'Password reset email sent. Check your email inbox.';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  // Future<void> signInWithGoogle() async {
  //   try {
  //     await Auth().signInWithGoogle();
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = e.toString();
  //     });
  //   }
  // }

  Widget _title() {
    return const Text('Event Management');
  }

  // Widget _entryField(
  //   String title,
  //   TextEditingController controller,
  // ) {
  //   return TextField(
  //     controller: controller,
  //     decoration: InputDecoration(
  //       labelText: title,
  //     ),
  //   );
  // }
  bool obscureText = true; // Added for password visibility toggle
  Widget _entryField(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        obscureText: title.toLowerCase() == 'password' ? obscureText : false,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.green,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: title,
          suffixIcon: title.toLowerCase() == 'password'
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.86,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: signInWithEmailAndPassword,
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // Widget _loginOrRegisterButton() {
  //   return TextButton(
  //     onPressed: () {
  //       setState(() {
  //         isLogin = !isLogin;
  //       });
  //     },
  //     child: Text(isLogin ? 'Register instead' : 'Login instead'),
  //   );
  // }

  // Widget _googleSignInButton() {
  //   return ElevatedButton(
  //     onPressed: signInWithGoogle,
  //     child: const Text('Continue with Google'),
  //   );
  // }

  Widget _forgotPassButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              forgotPassword();
              print("Forgot password");
            },
            child: Text("Forgot password"),
          )
        ],
      ),
    );
  }

  Widget _logoContainer() {
    return Container(
        width: MediaQuery.sizeOf(context).width * 0.5,
        height: MediaQuery.sizeOf(context).height * 0.2,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/siitassyakirinlogo-removebg.png'),
                fit: BoxFit.cover)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: _title(),
      // ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logoContainer(),
            Text(
              'SIIT AS-SYAKIRIN',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '(EVENT MANAGEMENT)',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.08),
            _entryField('Email', _controllerEmail),
            _entryField('Password', _controllerPassword),
            _forgotPassButton(),
            _errorMessage(),
            _submitButton(),
            //_loginOrRegisterButton(),
            //_googleSignInButton(),
          ],
        ),
      ),
    );
  }
}
