import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void uploadDoctorsToFirestore() async {
  try {
    // Pick the JSON file
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json']
    );

    if (result != null) {
      // Read the JSON file
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> doctors = jsonDecode(jsonString);

      // Reference Firebase Firestore
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Loop through the doctor list and add to batch
      for (var doctor in doctors) {
        final docRef = firestore.collection('doctors').doc(doctor['id'].toString());
        batch.set(docRef, doctor);
      }

      // Commit the batch
      await batch.commit();
      print("Doctors uploaded successfully!");
    } else {
      print("No file selected.");
    }
  } catch (e) {
    print("Error uploading doctors: $e");
  }
}
