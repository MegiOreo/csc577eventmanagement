import 'package:eventmanagement/teachers/editProposal.dart';
import 'package:eventmanagement/teachers/proposalDetails.dart';
import 'package:eventmanagement/teachers/proposalScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import '../login/auth.dart';
import '../login/widget_tree.dart';

class ProposedEventsScreen extends StatefulWidget {
  const ProposedEventsScreen({Key? key}) : super(key: key);

  @override
  State<ProposedEventsScreen> createState() => _ProposedEventsScreenState();
}

class _ProposedEventsScreenState extends State<ProposedEventsScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth _auth = Auth();

  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      setState(() {
        userName = userDoc['name'];
      });
    } catch (e) {
      print('Error fetching user name: $e');
    }}

  Future<void> signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
          (route) => false, // This line removes all routes in the stack
    );
  }

  Widget _proposalContainer(String proposalId, Map<String, dynamic> fields) {
    Timestamp createdAtTimestamp = fields['createdAt'];
    DateTime createdAtDate = createdAtTimestamp.toDate();
    String formattedCreatedAt = DateFormat('d MMMM yyyy, hh:mm a').format(createdAtDate);

    bool isPending = fields['status'] == 'Pending' ||  fields['status'] =='Need changes';
    bool isEdited = fields.containsKey('editedAt');

    //return Slidable(
      // key: ValueKey(proposalId),
      // endActionPane: ActionPane(
      //   motion: DrawerMotion(),
      //   children: [
      //     if (isPending)
      //       SlidableAction(
      //         onPressed: (BuildContext context) {
      //           Navigator.of(context).push(
      //             MaterialPageRoute(
      //               builder: (BuildContext context) => EditProposalScreen(proposalId: proposalId,
      //                 fields: fields,),
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
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => ProposalDetails(proposalId: proposalId, fields: fields),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.14,
            decoration: BoxDecoration(
              color: getStatusColor(_selectedStatus),//Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                 // decoration: BoxDecoration(color: Colors.green),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fields['title'],
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(fields['date']),
                        SizedBox(height: MediaQuery.sizeOf(context).height*0.01,),
                        Text('Submitted at ' + formattedCreatedAt),

                        if(isEdited)
                        Text('Edited')
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(fields['status'], textAlign: TextAlign.center,),
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

  Future<void> navProposal() async {
    //await Auth().registerTeacher()
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProposalScreen()));
  }

  void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                signOut();
              },
            ),
          ],
        );
      },
    );
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

  late String _selectedStatus = 'Pending'; // Default status

  void _setStatus(String status) {
    setState(() {
      _selectedStatus = status;
      //_selectedStatus = widget.selectedStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.lightGreen,
              height: 2.0,
            )),
        //backgroundColor: Colors.yellowAccent,
        title: Text('Proposal', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold,),),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout),
        //     onPressed: () {
        //       print('Logout button pressed');
        //       signOut();
        //     },
        //   ),
        // ],
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProposalScreen()));
      //   },
      //   child: Icon(Icons.add),
      // ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: userName != null ? Text(userName!) : Text('Loading...'),
              accountEmail: Text(_auth.currentUser!.email ?? 'No email'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName != null ? userName![0] : '',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            // ListTile(
            //   leading: Icon(Icons.home),
            //   title: Text('Home'),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
              ),
              child: ListTile(
                leading: Icon(Icons.event),
                title: Text('Propose Event'),
                onTap: () {//n
                  Navigator.pop(context);
                  navProposal();
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
              ),
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  showLogoutConfirmationDialog();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.sizeOf(context).width*0.2,
        height: MediaQuery.sizeOf(context).height*0.08,
        //decoration: BoxDecoration(color: Colors.blue),
        child: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.lightGreen,
          //foregroundColor: Colors.white,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          children: [
            SpeedDialChild(
                child: Icon(Icons.logout),
                label: 'Logout',
                onTap: showLogoutConfirmationDialog//signOut,
            ),
            SpeedDialChild(
                child: Icon(Icons.add_card),
                label: 'Propose Event',
                onTap: navProposal//signOut,//_registerTeacher,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('testproposal')
              //.collection('userProposal')
              .doc(_auth.currentUser!.uid)
              .collection('proposals')
              .where('status', isEqualTo: _selectedStatus)
              .orderBy("date", descending: false)
              .orderBy('startTime', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              String message;
              switch (_selectedStatus) {
                case 'Pending':
                  message = 'No pending review proposal(s)';
                  break;
                case 'Reviewing':
                  message = 'No proposal(s) on review yet';
                  break;
                case 'Approved':
                  message = 'No approved proposal(s)';
                  break;
                case 'Rejected':
                  message = 'No rejected proposal(s)';
                  break;
                default:
                  message = 'No proposal(s) need changes.';
              }
              return Center(child: Text(message));
            }

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 100),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // if (index == snapshot.data!.docs.length) {
                          //   return Container(height: MediaQuery.sizeOf(context).height*0.08,);  // Adjust the height as needed
                          // }
                          DocumentSnapshot proposal = snapshot.data!.docs[index];
                          return _proposalContainer(proposal.id, proposal.data() as Map<String, dynamic>);
                          // DocumentSnapshot proposal = snapshot.data!.docs[index];
                          // return _proposalContainer(proposal.id, proposal.data() as Map<String, dynamic>);
                        },
                      ),
                    ),
                    //SizedBox(height: MediaQuery.sizeOf(context).height*0.08,)
                  ],
                );
            }
          },
        ),
      ),
    );
  }

}
