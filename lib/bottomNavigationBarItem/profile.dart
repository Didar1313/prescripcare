import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prescripcare/splashScreen/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Upload the selected image to Firebase Storage
      final storageRef = FirebaseStorage.instanceFor(bucket: 'ecommerceapp-7cd08.appspot.com')
          .ref()
          .child('profile_images')
          .child('${currentUser.uid}.jpg');

      try {
        await storageRef.putFile(File(pickedFile.path));
        final downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email)
            .update({'photoUrl': downloadUrl});
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  // Method to show the edit name dialog
  Future<String> _editNameDialog(BuildContext context, String currentName) async {
    TextEditingController controller = TextEditingController(text: currentName);
    String newName = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Name"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                newName = controller.text;
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );

    return newName;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('No user is currently logged in.')),
      );
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.email);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: userDocRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('User data not found.');
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>?;
                    final photoUrl = userData != null && userData['photoUrl'] != null && userData['photoUrl'].isNotEmpty
                        ? userData['photoUrl']
                        : null;
                    final name = userData?['name'] ?? "Name not available";

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                            child: photoUrl == null
                                ? Icon(Icons.person, size: 70, color: Colors.blueAccent)
                                : null,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () async {
                            String newName = await _editNameDialog(context, name);
                            if (newName.isNotEmpty) {
                              // Update name in Firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.email)
                                  .update({'name': newName});
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10.w),
                              Icon(Icons.edit, color: Colors.blueAccent),
                            ],
                          ),
                        ),
                        Divider(color: Colors.blueAccent, thickness: 1),
                        SizedBox(height: 10.h),
                        _buildInfoRow(Icons.date_range, 'Birth Date', userData?['birth'] ?? 'N/A', 'birth'),
                        _buildInfoRow(Icons.monitor_weight, 'Weight', userData?['weight'] ?? 'N/A', 'weight'),
                        _buildInfoRow(Icons.bloodtype_outlined, 'Blood Group', userData?['blood'] ?? 'N/A', 'blood'),
                        _buildInfoRow(Icons.phone, 'Phone', userData?['phone'] ?? 'N/A', 'phone'),
                        _buildInfoRow(Icons.email, 'Email', userData?['email'] ?? 'N/A', 'email'),
                        Divider(color: Colors.blueAccent, thickness: 1),
                      ],
                    );
                  },
                ),
                SizedBox(height: 30.h),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      bool confirmLogout = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Logout"),
                            content: Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text("Logout"),
                              ),
                            ],
                          );
                        },
                      ) ?? false;

                      if (confirmLogout) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SplashScreen())); // Replace with your splash screen route
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated _buildInfoRow method with edit option
  Widget _buildInfoRow(IconData icon, String label, String value, String field) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10.w),
          Text(
            "$label:",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.blueAccent),
            onPressed: () async {
              // Open dialog to edit the value
              String newValue = await _showEditDialog(context, value);
              if (newValue.isNotEmpty) {
                // Update the value in Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.email)
                    .update({field: newValue});
              }
            },
          ),
        ],
      ),
    );
  }

  // Method to show edit dialog
  Future<String> _showEditDialog(BuildContext context, String initialValue) async {
    TextEditingController controller = TextEditingController(text: initialValue);
    String newValue = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Information"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new value'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                newValue = controller.text;
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );

    return newValue;
  }
}
