import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({required this.doctor, Key? key}) : super(key: key);

  @override
  _DoctorDetailsScreenState createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool isFavorite = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // Check if the doctor is already in the user's favorites
  void _checkIfFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .collection('favorites')
          .doc(widget.doctor['name'])
          .get();
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  // Add or remove from favorites in Firebase
  void _toggleFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .collection('favorites')
          .doc(widget.doctor['name']);

      if (isFavorite) {
        // Remove from favorites
        await favoritesRef.delete();
      } else {
        // Add to favorites
        await favoritesRef.set({
          'name': widget.doctor['name'],
          'specialization': widget.doctor['specialization'],
          'clinic': widget.doctor['clinic'],
          'contact': widget.doctor['contact'],
        });
      }

      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite ? 'Added to Bookmarks' : 'Removed from Bookmarks'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.doctor['name'] ?? 'Doctor Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border,color: Colors.deepOrange,),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Section
                Card(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.blue[500],
                          child: Icon(Icons.person, color: Colors.white, size: 100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.doctor['name'] ?? 'Not Available',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.doctor['specialization'] ?? 'Specialization Not Available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Details Section
                Card(
                  elevation: 8,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailRow(Icons.school, "Qualifications", widget.doctor['qualifications'].join(", ")),
                        buildDetailRow(Icons.business, "Institution", widget.doctor['institution']),
                        buildDetailRow(Icons.local_hospital, "Clinic", widget.doctor['clinic']),
                        buildDetailRow(Icons.location_on, "Address", widget.doctor['address']),
                        buildDetailRow(Icons.phone, "Phone", widget.doctor['contact']['phone'].join(", ")),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    // Row for Call and Location Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Card for Call Button
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 130, // Set a fixed width for uniformity
                            height: 130, // Set a fixed height for uniformity
                            child: ElevatedButton(
                              onPressed: () async {
                                if (widget.doctor['contact']['phone'] != null) {
                                  final contact = widget.doctor['contact']['phone'] is List
                                      ? widget.doctor['contact']['phone'][0]
                                      : widget.doctor['contact']['phone'];
                                  final url = "tel:$contact";
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.phone,
                                      color: Colors.blue, size: 36),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Call",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Card for Location Button
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 130, // Set a fixed width for uniformity
                            height: 130, // Set a fixed height for uniformity
                            child: ElevatedButton(
                              onPressed: () async {
                                if (widget.doctor['address'] != null) {
                                  final query =
                                  Uri.encodeComponent(widget.doctor['address']!);
                                  final url =
                                      "https://www.google.com/maps/search/?api=1&query=$query";
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.blue, size: 36),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Location",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row for Nearby Pharmacy and Search the Hospital Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Card for Nearby Pharmacy Button
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 130, // Set a fixed width for uniformity
                            height: 130, // Set a fixed height for uniformity
                            child: ElevatedButton(
                              onPressed: () async {
                                if (widget.doctor['name'] != null) {
                                  final query = Uri.encodeComponent(widget.doctor['name']);
                                  final url = "https://www.google.com/search?q=$query";
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.blue, size: 36),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Doctor Info",
                                    style: TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ]
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String title, dynamic value) {
    String displayValue = '';
    if (value != null) {
      if (value is List && value.isNotEmpty) {
        displayValue = value.join(", ");
      } else if (value is String && value.isNotEmpty) {
        displayValue = value;
      } else {
        displayValue = 'Not Available';
      }
    } else {
      displayValue = 'Not Available';
    }
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.blue[500],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: displayValue,
                      style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
