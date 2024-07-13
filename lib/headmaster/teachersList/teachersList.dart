import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventmanagement/headmaster/teachersList/registerTeacher.dart';
import 'package:flutter/material.dart';

class Teacherslist extends StatefulWidget {
  const Teacherslist({super.key});

  @override
  State<Teacherslist> createState() => _TeacherslistState();
}

class _TeacherslistState extends State<Teacherslist> {
  Widget _teacherContainer(String name, String email) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1,
        height: MediaQuery.sizeOf(context).height * 0.16,
        decoration: BoxDecoration(
          color: Color.fromARGB(169, 122, 48, 181),//Colors.purple,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),]
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                email,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teachers Account')),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterTeacherScreen()));
      //   },
      //   child: Icon(Icons.add),
      // ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final teachers = snapshot.data?.docs ?? [];

            return ListView.builder(
              padding: EdgeInsets.only(bottom: 100),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                //if (index != teachers.length) {
                  final teacher = teachers[index];
                  final name = teacher['name'] ?? 'No Name';
                  final email = teacher['email'] ?? 'No Email';

                  return _teacherContainer(name, email);
                  // Adjust the height as needed
                // } else {
                //   return Container(
                //     height: MediaQuery.sizeOf(context).height * 0.1,
                //     width: MediaQuery.sizeOf(context).height * 1,
                //     decoration: BoxDecoration(color: Colors.black),
                //   );
                // }
              },
            );
          },
        ),
      ),
    );
  }
}

// //*
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:eventmanagement/headmaster/teachersList/registerTeacher.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class Teacherslist extends StatefulWidget {
//   const Teacherslist({super.key});
//
//   @override
//   State<Teacherslist> createState() => _TeacherslistState();
// }
//
// class _TeacherslistState extends State<Teacherslist> {
//   final TextEditingController _passwordController = TextEditingController();
//   String? _currentUserPasswordError;
//
//   Widget _teacherContainer(String name, String email, String teacherId) {
//     return GestureDetector(
//       onLongPress: () {
//         _confirmDeleteTeacher(teacherId, email);
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           width: MediaQuery.sizeOf(context).width * 1,
//           height: MediaQuery.sizeOf(context).height * 0.1,
//           decoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   email,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _confirmDeleteTeacher(String teacherId, String teacherEmail) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Enter your password to confirm deletion:'),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: 'Your Password',
//                   errorText: _currentUserPasswordError,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _passwordController.clear();
//               },
//               child: Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _deleteTeacher(teacherId, teacherEmail);
//               },
//               child: Text('Confirm Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _deleteTeacher(String teacherId, String teacherEmail) async {
//     try {
//       // Validate the user's password
//       String password = _passwordController.text.trim();
//       User? user = FirebaseAuth.instance.currentUser;
//       AuthCredential credential = EmailAuthProvider.credential(
//         email: user!.email!,
//         password: password,
//       );
//
//       await user.reauthenticateWithCredential(credential);
//
//       // Delete the teacher document from Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc('YsrFeTFvew5cdpaEXrnV')
//           .collection('teachers')
//           .doc(teacherId)
//           .delete();
//
//       // Optionally, delete the teacher from Firebase Authentication
//       // Note: This step is only necessary if you manage users in Firebase Authentication
//       // Make sure to confirm the teacher's email against what is stored in Firestore
//       if (user.email == teacherEmail) {
//         await user.delete();
//       }
//
//       // Close the dialog and clear password field
//       Navigator.of(context).pop(); // Close the delete confirmation dialog
//       _passwordController.clear();
//     } catch (e) {
//       setState(() {
//         _currentUserPasswordError = 'Invalid password. Please try again.';
//       });
//     }
//   }
//
//   // void _deleteTeacher(String teacherId, String teacherEmail) async {
//   //   try {
//   //     // Validate the user's password
//   //     String password = _passwordController.text.trim();
//   //     UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//   //       email: FirebaseAuth.instance.currentUser!.email!,
//   //       password: password,
//   //     );
//   //
//   //     // Delete the teacher document from Firestore
//   //     await FirebaseFirestore.instance
//   //         .collection('users')
//   //         .doc('YsrFeTFvew5cdpaEXrnV')
//   //         .collection('teachers')
//   //         .doc(teacherId)
//   //         .delete();
//   //
//   //     // Optionally, delete the teacher from Firebase Authentication
//   //     // Note: This step is only necessary if you manage users in Firebase Authentication
//   //     // Make sure to confirm the teacher's email against what is stored in Firestore
//   //     if (credential.user!.email == teacherEmail) {
//   //       await credential.user!.delete();
//   //     }
//   //
//   //     // Close the dialog and clear password field
//   //     Navigator.of(context).pop(); // Close the delete confirmation dialog
//   //     _passwordController.clear();
//   //   } catch (e) {
//   //     setState(() {
//   //       _currentUserPasswordError = 'Invalid password. Please try again.';
//   //     });
//   //   }
//   // }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Teachers')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterTeacherScreen()));
//         },
//         child: Icon(Icons.add),
//       ),
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('users')
//               .doc('YsrFeTFvew5cdpaEXrnV')
//               .collection('teachers')
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//
//             final teachers = snapshot.data?.docs ?? [];
//
//             return ListView.builder(
//               itemCount: teachers.length,
//               itemBuilder: (context, index) {
//                 final teacher = teachers[index];
//                 final name = teacher['name'] ?? 'No Name';
//                 final email = teacher['email'] ?? 'No Email';
//                 final teacherId = teacher.id;
//
//                 return _teacherContainer(name, email, teacherId);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
//  *//
