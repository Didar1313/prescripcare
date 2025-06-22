import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void uploadAmbulanceDataToFirestore() async {
  try {
    // Pick the JSON file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      // Read the JSON file
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> ambulances = jsonDecode(jsonString);

      // Reference Firebase Firestore
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Loop through the ambulance list and add to batch
      for (var ambulance in ambulances) {
        final docRef = firestore.collection('ambulance_services').doc(ambulance['id'].toString());
        batch.set(docRef, {
          'name': ambulance['name'],
          'phone': ambulance['phone'],
          'address': ambulance['address'],
        });
      }

      // Commit the batch
      await batch.commit();
      print("Ambulance data uploaded successfully!");
    } else {
      print("No file selected.");
    }
  } catch (e) {
    print("Error uploading ambulance data: $e");
  }
}
