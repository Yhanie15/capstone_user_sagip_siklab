import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // For Realtime Database
import 'package:flutter/material.dart';
import 'dart:io'; // For File usage
import 'activity_page.dart';
import 'home_page.dart';

class SubmitPictureReport extends StatefulWidget {
  final File imageFile; // Image file passed from PictureReportPage

  const SubmitPictureReport({super.key, required this.imageFile});

  @override
  SubmitPictureReportState createState() => SubmitPictureReportState();
}

class SubmitPictureReportState extends State<SubmitPictureReport> {
  String senderName = 'Loading...'; // Variable to store sender's name
  bool isLoading = true; // To show loading state while fetching data

  // Function to fetch user data from Firebase Realtime Database
  Future<void> _fetchSenderName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final databaseReference = FirebaseDatabase.instance.ref("users/$userId");

        // Fetching the user data from Firebase Realtime Database
        final snapshot = await databaseReference.once();
        final userData = snapshot.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          senderName = userData['name'] ?? 'Unknown'; // Fetch the sender's name
          isLoading = false; // Data fetched, stop loading
        });
      } else {
        // If no user is logged in, set a default name
        setState(() {
          senderName = 'Guest';
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle errors (e.g., network issues)
      print("Error fetching sender's name: $e");
      setState(() {
        senderName = 'Error fetching name';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSenderName(); // Fetch sender name when the page loads
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thank You!'),
          content: const Text('Thank you for reporting. You will be redirected to the Activity Page to monitor your report.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityPage()),
                );
              },
              child: const Text('OK'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFF880E4F)], // Adjust colors for gradient
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
                  'assets/text.png', // Updated path for the logo
                  height: 25,
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
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'), // Add your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the image passed from PictureReportPage
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: widget.imageFile != null
                      ? Image.file(widget.imageFile)
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                // Display sender's name (or loading message if not fetched yet)
                isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Sender: $senderName\nCurrent Location: 1234567890', // Replace with actual location if needed
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                const SizedBox(height: 20),
                // Submit and Cancel buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showThankYouDialog(context); // Show thank you dialog on submit
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
