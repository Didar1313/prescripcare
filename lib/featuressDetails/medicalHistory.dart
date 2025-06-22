import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../reportPrescription/reportPresDetailsScreen.dart';

class MedicalHistory extends StatefulWidget {
  const MedicalHistory({super.key});

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  String selectedTab = 'Report'; // Track selected tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Update selectedTab when tab changes
          selectedTab = _tabController.index == 0 ? 'Report' : 'Prescription';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Add a new doctor to the list
  Future<void> _addNewDoctor() async {
    String? name = await _showDoctorNameDialog('');
    if (name != null && name.isNotEmpty) {
      await _addDoctorToFirestore(name);
    }
  }

  // Show dialog to input doctor name
  Future<String?> _showDoctorNameDialog(String existingName) async {
    String? doctorName;
    TextEditingController doctorNameController = TextEditingController(text: existingName);
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Doctor\'s Name'),
          content: TextField(
            controller: doctorNameController,
            decoration: const InputDecoration(hintText: 'Doctor\'s Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                doctorName = doctorNameController.text;
                doctorNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    return doctorName;
  }

  // Add the doctor to Firestore
  Future<void> _addDoctorToFirestore(String name) async {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    String tab = selectedTab;  // Use selected tab (Report or Prescription)

    DocumentReference newDoctorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail)
        .collection('doctor') // Create a doctors collection
        .doc();

    await newDoctorRef.set({'doctorName': name});

    // Automatically create a sub-collection for images (reports and prescriptions)
    await newDoctorRef.collection('images').add({});
  }

  // Upload image for a doctor
  Future<void> _uploadImage(String doctorId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload image to Firebase Storage
      String filePath = 'doctor/$doctorId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      File file = File(image.path);
      try {
        // Upload image to Firebase Storage
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref(filePath)
            .putFile(file);

        // Get the download URL of the image
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Store image URL in Firestore under the doctor's collection
        String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
        DocumentReference doctorRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserEmail)
            .collection('doctor')
            .doc(doctorId);

        // Add the image URL to the 'images' subcollection
        await doctorRef.collection('images').add({'imageUrl': imageUrl});
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
  // Display the list of doctors
  // Display the list of doctors
  Widget _buildDoctorListView() {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserEmail)
          .collection('doctor')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var doctorDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: doctorDocs.length,
          itemBuilder: (context, index) {
            var doctorData = doctorDocs[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text(
                  doctorData['doctorName'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Tap to see reports & prescriptions'),
                onTap: () {
                  _viewDoctorDetails(doctorData.id);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteDoctor(doctorData.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// Function to delete a doctor entry
  Future<void> _deleteDoctor(String doctorId) async {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    // Confirm before deleting
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: const Text('Are you sure you want to delete this doctor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // Delete the doctor document from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserEmail)
          .collection('doctor')
          .doc(doctorId)
          .delete();
    }
  }


  // Navigate to view doctor details (reports and prescriptions)
  Future<void> _viewDoctorDetails(String doctorId) async {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    DocumentReference doctorDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail)
        .collection('doctor')
        .doc(doctorId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPresDetailsScreen(
          doctorDocRef: doctorDocRef,
        ),
      ),
    );
  }

  // Build the UI for Medical History (Doctor List)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text(
          'Medical History',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: _buildDoctorListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDoctor,
        child: const Icon(Icons.person_add, color: Colors.white),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

