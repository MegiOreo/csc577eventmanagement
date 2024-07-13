import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProposalScreen extends StatefulWidget {
  const ProposalScreen({super.key});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherPlaceController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedPlace;
  List<String> _places = ['Place 1', 'Place 2', 'Place 3', 'Others'];
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _userName = userDoc['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Propose Event')),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitProposal,
        child: Icon(Icons.check),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('d MMMM yyyy').format(_selectedDate!),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                ListTile(
                  title: Text(
                    _startTime == null
                        ? 'Select Start Time'
                        : _startTime!.format(context),
                  ),
                  trailing: Icon(Icons.access_time),
                  onTap: _pickStartTime,
                ),
                ListTile(
                  title: Text(
                    _endTime == null
                        ? 'Select End Time'
                        : _endTime!.format(context),
                  ),
                  trailing: Icon(Icons.access_time),
                  onTap: _pickEndTime,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPlace,
                  items: _places.map((place) {
                    return DropdownMenuItem<String>(
                      value: place,
                      child: Text(place),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlace = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Place'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a place';
                    }
                    return null;
                  },
                ),
                if (_selectedPlace == 'Others')
                  TextFormField(
                    controller: _otherPlaceController,
                    decoration: InputDecoration(labelText: 'Specify Other Place'),
                    validator: (value) {
                      if (_selectedPlace == 'Others' && (value == null || value.isEmpty)) {
                        return 'Please specify the place';
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _pickDate() async {
  //   DateTime today = DateTime.now();
  //   DateTime minDate = today.add(Duration(days: 10));
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: minDate,
  //     firstDate: minDate,
  //     lastDate: minDate.add(Duration(days: 365)),
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //   }
  // }

  Future<void> _pickDate() async {
    // Check if start time, end time, and place are selected
    if (_startTime == null || _endTime == null || _selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill start time, end time, and place first')),
      );
      return;
    }

    DateTime today = DateTime.now();
    DateTime minDate = today.add(Duration(days: 10));
    DateTime lastDate = minDate.add(Duration(days: 365));

    // Query for existing proposals that overlap with the selected date, time, and place
    CollectionReference proposalsRef = FirebaseFirestore.instance
        .collection('testproposal')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('proposals');

    QuerySnapshot overlappingProposals = await proposalsRef
        .where('place', isEqualTo: _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace)
        .get();

    List<DateTime> overlappingDates = [];

    // Extract overlapping dates from the existing proposals
    overlappingProposals.docs.forEach((proposal) {
      String dateString = proposal['date'];
      DateTime existingDate = DateFormat('d MMMM yyyy').parse(dateString);
      overlappingDates.add(existingDate);
    });

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: lastDate,
      selectableDayPredicate: (date) {
        // Check if the selected date is in overlappingDates
        if (overlappingDates.contains(date)) {
          // Check for time overlaps if the date matches
          DateTime startDate = DateTime(date.year, date.month, date.day, _startTime!.hour, _startTime!.minute);
          DateTime endDate = DateTime(date.year, date.month, date.day, _endTime!.hour, _endTime!.minute);

          // Check each proposal for overlapping time ranges
          bool hasOverlap = false;
          overlappingProposals.docs.forEach((proposal) {
            DateTime existingStartTime = (proposal['startTime'] as Timestamp).toDate();
            DateTime existingEndTime = (proposal['endTime'] as Timestamp).toDate();

            if (!(endDate.isBefore(existingStartTime) || startDate.isAfter(existingEndTime))) {
              hasOverlap = true;
              return;
            }
          });

          return !hasOverlap; // Return true if no overlap found
        } else {
          return true; // Date is not in overlappingDates, so selectable
        }
      },
    );

    if (picked != null) {
      // Calculate start and end DateTime objects from TimeOfDay and selected date
      DateTime startDate = DateTime(picked.year, picked.month, picked.day, _startTime!.hour, _startTime!.minute);
      DateTime endDate = DateTime(picked.year, picked.month, picked.day, _endTime!.hour, _endTime!.minute);

      // No overlap, set the selected date
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  //new 1
  // Future<void> _pickDate() async {
  //   // Check if start time, end time, and place are selected
  //   if (_startTime == null && _endTime == null && _selectedPlace == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill start time, end time, and place first')),
  //     );
  //     return;
  //   } else if (_startTime == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill start time')),
  //     );
  //     return;
  //   } else if (_endTime == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill end time')),
  //     );
  //     return;
  //   } else if (_selectedPlace == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill place')),
  //     );
  //     return;
  //   }
  //
  //
  //
  //   DateTime today = DateTime.now();
  //   DateTime minDate = today.add(Duration(days: 10));
  //   DateTime lastDate = minDate.add(Duration(days: 365));
  //
  //   // Query for existing proposals that overlap with the selected date, time, and place
  //   CollectionReference proposalsRef = FirebaseFirestore.instance
  //       .collection('testproposal')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('proposals');
  //
  //   QuerySnapshot overlappingProposals = await proposalsRef
  //       .where('place', isEqualTo: _selectedPlace == 'Others'? _otherPlaceController.text : _selectedPlace)
  //       .get();
  //
  //   List<DateTime> overlappingDates = [];
  //
  //   // Extract dates from the existing proposals
  //   // Extract dates from the existing proposals
  //   overlappingProposals.docs.forEach((proposal) {
  //     String dateString = proposal['date'];
  //     DateTime existingDate = DateFormat('d MMMM yyyy').parse(dateString);
  //     overlappingDates.add(existingDate);
  //   });
  //
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: minDate,
  //     firstDate: minDate,
  //     lastDate: lastDate,
  //     selectableDayPredicate: (date) {
  //       return!overlappingDates.contains(date);
  //     },
  //   );
  //
  //   if (picked!= null) {
  //     // Calculate start and end DateTime objects from TimeOfDay and selected date
  //     DateTime startDate = DateTime(picked.year, picked.month, picked.day, _startTime!.hour, _startTime!.minute);
  //     DateTime endDate = DateTime(picked.year, picked.month, picked.day, _endTime!.hour, _endTime!.minute);
  //
  //     // No overlap, set the selected date
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //   }
  // }



  Future<void> _pickStartTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _submitProposal() async {
    if (_formKey.currentState!.validate()) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference proposalsRef = FirebaseFirestore.instance
          .collection('testproposal')
          .doc(uid)
          .collection('proposals');

      // Calculate start and end DateTime objects from TimeOfDay and selected date
      DateTime startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _startTime!.hour, _startTime!.minute);
      DateTime endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _endTime!.hour, _endTime!.minute);

      // Query for existing proposals that overlap with the new proposal's time range
      QuerySnapshot overlappingProposals = await proposalsRef
          .where('date', isEqualTo: DateFormat('d MMMM yyyy').format(_selectedDate!))
      .where('place', isEqualTo: _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace)
          .get();

      bool hasOverlap = false;

      // Check each proposal for overlapping time ranges
      overlappingProposals.docs.forEach((proposal) {
        // Extract startTime and endTime from the existing proposal
        DateTime existingStartTime = (proposal['startTime'] as Timestamp).toDate();
        DateTime existingEndTime = (proposal['endTime'] as Timestamp).toDate();

        // Check for overlap condition
        if (!(endDate.isBefore(existingStartTime) || startDate.isAfter(existingEndTime))) {
          hasOverlap = true;
          return;
        }
      });

      if (hasOverlap) {
        // Display an error message or handle overlap condition
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot add proposal. Time overlap with existing proposal.')),
        );
      } else {
        // No overlap, proceed to add the new proposal
        await proposalsRef.add({
          'title': _titleController.text,
          'date': DateFormat('d MMMM yyyy').format(_selectedDate!),
          'startTime': Timestamp.fromDate(startDate),
          'endTime': Timestamp.fromDate(endDate),
          'place': _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace,
          'description': _descriptionController.text,
          'status': 'Pending',
          'submittedBy': _userName,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': uid,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Proposal submitted successfully!')),
        );

        // Navigate back or perform other actions
        Navigator.of(context).pop();
      }
    }
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// class ProposalScreen extends StatefulWidget {
//   const ProposalScreen({super.key});
//
//   @override
//   State<ProposalScreen> createState() => _ProposalScreenState();
// }
//
// class _ProposalScreenState extends State<ProposalScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _otherPlaceController = TextEditingController();
//   DateTime? _selectedDate;
//   TimeOfDay? _startTime;
//   TimeOfDay? _endTime;
//   String? _selectedPlace;
//   List<String> _places = ['Place 1', 'Place 2', 'Place 3', 'Others'];
//   String? _userName;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserName();
//   }
//
//   Future<void> _fetchUserName() async {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     DocumentSnapshot userDoc =
//     await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     setState(() {
//       _userName = userDoc['name'];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Propose Event')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _submitProposal,
//         child: Icon(Icons.check),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(labelText: 'Title'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a title';
//                     }
//                     return null;
//                   },
//                 ),
//                 ListTile(
//                   title: Text(
//                     _selectedDate == null
//                         ? 'Select Date'
//                         : DateFormat('d MMMM yyyy').format(_selectedDate!),
//                   ),
//                   trailing: Icon(Icons.calendar_today),
//                   onTap: _pickDate,
//                 ),
//                 ListTile(
//                   title: Text(
//                     _startTime == null
//                         ? 'Select Start Time'
//                         : _startTime!.format(context),
//                   ),
//                   trailing: Icon(Icons.access_time),
//                   onTap: _pickStartTime,
//                 ),
//                 ListTile(
//                   title: Text(
//                     _endTime == null
//                         ? 'Select End Time'
//                         : _endTime!.format(context),
//                   ),
//                   trailing: Icon(Icons.access_time),
//                   onTap: _pickEndTime,
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _selectedPlace,
//                   items: _places.map((place) {
//                     return DropdownMenuItem<String>(
//                       value: place,
//                       child: Text(place),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedPlace = value;
//                     });
//                   },
//                   decoration: InputDecoration(labelText: 'Place'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select a place';
//                     }
//                     return null;
//                   },
//                 ),
//                 if (_selectedPlace == 'Others')
//                   TextFormField(
//                     controller: _otherPlaceController,
//                     decoration: InputDecoration(labelText: 'Specify Other Place'),
//                     validator: (value) {
//                       if (_selectedPlace == 'Others' && (value == null || value.isEmpty)) {
//                         return 'Please specify the place';
//                       }
//                       return null;
//                     },
//                   ),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(labelText: 'Description'),
//                   maxLines: 3,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a description';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickDate() async {
//     DateTime today = DateTime.now();
//     DateTime minDate = today.add(Duration(days: 10));
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: minDate,
//       firstDate: minDate,
//       lastDate: minDate.add(Duration(days: 365)),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   Future<void> _pickStartTime() async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null && picked != _startTime) {
//       setState(() {
//         _startTime = picked;
//       });
//     }
//   }
//
//   Future<void> _pickEndTime() async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null && picked != _endTime) {
//       setState(() {
//         _endTime = picked;
//       });
//     }
//   }
//
//   // Future<void> _submitProposal() async {
//   //   if (_formKey.currentState!.validate()) {
//   //     String uid = FirebaseAuth.instance.currentUser!.uid;
//   //     CollectionReference proposalsRef = FirebaseFirestore.instance
//   //     //.collection('pending')
//   //         .collection('userProposal')
//   //         .doc(uid)
//   //         .collection('proposals');
//   //
//   //     // Format the date to store in the desired format (e.g., "4th July 2024")
//   //     String formattedDate = DateFormat('d MMMM yyyy').format(_selectedDate!);
//   //
//   //     await proposalsRef.add({
//   //       'title': _titleController.text,
//   //       'date': formattedDate,
//   //       'startTime': _startTime?.format(context),
//   //       'endTime': _endTime?.format(context),
//   //       'place': _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace,
//   //       'description': _descriptionController.text,
//   //       'status': 'Pending',
//   //       'submittedBy': _userName,
//   //       'createdAt': FieldValue.serverTimestamp(),
//   //     });
//   //
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Proposal submitted successfully!')),
//   //     );
//   //
//   //     Navigator.of(context).pop();
//   //   }
//   // }
//
//
//   Future<void> _submitProposal() async {
//     if (_formKey.currentState!.validate()) {
//       String uid = FirebaseAuth.instance.currentUser!.uid;
//       CollectionReference proposalsRef = FirebaseFirestore.instance
//           //.collection('userProposal')
//           .collection('pending')
//           .doc(uid)
//           .collection('proposals');
//
//       // Format the date to store in the desired format (e.g., "4th July 2024")
//       String formattedDate = DateFormat('d MMMM yyyy').format(_selectedDate!);
//
//       await proposalsRef.add({
//         'title': _titleController.text,
//         'date': formattedDate,
//         'startTime': _startTime?.format(context),
//         'endTime': _endTime?.format(context),
//         'place': _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace,
//         'description': _descriptionController.text,
//         'status': 'Pending',
//         'submittedBy': _userName,
//         'createdAt': FieldValue.serverTimestamp(),
//         'uid': uid, // Adding uid field based on current user
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Proposal submitted successfully!')),
//       );
//
//       Navigator.of(context).pop();
//     }
//   }
//
// }
//
// // Future<void> _submitProposal() async {
// //   if (_formKey.currentState!.validate()) {
// //     String uid = FirebaseAuth.instance.currentUser!.uid;
// //     CollectionReference pendingProposalsRef = FirebaseFirestore.instance
// //         .collection('pending')
// //         .doc(uid)
// //         .collection('proposals');
// //
// //     // Format the date to store in the desired format (e.g., "4th July 2024")
// //     String formattedDate = DateFormat('d MMMM yyyy').format(_selectedDate!);
// //
// //     // Check if a similar proposal already exists in approved collection
// //     QuerySnapshot similarProposals = await FirebaseFirestore.instance
// //         .collection('approved')
// //         .doc(uid)
// //         .collection('proposals')
// //     //.where('title', isEqualTo: _titleController.text)
// //         .where('date', isEqualTo: formattedDate)
// //         .where('startTime', isEqualTo: _startTime?.format(context))
// //         .where('place', isEqualTo: _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace)
// //         .get();
// //
// //     if (similarProposals.docs.isNotEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('The place is occupied at that date and time :(')),
// //       );
// //       return; // Exit function if similar proposal found
// //     }
// //
// //     // If no similar proposal found, add to pending proposals
// //     await pendingProposalsRef.add({
// //       'title': _titleController.text,
// //       'date': formattedDate,
// //       'startTime': _startTime?.format(context),
// //       'endTime': _endTime?.format(context),
// //       'place': _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace,
// //       'description': _descriptionController.text,
// //       'status': 'Pending',
// //       'submittedBy': _userName,
// //       'createdAt': FieldValue.serverTimestamp(),
// //     });
// // //start
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Proposal submitted successfully!')),
// //     );
// //
// //     Navigator.of(context).pop();
// //   }
// // }
