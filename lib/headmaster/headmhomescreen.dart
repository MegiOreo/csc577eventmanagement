import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventmanagement/headmaster/proposals/allProposals.dart';
import 'package:eventmanagement/headmaster/proposals/reviewProposal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../login/auth.dart';
import '../login/widget_tree.dart';
import '../teachers/proposalDetails.dart';

class HeadMHomeScreen extends StatefulWidget {
  const HeadMHomeScreen({super.key});

  @override
  State<HeadMHomeScreen> createState() => _HeadMHomeScreenState();
}

class _HeadMHomeScreenState extends State<HeadMHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth _auth = Auth();

  //String _setProposalStatus = "";

  Widget _proposalContainer(String proposalId, Map<String, dynamic> fields) {
    bool isPending = fields['status'] == 'Pending';

    bool isResubmit = fields.containsKey('resubmitAt');

    void updateStatusToOpened() async {
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
        print('Status updated to reviewing successfully');
      } catch (e) {
        print('Error updating status: $e');
        // Handle error as needed
      }
    }

    // @override
    // void initState() {
    //   super.initState();
    //   // Update Firestore status to 'opened' when widget is initialized
    //   updateStatusToOpened();
    // }



    return
      // Slidable(
      // key: ValueKey(proposalId),
      // endActionPane: ActionPane(
      //   motion: const DrawerMotion(),
      //   children: [
      //     if (isPending)
      //       SlidableAction(
      //         onPressed: (BuildContext context) {
      //
      //           Navigator.of(context).push(
      //             MaterialPageRoute(
      //               builder: (BuildContext context) =>
      //                   ProposalDetails(fields: fields),
      //             ),
      //           );
      //         },
      //         backgroundColor: Colors.green,
      //         foregroundColor: Colors.white,
      //         icon: Icons.edit,
      //         label: 'Edit',
      //       ),
      //   ],
      // ),
      // child:
    Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            updateStatusToOpened();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    ReviewProposal(fields: fields, proposalId: proposalId),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.12,
            decoration: BoxDecoration(
              color: isPending ? Color.fromARGB(255, 193, 168, 61) : Colors.blueAccent,
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
                            // if(isResubmit)
                            // Expanded(
                            //   child: Text('Edited')
                            // ),

                          ],
                        ),

                        SizedBox(height: MediaQuery.sizeOf(context).height*0.01,),
                        if (isResubmit) Text('Resubmitetd'),

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
    //);
  }

  Widget _sectionTitle(String _secTitle) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(_secTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }

  Widget _latestProposedEvent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_sectionTitle('Latest Proposal')],
        ),
      ),
    );
  }

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
      (route) => false,
    );
  }

  Widget _sectionContainer(bool _isPendingSection) {
    //bool isPendingSection = _isPendingSection;
    Color backgroundColor = _isPendingSection ? Colors.pink : Colors.green;
    String _setStatus = _isPendingSection ? 'Pending' : 'Reviewing';//'Opened';//_setProposalStatus;
    String _sectionTitle = _isPendingSection ? 'To be review' : 'Continue review';


    //if (_isPendingSection){
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery
              .sizeOf(context)
              .width * 1,
          height: MediaQuery
              .sizeOf(context)
              .height * 0.56,
          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
          child: //Column(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
              child: Text(_sectionTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collectionGroup('proposals')
                      .where('status', isEqualTo: _setStatus)
                      .orderBy("date", descending: false)
                      .orderBy('startTime', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      default:
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No proposals found.'));
                        }
                        // Calculate the number of items to display initially
                        int initialItemCount = snapshot.data!.docs.length > 3 ? 3 : snapshot.data!.docs.length;

                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: initialItemCount,
                              itemBuilder: (context, index) {
                                DocumentSnapshot proposal = snapshot.data!.docs[index];
                                return _proposalContainer(
                                    proposal.id, proposal.data() as Map<String, dynamic>);
                              },
                            ),
                            if (snapshot.data!.docs.length > 3)
                              TextButton(
                                onPressed: () {
                                 Navigator.of(context).push(MaterialPageRoute(
                                   builder: (BuildContext context) =>
                                       AllProposalScreen(selectedStatus: _isPendingSection ? 'Pending' : 'Reviewing',),
                                 ),);
                                 //AllProposalScreen();
                                },
                                child: Text('See All (${snapshot.data!.docs.length})', style: TextStyle(color: Colors.white),),
                              ),
                          ],
                        );
                    }
                  },
                ),

              ),
            ],
          ),
        ),
      );
 // } else
 //      return Container(
 //        width: MediaQuery
 //            .sizeOf(context)
 //            .width * 1,
 //        height: MediaQuery
 //            .sizeOf(context)
 //            .height * 0.1,
 //        decoration: BoxDecoration(color: Colors.green),
 //        child: Column(),
 //      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Home'),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: const Icon(Icons.logout),
      //   //     onPressed: () {
      //   //       print('Logout button pressed');
      //   //       signOut();
      //   //     },
      //   //   ),
      //   // ],
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _sectionContainer(true),
              _sectionContainer(false),
              SizedBox(height: MediaQuery.sizeOf(context).height*0.08)
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
//
// import '../login/auth.dart';
// import '../login/widget_tree.dart';
// import '../teachers/proposalDetails.dart';
//
// class HeadMHomeScreen extends StatefulWidget {
//   const HeadMHomeScreen({super.key});
//
//   @override
//   State<HeadMHomeScreen> createState() => _HeadMHomeScreenState();
// }
//
// class _HeadMHomeScreenState extends State<HeadMHomeScreen> {
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Auth _auth = Auth();
//
//   Widget _proposalContainer(String proposalId, Map<String, dynamic> fields) {
//     bool isPending = fields['status'] == 'pending';
//
//     return Slidable(
//       key: ValueKey(proposalId),
//       endActionPane: ActionPane(
//         motion: DrawerMotion(),
//         children: [
//           if (isPending)
//             SlidableAction(
//               onPressed: (BuildContext context) {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (BuildContext context) => ProposalDetails(fields: fields),
//                   ),
//                 );
//               },
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               icon: Icons.edit,
//               label: 'Edit',
//             ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GestureDetector(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (BuildContext context) => ProposalDetails(fields: fields),
//               ),
//             );
//           },
//           child: Container(
//             width: MediaQuery.of(context).size.width * 1,
//             height: MediaQuery.of(context).size.height * 0.1,
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.7,
//                   // decoration: BoxDecoration(color: Colors.green),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           fields['title'],
//                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(fields['date']),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(fields['status']),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionTitle(String _secTitle){
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Text(_secTitle, style: TextStyle(fontSize: 24, fontWeight:FontWeight.bold)),
//     );
//   }
//
//   Widget _latestProposedEvent(){
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Container(
//         width: MediaQuery.sizeOf(context).width*1,
//         height: MediaQuery.sizeOf(context).height*0.3,
//         decoration: BoxDecoration(
//           color: Colors.blue,
//           borderRadius: BorderRadius.circular(16)
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _sectionTitle('Latest Proposal')
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> signOut() async {
//     await Auth().signOut();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const WidgetTree()),
//           (route) => false, // This line removes all routes in the stack
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () {
//               // Handle logout action here
//               print('Logout button pressed');
//               signOut();
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//           child:
//           // Column(
//           //   crossAxisAlignment: CrossAxisAlignment.start,
//           //         children: [
//           // _latestProposedEvent(),
//           // Container(),
//                     StreamBuilder<QuerySnapshot>(
//                       stream: _firestore
//                       //.collection('pending')
//                           .collection('userProposal')
//                           .doc(_auth.currentUser!.uid)
//                           .collection('proposals')
//                           .snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasError) {
//                           return Text('Error: ${snapshot.error}');
//                         }
//
//                         switch (snapshot.connectionState) {
//                           case ConnectionState.waiting:
//                             return Center(child: CircularProgressIndicator());
//                           default:
//                             return ListView.builder(
//                               itemCount: snapshot.data!.docs.length,
//                               itemBuilder: (context, index) {
//                                 DocumentSnapshot proposal = snapshot.data!.docs[index];
//                                 return _proposalContainer(proposal.id, proposal.data() as Map<String, dynamic>);
//                               },
//                             );
//                         }
//                       },
//                     ),
//                 //   ],
//                 // )
//       ),
//     );
//   }
// }
