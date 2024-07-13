// import 'package:flutter/material.dart';
//
// class AllProposalScreen extends StatefulWidget {
//   const AllProposalScreen({super.key});
//
//   @override
//   State<AllProposalScreen> createState() => _AllProposalScreenState();
// }
//
// class _AllProposalScreenState extends State<AllProposalScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventmanagement/headmaster/proposals/reviewProposal.dart';
import 'package:flutter/material.dart';

class AllProposalScreen extends StatefulWidget {
  final selectedStatus;

  AllProposalScreen({super.key, this.selectedStatus});

  @override
  State<AllProposalScreen> createState() => _AllProposalScreenState();
}

class _AllProposalScreenState extends State<AllProposalScreen> {
  late String _selectedStatus;// = 'Pending'; // Default status
  //String _selectedStatus = widget.selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
  }

  void _setStatus(String status) {
    setState(() {
      _selectedStatus = status;
      //_selectedStatus = widget.selectedStatus;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Color.fromARGB(255, 193, 168, 61);
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Reviewing':
        return Colors.blueAccent;
      default:
        return Colors.orange; // Default color if the status doesn't match any of the expected values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proposals'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _setStatus,
            icon: Icon(Icons.filter_alt_outlined),
            itemBuilder: (BuildContext context) {
              return [
                {'text': 'Pending', 'icon': Icons.access_time},
                {'text': 'Reviewing', 'icon': Icons.timelapse},
                {'text': 'Approved', 'icon': Icons.check_circle},
                {'text': 'Rejected', 'icon': Icons.cancel},
                {'text': 'Need changes', 'icon': Icons.edit}
              ].map((item) {
                return PopupMenuItem<String>(
                  value: item['text'] as String,
                  child: Container(
                    color: getStatusColor(item['text'] as String),
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: 8),
                      leading: Icon(item['icon'] as IconData),
                      title: Text(item['text'] as String),
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Status: $_selectedStatus',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('proposals')
                  .where('status', isEqualTo: _selectedStatus)
                  .orderBy("date", descending: false)
                  .orderBy('startTime', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  String message;
                  switch (_selectedStatus) {
                    case 'Pending':
                      message = 'No unopened proposals. Check opened section.';
                      break;
                    case 'Reviewing':
                      message = 'No pending review. Check Pending section';
                      break;
                    case 'Approved':
                      message = 'No approved proposals yet';
                      break;
                    case 'Rejected':
                      message = 'No rejected proposals yet';
                      break;
                    default:
                      message = 'No proposals found.';
                  }
                  return Center(child: Text(message));
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 100),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot proposal = snapshot.data!.docs[index];
                    Map<String, dynamic> fields = proposal.data() as Map<String, dynamic>;
                    return _proposalContainer(proposal.id, fields);
                  },
                );
              },
            ),
          )

        ],
      ),
    );
  }

  Widget _proposalContainer(String proposalId, Map<String, dynamic> fields) {
    //bool isPending = fields['status'] == 'Pending';
    bool isResubmit = fields.containsKey('resubmitAt');

    //if (isPending) {
      void updateStatusToReviewing() async {
        String uid = fields['uid']; // Assuming 'uid' is present in fields
        //String _proposalId = proposalId; // Assuming 'proposalId' is present in fields

        // Update Firestore document
        try {
          await FirebaseFirestore.instance
              .collection('testproposal')
              .doc(uid)
              .collection('proposals')
              .doc(proposalId)
              .update({
            'status': 'Reviewing',
          });
          print('Status updated to opened successfully');
        } catch (e) {
          print('Error updating status: $e');
          // Handle error as needed
        }
      }
    //}


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          if (fields['status'] == 'Pending') {
            updateStatusToReviewing();
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => ReviewProposal(
                fields: fields,
                proposalId: proposalId,
              ),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.12,
          decoration: BoxDecoration(
            color: getStatusColor(_selectedStatus),//Colors.blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fields['title'] ?? 'No title',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      //Text(fields['date'] ?? 'No date'),
                      Row(
                        children: [
                          Text(
                            fields['date'] + " by ",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Expanded(
                            child: Text(
                              fields['submittedBy'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),


                        ],
                          //if(isResubmit)


                      ),
                      //isResubmit ? Text('Resubmit'),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.01,),
                      if (isResubmit) Text('Resubmited'),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(fields['status'] ?? 'No status'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}