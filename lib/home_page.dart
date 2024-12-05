import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // For Realtime Database
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'package:geolocator/geolocator.dart'; // Import geolocator

import 'activity_page.dart';
import 'login_screen.dart';
import 'profile_page.dart';
import 'confirm_location_page.dart';
import 'picture_report.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Function to fetch user data from Firebase
  Future<Map<String, String>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final databaseReference = FirebaseDatabase.instance.ref("users/$userId");

      // Fetching the user data from Firebase Realtime Database
      final snapshot = await databaseReference.once();
      final userData = snapshot.snapshot.value as Map<dynamic, dynamic>;

      return {
        'name': userData['name'] ?? 'Unknown',
        'mobile': userData['mobile'] ?? 'Unknown',
      };
    }
    return {'name': 'Guest', 'mobile': 'Unknown'};
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      // Request permission
      PermissionStatus newStatus = await Permission.location.request();
      if (newStatus.isGranted) {
        // Permission granted
        print('Location permission granted');
      } else {
        // Permission denied
        print('Location permission denied');
      }
    } else if (status.isGranted) {
      // Location permission already granted
      print('Location permission already granted');
    }
  }

  // Check if location services are enabled and request the user to turn it on if it's not
  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      // Location services are not enabled, ask the user to enable it
      _showLocationServiceDialog();
    } else {
      // If location services are enabled, proceed
      _requestLocationPermission();
    }
  }

  // Show dialog to prompt the user to enable location services
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to use this app.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and open the device location settings
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog without doing anything
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkLocationServices();  // Check if location services are enabled on app launch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFF880E4F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/text.png',
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                const Text(
                  'FIRE RESPONSE SYSTEM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: FutureBuilder<Map<String, String>>(
        future: _fetchUserData(), // Fetching user data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const Drawer(
              child: Center(child: Text('Error loading data')),
            );
          }
          if (snapshot.hasData) {
            final userData = snapshot.data!;
            return Drawer(
              child: Column(
                children: [
                  // Header section with gradient
                  Container(
                    padding: const EdgeInsets.only(top: 40, left: 20, bottom: 20),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB71C1C), Color(0xFF880E4F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 5),
                            Image.asset(
                              'assets/text.png',
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hello ${userData['name']}!',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          userData['mobile']!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Menu options
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.report, color: Colors.black),
                          title: const Text('Report'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.article, color: Colors.black),
                          title: const Text('News'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.history, color: Colors.black),
                          title: const Text('Activity'),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const ActivityPage()),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info, color: Colors.black),
                          title: const Text('Fire Safety Tips'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.account_circle, color: Colors.black),
                          title: const Text('Profile Account'),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfilePage()),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip, color: Colors.black),
                          title: const Text('Privacy Policy'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.black),
                          title: const Text('Log Out'),
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false, // Removes all previous routes
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Drawer(
              child: Center(child: Text('No data available')),
            );
          }
        },
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'), // Add your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Centered Call Button
          Center(
            child: GestureDetector(
              onTap: () {
                // Show overlay dialog with options "1" and "2"
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.black.withOpacity(0.8),
                      contentPadding: EdgeInsets.zero,
                      content: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Instruction Text
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                text: 'PRESS ',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                                children: [
                                  TextSpan(
                                    text: '1 ',
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: 'to call or PRESS '),
                                  TextSpan(
                                    text: '2 ',
                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: 'to capture and report fire.')
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Row of buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Button 1 - Call
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ConfirmLocationPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 30,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Telephone Icon background
                                      Icon(
                                        Icons.phone,
                                        size: 40, // Adjust size as needed
                                        color: Colors.white.withOpacity(0.3), // Semi-transparent white
                                      ),
                                      // Number "1" text
                                      const Text(
                                        '1',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Button 2 - Capture
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const PictureReportPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 30,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Camera Icon background
                                      Icon(
                                        Icons.camera_alt,
                                        size: 40, // Adjust size as needed
                                        color: Colors.black.withOpacity(0.2), // Semi-transparent dark color
                                      ),
                                      // Number "2" text
                                      const Text(
                                        '2',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'TAP FOR HELP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
