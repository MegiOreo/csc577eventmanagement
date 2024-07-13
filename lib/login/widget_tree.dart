//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:tasknotetimetableapp/auth.dart';
// import 'package:diaryapp/homepage.dart';
// import 'package:diaryapp/login/auth.dart';
// import 'package:diaryapp/login/loginregisterScreen.dart';
// import 'package:diaryapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventmanagement/headmaster/headmhomescreen.dart';
import 'package:eventmanagement/headmaster/headpage.dart';
import 'package:eventmanagement/main.dart';
import 'package:eventmanagement/teachers/proposedEventsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../teachers/teacherpage.dart';
import 'auth.dart';
import 'loginregisterScreen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

// class _WidgetTreeState extends State<WidgetTree> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: Auth().authStateChanges, builder: (context, snapshot) {
//           if(snapshot.hasData){
//             return MyHomePage(title: 'Title',);
//           } else{
//             return const LoginScreen();
//           }
//         });
//   }
// }


// class _WidgetTreeState extends State<WidgetTree> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: Auth().authStateChanges,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           final user = snapshot.data;
//           if (user == null) {
//             return const LoginScreen();
//           } else {
//             return const HeadMPage();
//           }
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          } else {
            // Get the user's role from Firebase Firestore
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final role = snapshot.data?.get('role');
                  if (role == 'headmaster') {
                    return const HeadMPage();
                  } else if (role == 'teacher') {
                    return const ProposedEventsScreen();
                  } else {
                    // Handle unknown role
                    return const LoginScreen();
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
