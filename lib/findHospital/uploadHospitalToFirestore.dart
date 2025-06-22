import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void uploadHospitalsToFirestore() async {
  // Pick the JSON file
  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
  if (result != null) {
    // Read the JSON file
    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    // Reference Firebase Firestore
    final firestore = FirebaseFirestore.instance;

    // Loop through the divisions and add hospitals
    for (var division in jsonData['divisions']) {
      String divisionName = division['name'];
      List hospitals = division['hospitals'];

      // Save division and its hospitals to Firestore
      for (var hospital in hospitals) {
        await firestore.collection('hospitals').add({
          'division': divisionName,
          'hospital': hospital['name'],
          'address': hospital['address'],
          'contact': hospital['contact'],
          'services': hospital['services'],
        });
      }
    }
    print("Hospitals uploaded successfully!");
  } else {
    print("No file selected.");
  }
}
