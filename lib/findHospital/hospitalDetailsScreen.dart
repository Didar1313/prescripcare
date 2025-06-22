import 'package:prescripcare/Authenticate/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> hospital;

  const HospitalDetailsScreen({required this.hospital, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          hospital['hospital'] ?? 'Hospital Details',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
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
                // Hospital Info
                Card(
                  color: Colors.white,
                  elevation: 8,
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
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hospital['hospital'] ?? 'Not Available',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getFormattedServices(hospital['services']),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Contact Details Section
                Card(
                  color: Colors.white,
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailRow(
                          Icons.location_on,
                          "Address",
                          hospital['address'],
                        ),
                        buildDetailRow(
                          Icons.phone,
                          "Contact",
                          _getFormattedContact(hospital['contact']),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Premium Design Buttons
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
                                if (hospital['contact'] != null) {
                                  final contact = hospital['contact'] is List
                                      ? hospital['contact'][0]
                                      : hospital['contact'];
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
                                if (hospital['address'] != null) {
                                  final query =
                                      Uri.encodeComponent(hospital['address']!);
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
                                if (hospital['address'] != null) {
                                  final query = Uri.encodeComponent(
                                      "pharmacies near ${hospital['address']!}");
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
                                  const Icon(Icons.local_pharmacy,
                                      color: Colors.blue, size: 36),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: const Text(
                                      "Nearby Pharmacy",
                                      style: TextStyle(
                                          color: Colors.black87, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Card for Search the Hospital Button
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
                                if (hospital['address'] != null) {
                                  final query = Uri.encodeComponent("restaurants near ${hospital['address']!}");
                                  final url = "https://www.google.com/maps/search/?api=1&query=$query";
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
                                  const Icon(Icons.restaurant, color: Colors.blue, size: 36),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: const Text(
                                      "Nearby Restaurants",
                                      style: TextStyle(color: Colors.black87, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedServices(dynamic services) {
    if (services is List && services.isNotEmpty) {
      return services.join(', ');
    }
    if (services is String) {
      return services;
    }
    return 'Services Not Available';
  }

  String _getFormattedContact(dynamic contact) {
    if (contact is List && contact.isNotEmpty) {
      return contact.join(', ');
    }
    if (contact is String) {
      return contact;
    }
    return 'Contact Not Available';
  }

  Widget buildDetailRow(IconData icon, String title, String? value) {
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
                      text: value ?? 'Not Available',
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
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
