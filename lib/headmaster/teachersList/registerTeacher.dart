// import 'package:eventmanagement/headmaster/headpage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../../headmaster/teachersList//authNewTeacher.dart';
//
// class RegisterTeacherScreen extends StatefulWidget {
//   const RegisterTeacherScreen({super.key});
//
//   @override
//   State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
// }
//
// class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
//   String? errorMessage = '';
//
//   final TextEditingController _controllerEmail = TextEditingController();
//   final TextEditingController _controllerPassword = TextEditingController();
//
//   String _capitalizeEachWord(String input) {
//     return input.split(' ').map((word) {
//       if (word.isNotEmpty) {
//         return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
//       }
//       return '';
//     }).join(' ');
//   }
//
//   Future<void> createUserWithEmailAndPassword() async {
//     try {
//       String _formattedName = _capitalizeEachWord(_teacherNameController.text);
//       await AuthNewTeacher().createUserWithEmailAndPassword(
//         name: _formattedName,//_teacherNameController.text,
//         email: _controllerEmail.text,
//         password: _controllerPassword.text,
//         role: 'teacher',
//       );
//       Navigator.pop(context);
//       // Navigator.pushReplacement(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => HeadMPage()),
//       // );
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         errorMessage = e.message;
//       });
//     }
//   }
//
//   bool obscureText = true; // Added for password visibility toggle
//   Widget _entryField(String title, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: TextFormField(
//         controller: controller,
//         obscureText: title.toLowerCase() == 'password' ? obscureText : false,
//         decoration: InputDecoration(
//           enabledBorder: OutlineInputBorder(
//             borderSide: const BorderSide(color: Colors.grey),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: Colors.black,
//               width: 2,
//             ),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: Colors.red,
//               width: 2,
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           labelText: title,
//           suffixIcon: title.toLowerCase() == 'password'
//               ? IconButton(
//                   icon: Icon(
//                     obscureText ? Icons.visibility : Icons.visibility_off,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       obscureText = !obscureText;
//                     });
//                   },
//                 )
//               : null,
//         ),
//       ),
//     );
//   }
//
//   final TextEditingController _teacherNameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Register Teacher')),
//       floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             createUserWithEmailAndPassword();
//           },
//           child: Icon(Icons.add)),
//       body: SafeArea(
//           child: Column(
//         children: [
//           _entryField('Name', _teacherNameController),
//           _entryField('Email', _controllerEmail),
//           _entryField('Password', _controllerPassword),
//         ],
//       )),
//     );
//   }
// }

import 'package:eventmanagement/headmaster/headpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

import '../../headmaster/teachersList/authNewTeacher.dart';

class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({super.key});

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  String? errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _teacherNameController = TextEditingController();

  String _capitalizeEachWord(String input) {
    return input.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }
      return '';
    }).join(' ');
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      String _formattedName = _capitalizeEachWord(_teacherNameController.text);
      await AuthNewTeacher().createUserWithEmailAndPassword(
        name: _formattedName,
        email: _controllerEmail.text,
        password: _controllerPassword.text,
        role: 'teacher',
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  bool obscureText = true; // Added for password visibility toggle

  Widget _entryField(String title, TextEditingController controller, {List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: controller,
        obscureText: title.toLowerCase() == 'password' ? obscureText : false,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Teacher')),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            createUserWithEmailAndPassword();
          },
          child: Icon(Icons.add)),
      body: SafeArea(
          child: Column(
            children: [
              _entryField('Name', _teacherNameController, inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ]),
              _entryField('Email', _controllerEmail),
              _entryField('Password', _controllerPassword),
              _errorMessage()
            ],
          )),
    );
  }
}

