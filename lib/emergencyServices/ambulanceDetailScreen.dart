import 'package:flutter/material.dart';

class AmbulanceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> ambulance;

  const AmbulanceDetailsScreen({Key? key, required this.ambulance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ambulance['name'] ?? 'Ambulance Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${ambulance['name']}", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Phone: ${ambulance['phone']}", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Address: ${ambulance['address']}", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
