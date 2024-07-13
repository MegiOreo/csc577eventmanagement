// import 'package:flutter/material.dart';
//
// class EditProposal extends StatefulWidget {
//   const EditProposal({super.key});
//
//   @override
//   State<EditProposal> createState() => _EditProposalState();
// }
//
// class _EditProposalState extends State<EditProposal> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditProposalScreen extends StatefulWidget {
  final String proposalId;
  final Map<String, dynamic> fields;

  const EditProposalScreen({Key? key, required this.proposalId, required this.fields}) : super(key: key);

  @override
  State<EditProposalScreen> createState() => _EditProposalScreenState();
}

class _EditProposalScreenState extends State<EditProposalScreen> {
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
    _titleController.text = widget.fields['title'];
    _descriptionController.text = widget.fields['description'];
    _selectedDate = DateFormat('d MMMM yyyy').parse(widget.fields['date']);
    _startTime = TimeOfDay(hour: (widget.fields['startTime'] as Timestamp).toDate().hour, minute: (widget.fields['startTime'] as Timestamp).toDate().minute);
    _endTime = TimeOfDay(hour: (widget.fields['endTime'] as Timestamp).toDate().hour, minute: (widget.fields['endTime'] as Timestamp).toDate().minute);
    _selectedPlace = widget.fields['place'];
    if (_selectedPlace == 'Others') {
      _otherPlaceController.text = widget.fields['place'];
    }
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
      appBar: AppBar(title: Text('Edit Proposal')),
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

  Future<void> _pickDate() async {
    // if (_startTime == null || _endTime == null || _selectedPlace == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please fill start time, end time, and place first')),
    //   );
    //   return;
    // }

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
        .where('date', isEqualTo: DateFormat('d MMMM yyyy').format(_selectedDate!))
        .get();

    List<DateTime> overlappingDates = [];

    // Extract dates from the existing proposals
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
        return!overlappingDates.contains(date);
      },
    );

    if (picked!= null) {
      // Calculate start and end DateTime objects from TimeOfDay and selected date
      DateTime startDate = DateTime(picked.year, picked.month, picked.day, _startTime!.hour, _startTime!.minute);
      DateTime endDate = DateTime(picked.year, picked.month, picked.day, _endTime!.hour, _endTime!.minute);

      // No overlap, set the selected date
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
    bool isResubmit = widget.fields['status'] == 'Need changes';

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
        // No overlap, proceed to update the proposal
        // await proposalsRef.doc(widget.proposalId).update({
        //   'title': _titleController.text,
        //   'date': DateFormat('d MMMM yyyy').format(_selectedDate!),
        //   'startTime': Timestamp.fromDate(startDate),
        //   'endTime': Timestamp.fromDate(endDate),
        //   'place': _selectedPlace == 'Others' ? _otherPlaceController.text : _selectedPlace,
        //   'description': _descriptionController.text,
        //   'status': 'Pending',
        //   'submittedBy': _userName,
        //   if(isResubmit)
        //   'editedAt': FieldValue.serverTimestamp(),
        //   //'createdAt': FieldValue.serverTimestamp(),
        //   'uid': uid,
        // });
        Map<String, dynamic> updateData = {
          'title': _titleController.text,
          'date': DateFormat('d MMMM yyyy').format(_selectedDate!),
          'startTime': Timestamp.fromDate(startDate),
          'endTime': Timestamp.fromDate(endDate),
          'place': _selectedPlace == 'Others'
              ? _otherPlaceController.text
              : _selectedPlace,
          'description': _descriptionController.text,
          'status': 'Pending',
          'submittedBy': _userName,
          'editedAt': FieldValue.serverTimestamp(),
          //'createdAt': FieldValue.serverTimestamp(),
          'uid': uid,
        };

        if (isResubmit) {
          updateData['resubmitAt'] = FieldValue.serverTimestamp();
        }

        await proposalsRef.doc(widget.proposalId).update(updateData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Proposal updated successfully!')),
        );

        // Navigate back or perform other actions
        Navigator.of(context).pop();
      }
    }
  }
}

