import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../emergencyServices/uploadAmbulanceToFire.dart';

class EmergencyServices extends StatefulWidget {
  const EmergencyServices({super.key});

  @override
  State<EmergencyServices> createState() => _EmergencyServicesState();
}

class _EmergencyServicesState extends State<EmergencyServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Find a Ambulance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, color: Colors.white),
            onPressed: () {
              uploadAmbulanceDataToFirestore();
            },
          ),
        ],
      ),
    );
  }
}
