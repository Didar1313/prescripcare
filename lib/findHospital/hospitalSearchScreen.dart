import 'package:prescripcare/findHospital/uploadHospitalToFirestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'hospitalDetailsScreen.dart';

class HospitalSearchScreen extends StatefulWidget {
  @override
  _HospitalSearchScreenState createState() => _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  String searchQuery = " ";
  String selectedDivision = "All"; // Default selection (show all divisions)

  // Stream to fetch hospitals based on search query and selected division
  Stream<List<Map<String, dynamic>>> searchHospitals(String query, String division) {
    final firestore = FirebaseFirestore.instance;

    return firestore.collection('hospitals').snapshots().map((snapshot) {
      final allHospitals = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      return allHospitals.where((hospital) {
        final name = hospital['hospital']?.toLowerCase() ?? '';
        final hospitalDivision = hospital['division']?.toLowerCase() ?? '';
        final searchText = query.toLowerCase();

        // Check if division matches, or if "All" is selected
        final divisionMatch = division.isEmpty || division == 'All'
            ? true
            : hospitalDivision.contains(division.toLowerCase());

        // Return true if both conditions are satisfied
        return name.contains(searchText) && divisionMatch;
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Find a Hospital",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],

      ),
      body: Column(
        children: [
          // Search Input and Division Filter Row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Search Input Field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by Hospital's Name",
                      prefixIcon: Icon(Icons.search, color: Colors.blue[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.blue[500]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Division Dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: Colors.blue[500]!, width: 2),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: selectedDivision,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDivision = newValue!;
                      });
                    },
                    underline: SizedBox(),
                    isExpanded: false,
                    items: ["All", "Dhaka", "Chattogram", "Sylhet", "Rangpur", "Rajshahi", "Barishal"]
                        .map((division) {
                      return DropdownMenuItem<String>(
                        value: division,
                        child: Text(
                          division,
                          style: TextStyle(color: Colors.blue[500]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Hospital List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: searchHospitals(searchQuery, selectedDivision),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.blue[500]));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No hospitals found",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  );
                }
                final hospitals = snapshot.data!;
                return ListView.builder(
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue[500],
                            child: Icon(Icons.local_hospital, color: Colors.white),
                          ),
                          title: Text(
                            hospital['hospital'] ?? 'No Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[500],
                            ),
                          ),
                          subtitle: Text(
                            hospital['address'] ?? 'Address not available',
                            style: TextStyle(color: Colors.black87),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[500]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HospitalDetailsScreen(hospital: hospital),
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
    );
  }
}