import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Importing the intl package for date formatting

class ReportPresDetailsScreen extends StatefulWidget {
  final DocumentReference doctorDocRef;

  const ReportPresDetailsScreen({super.key, required this.doctorDocRef});

  @override
  State<ReportPresDetailsScreen> createState() => _ReportPresDetailsScreenState();
}

class _ReportPresDetailsScreenState extends State<ReportPresDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Upload image for report or prescription
  Future<void> _uploadImage(String tab) async {
    final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery);
    if (selectedImage == null) return;

    String imageUrl = await _uploadImageToFirebase(selectedImage);
    await widget.doctorDocRef.collection('images').add({
      'imageUrl': imageUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
      'tab': tab,
    });
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImageToFirebase(XFile image) async {
    FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'ecommerceapp-7cd08.appspot.com');
    String fileName = 'medical_images/${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg';
    final storageRef = storage.ref().child(fileName);

    await storageRef.putFile(File(image.path));
    return await storageRef.getDownloadURL();
  }

  // Build the UI to display the reports and prescriptions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'History Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[500],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Reports'),
              Tab(text: 'Prescriptions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildImagesListView('Report'),
                _buildImagesListView('Prescription'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _uploadImage(_tabController.index == 0 ? 'Report' : 'Prescription'),
        child: const Icon(Icons.add_a_photo, color: Colors.white),
        backgroundColor: Colors.blue[700],
      ),
    );
  }


// Update _buildImagesListView method to include long press gesture for deleting an image
  Widget _buildImagesListView(String tab) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.doctorDocRef.collection('images').where(
          'tab', isEqualTo: tab).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        var images = snapshot.data!.docs;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            var imageData = images[index];
            var timestamp = imageData['uploadedAt'] as Timestamp?;
            var formattedDate = timestamp != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                : 'Unknown';

            return GestureDetector(
              onLongPress: () =>
                  _showDeleteConfirmationDialog(
                      context, imageData.id, imageData['imageUrl']),
              onTap: () => _showImageDialog(context, imageData['imageUrl']),
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        imageData['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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

// Function to show the delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, String imageId,
      String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteImage(imageId, imageUrl);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

// Function to delete the image from Firestore and Firebase Storage
  Future<void> _deleteImage(String imageId, String imageUrl) async {
    // Delete image document from Firestore
    await widget.doctorDocRef.collection('images').doc(imageId).delete();

    // Delete image file from Firebase Storage
    FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'ecommerceapp-7cd08.appspot.com');
    Reference storageRef = storage.refFromURL(imageUrl);
    await storageRef.delete();
  }

// Show the image in a dialog
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(imageUrl),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
