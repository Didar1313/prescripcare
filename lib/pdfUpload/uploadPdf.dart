import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadJsonToFirestore() async {
  try {
    // Allow the user to pick a JSON file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Only allow JSON files
    );

    if (result != null) {
      // Get the file path
      String filePath = result.files.single.path!;
      File file = File(filePath);

      // Read the file contents
      String fileContents = await file.readAsString();

      // Parse the JSON
      List<dynamic> jsonData = json.decode(fileContents);

      // Reference to your Firestore collection
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('your_collection_name');

      // Upload data to Firestore
      for (var entry in jsonData) {
        await collectionRef.add(entry); // Add each JSON object to Firestore
      }

      print("Data uploaded successfully!");
    } else {
      print("File selection canceled.");
    }
  } catch (e) {
    print("Error uploading JSON to Firestore: $e");
  }
}
