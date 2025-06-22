import 'package:prescripcare/findDoctor/doctorDetailScreen.dart';
import 'package:prescripcare/findDoctor/uploadDoctorsToFirestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSearchScreen extends StatefulWidget {
  @override
  _DoctorSearchScreenState createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  String searchQuery = "";
  String selectedSpecialization = "";

  final List<String> specializations = [
    'All',
    'Medicine',
    'Cardiology',
    'Neurology',
    'Pediatrics',
    'Eye Surgery',
    'Orthopedic Surgery',
    'Gynecology',
    'Dermatology',
    'ENT',
    'General Surgery',
  ];

  Stream<List<Map<String, dynamic>>> searchDoctors(String query, String specialization) {
    final firestore = FirebaseFirestore.instance;

    return firestore.collection('doctors').snapshots().map((snapshot) {
      final allDoctors = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      return allDoctors.where((doctor) {
        final name = doctor['name']?.toLowerCase() ?? '';
        final doctorSpecialization = doctor['specialization']?.toLowerCase() ?? '';
        final searchText = query.toLowerCase();
        final specializationMatch = specialization.isEmpty || specialization == 'All'
            ? true
            : doctorSpecialization.contains(specialization.toLowerCase());
        return name.contains(searchText) && specializationMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Find a Doctor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],

      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by Doctor's Name",
                  prefixIcon: Icon(Icons.search, color: Colors.blue[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.blue[100],
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: specializations.length,
                itemBuilder: (context, index) {
                  final specialization = specializations[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(specialization),
                      selected: selectedSpecialization == specialization,
                      onSelected: (selected) {
                        setState(() {
                          selectedSpecialization = selected ? specialization : '';
                        });
                      },
                      selectedColor: Colors.blue[500],
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: selectedSpecialization == specialization ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: searchDoctors(searchQuery, selectedSpecialization),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.blue[500]));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No doctors found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  final doctors = snapshot.data!;
                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(15),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue[500],
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            title: Text(
                              doctor['name'] ?? 'No Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[500],
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              doctor['specialization'] ?? 'Specialization not available',
                              style: TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[500]),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailsScreen(doctor: doctor),
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
