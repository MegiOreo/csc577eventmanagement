import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewProposal extends StatefulWidget {
  final Map<String, dynamic> fields;
  final String proposalId;

  const ReviewProposal({Key? key, required this.fields, required this.proposalId}) : super(key: key);

  @override
  State<ReviewProposal> createState() => _ReviewProposalState();
}

class _ReviewProposalState extends State<ReviewProposal> {
  // void updateStatusToOpened() async {
  //   String uid = widget.fields['uid']; // Assuming 'uid' is present in fields
  //   String proposalId = widget.proposalId; // Assuming 'proposalId' is present in fields
  //
  //   // Update Firestore document
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('pending')
  //         .doc(uid)
  //         .collection('proposals')
  //         .doc(proposalId)
  //         .update({
  //       'status': 'Opened',
  //     });
  //     print('Status updated to opened successfully');
  //   } catch (e) {
  //     print('Error updating status: $e');
  //     // Handle error as needed
  //   }
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // Update Firestore status to 'opened' when widget is initialized
  //   updateStatusToOpened();
  // }

  void showApprovalDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    bool allowModify = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Approve or Reject Proposal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Provide a reason if rejecting:'),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: 'Enter reason here',
                    ),
                    maxLines: 3,
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: allowModify,
                        onChanged: (bool? value) {
                          setState(() {
                            allowModify = value ?? false;
                          });
                        },
                      ),
                      Text('Allow modify'),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Approve'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    updateProposalStatus('Approved', '');
                  },
                ),
                TextButton(
                  child: Text('Reject'),
                  onPressed: () {
                    if (reasonController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reason for rejection is required')),
                      );
                    } else {
                      String status = 'Rejected';
                      if (allowModify) {
                        status = 'Need changes';
                      }
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      updateProposalStatus(status, reasonController.text);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }



  void updateProposalStatus(String status, String reason) async {
    String uid = widget.fields['uid'];
    String proposalId = widget.proposalId;

    try {
      //await FirebaseFirestore.instance
      DocumentReference proposalRef = FirebaseFirestore.instance
          .collection('testproposal')
          .doc(uid)
          .collection('proposals')
          .doc(proposalId);
      //     .update({
      //   'status': status,
      //   'approvalAt': FieldValue.serverTimestamp(),
      //   'reason': reason,
      // });
      if (status == 'Approved') {
        await proposalRef.update({
          'status': status,
          'approvalAt': FieldValue.serverTimestamp(),
          'reason': FieldValue.delete(), // Remove the reason field
        });
      } else {
        await proposalRef.update({
          'status': status,
          'approvalAt': FieldValue.serverTimestamp(),
          'reason': reason,
        });
      }
      print('Status updated to $status successfully');
    } catch (e) {
      print('Error updating status: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    Timestamp createdAtTimestamp = widget.fields['createdAt']; // Assuming 'createdAt' is retrieved as Timestamp

    // Convert Timestamp to DateTime
    DateTime createdAtDate = createdAtTimestamp.toDate();

    // Format DateTime into a readable string
    String formattedCreatedAt = DateFormat('d MMMM yyyy, hh:mm a').format(createdAtDate);

    Timestamp startTimeTimestamp = widget.fields['startTime'];
    DateTime startTimeDate = startTimeTimestamp.toDate();
    String formattedStartTime = DateFormat('hh:mm a').format(startTimeDate);

    Timestamp endTimeTimestamp = widget.fields['endTime'];
    DateTime endTimeDate = endTimeTimestamp.toDate();
    String formattedEndTime = DateFormat('hh:mm a').format(endTimeDate);
    
    // bool isResubmit = widget.fields.containsKey('resubmitAt');
    // Timestamp resubmitAtTimestamp = widget.fields['resubmitAt'];
    // DateTime resubmitAtDate = resubmitAtTimestamp.toDate();
    // String formattedResubmitAt = DateFormat('d MMMM yyyy, hh:mm a').format(resubmitAtDate);
    bool isResubmit = widget.fields.containsKey('resubmitAt');
    String formattedResubmitAt = '';
    if (isResubmit) {
      Timestamp resubmitAtTimestamp = widget.fields['resubmitAt'];
      DateTime resubmitAtDate = resubmitAtTimestamp.toDate();
      formattedResubmitAt = DateFormat('d MMMM yyyy, hh:mm a').format(resubmitAtDate);
    }

    bool isReason = widget.fields.containsKey('reason');

    return Scaffold(
      appBar: AppBar(title: Text('Review Proposal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showApprovalDialog(context),
        child: Icon(Icons.library_add_check_outlined),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text('Title:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['title']),
            ),
            ListTile(
              title: Text('Date:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['date']),
            ),
            ListTile(
              title: Text('Start Time:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              //subtitle: Text(widget.fields['startTime'] ?? 'Not specified'),
              subtitle: Text(formattedStartTime),
            ),
            ListTile(
              title: Text('End Time:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              //subtitle: Text(widget.fields['endTime'] ?? 'Not specified'),
              subtitle: Text(formattedStartTime),
            ),
            ListTile(
              title: Text('Place:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['place'] ?? 'Not specified'),
            ),
            ListTile(
              title: Text('By:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['submittedBy']),
            ),
            // ListTile(
            //   title: Text('Submitted at:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            //   subtitle: Text(formattedCreatedAt),
            // ),
            //if(isResubmit)
            ListTile(
              title: Text(
                isResubmit ? 'Resubmit at:' : 'Submitted at:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isResubmit ? formattedResubmitAt : formattedCreatedAt,
              ),
            ),
            ListTile(
              title: Text('Status:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['status'] ?? 'No reason provided'),
            ),
            if(isReason)
            ListTile(
              title: Text('Reason:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['reason'] ?? 'No reason provided'),
            ),
            ListTile(
              title: Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['description'] ?? 'No description provided'),
            ),
          ],
        ),
      ),
    );
  }
}
