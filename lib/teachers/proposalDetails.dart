import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventmanagement/teachers/editProposal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProposalDetails extends StatefulWidget {
  final Map<String, dynamic> fields;
  final String proposalId;

  const ProposalDetails(
      {Key? key, required this.fields, required this.proposalId})
      : super(key: key);

  @override
  State<ProposalDetails> createState() => _ProposalDetailsState();
}

class _ProposalDetailsState extends State<ProposalDetails> {
  @override
  Widget build(BuildContext context) {
    Timestamp createdAtTimestamp = widget.fields['createdAt'];
    DateTime createdAtDate = createdAtTimestamp.toDate();
    String formattedCreatedAt =
        DateFormat('d MMMM yyyy, hh:mm a').format(createdAtDate);

    Timestamp startTimeTimestamp = widget.fields['startTime'];
    DateTime startTimeDate = startTimeTimestamp.toDate();
    String formattedStartTime = DateFormat('hh:mm a').format(startTimeDate);

    Timestamp endTimeTimestamp = widget.fields['endTime'];
    DateTime endTimeDate = endTimeTimestamp.toDate();
    String formattedEndTime = DateFormat('hh:mm a').format(endTimeDate);

    String status = widget.fields['status'];
    bool showReason = status == 'Need changes' || status == 'Rejected';

    bool showEdited = widget.fields.containsKey('editedAt');

    bool isPending = widget.fields['status'] == 'Pending' ||  widget.fields['status'] =='Need changes';

    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        // actions: [
        //   if (isPending)
        //   IconButton(
        //       onPressed: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //             builder: (BuildContext context) => EditProposalScreen(
        //                 proposalId: widget.proposalId, fields: widget.fields)));
        //       },
        //       icon: Icon(Icons.edit))
        // ],
      ),
      floatingActionButton: isPending ? FloatingActionButton(onPressed: (){
        Navigator.of(context).push(MaterialPageRoute(
                         builder: (BuildContext context) => EditProposalScreen(
                             proposalId: widget.proposalId, fields: widget.fields)));
      }, child: Icon(Icons.edit),) : null,
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text('Title:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['title']),
            ),
            ListTile(
              title: Text('Submitted at:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(formattedCreatedAt),
            ),
            if (showEdited)
              ListTile(
                title: Text(
                  'Edited at:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('d MMMM yyyy, hh:mm a').format(
                    (widget.fields['editedAt'] as Timestamp).toDate(),
                  ),
                ),
              ),
            ListTile(
              title: Text('Event Date:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['date']),
            ),
            ListTile(
              title: Text('Start Time:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(formattedStartTime),
            ),
            ListTile(
              title: Text('End Time:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(formattedEndTime),
            ),
            ListTile(
              title: Text('Place:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['place'] ?? 'Not specified'),
            ),
            ListTile(
              title: Text('Status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.fields['status']),
            ),
            if (showReason)
              ListTile(
                title: Text('Reason:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(widget.fields['reason'] ?? 'No reason provided'),
              ),
            ListTile(
              title: Text('Description:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(
                  widget.fields['description'] ?? 'No description provided'),
            ),
          ],
        ),
      ),
    );
  }
}
