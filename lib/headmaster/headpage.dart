import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventmanagement/headmaster/headmhomescreen.dart';
import 'package:eventmanagement/headmaster/proposals/allProposals.dart';
import 'package:eventmanagement/headmaster/teachersList/registerTeacher.dart';
import 'package:eventmanagement/headmaster/teachersList/teachersList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../login/auth.dart';
import '../login/widget_tree.dart';

class HeadMPage extends StatefulWidget {
  const HeadMPage({super.key});

  @override
  State<HeadMPage> createState() => _HeadMPageState();
}

class _HeadMPageState extends State<HeadMPage> {
  int _currentIndex = 0; //start

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
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      setState(() {
        userName = userDoc['name'];
      });
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  final List<Widget> _pages = [
    HeadMHomeScreen(),
    AllProposalScreen(
      selectedStatus: 'Pending',
    ),
    Teacherslist(),
  ];

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
      (route) => false,
    );
  }

  Future<void> registerTeacher() async {
    //await Auth().registerTeacher()
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RegisterTeacherScreen()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIIT AS-SYAKIRIN'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () {
        //       print('Logout button pressed');
        //       signOut();
        //     },
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName:
                  userName != null ? Text(userName!) : Text('Loading...'),
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
                leading: Icon(Icons.person_add),
                title: Text('Register teacher account'),
                onTap: () {
                  Navigator.pop(context);
                  registerTeacher();
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
      //floatingActionButton: FloatingActionButton(onPressed: (){}, child: Icon(Icons.menu),),
      floatingActionButton: Container(
        height: MediaQuery.sizeOf(context).height * 0.09,
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.2,
          height: MediaQuery.sizeOf(context).height * 0.08,
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
                  onTap: showLogoutConfirmationDialog //signOut,
                  ),
              SpeedDialChild(
                  child: Icon(Icons.person_add),
                  label: 'Register Teacher',
                  onTap: registerTeacher //signOut,//_registerTeacher,
                  ),
            ],
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 1))
            //color: Color.fromARGB(255, 140, 8, 8)
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.5),
            //     spreadRadius: 5,
            //     blurRadius: 7,
            //     offset: Offset(0, 3), // changes position of shadow
            //   ),
            // ],
            ),
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
              selectedColor: Colors.teal,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.file_open),
              title: const Text("Proposals"),
              selectedColor: Color.fromARGB(255, 193, 168, 61),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_pin_rounded),
              title: const Text("Teachers"),
              selectedColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
