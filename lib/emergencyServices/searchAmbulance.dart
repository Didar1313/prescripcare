import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ambulanceDetailScreen.dart';

class AmbulanceSearchScreen extends StatefulWidget {
  @override
  _AmbulanceSearchScreenState createState() => _AmbulanceSearchScreenState();
}

class _AmbulanceSearchScreenState extends State<AmbulanceSearchScreen> {
  String searchQuery = ""; // To hold the search term

  // Stream to fetch ambulances from Firestore
  Stream<List<Map<String, dynamic>>> searchAmbulances(String query) {
    final firestore = FirebaseFirestore.instance;

    return firestore.collection('ambulance_services').snapshots().map((snapshot) {
      print("Fetched ${snapshot.docs.length} documents from Firestore.");
      final allAmbulances = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      return allAmbulances.where((ambulance) {
        final name = ambulance['name']?.toLowerCase() ?? '';
        final address = ambulance['address']?.toLowerCase() ?? '';
        final searchText = query.toLowerCase();

        return name.contains(searchText) || address.contains(searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find an Ambulance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by Ambulance Name or Address",
                  prefixIcon: Icon(Icons.search, color: Colors.blue[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.red,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim();
                  });
                },
              ),
            ),
            // Display Ambulances
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: searchAmbulances(searchQuery),
                builder: (context, snapshot) {
                  print("Snapshot State: ${snapshot.connectionState}");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.blue[500]));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: const Text(
                        "No ambulances found",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  }
                  final ambulances = snapshot.data!;
                  print("Ambulances: $ambulances");
                  return ListView.builder(
                    itemCount: ambulances.length,
                    itemBuilder: (context, index) {
                      final ambulance = ambulances[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue[500],
                              child: const Icon(Icons.local_hospital, color: Colors.white, size: 30),
                            ),
                            title: Text(
                              ambulance['name'] ?? 'No Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[500],
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              ambulance['address'] ?? 'Address not available',
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[500]),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AmbulanceDetailsScreen(ambulance: ambulance),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

