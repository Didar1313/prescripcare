import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<Favorite> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> favoriteDoctors = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  void _fetchFavorites() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .collection('favorites')
          .get();

      setState(() {
        favoriteDoctors = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;  // Assign document ID to 'id'
          return data;
        }).toList();
      });
    }
  }



  void _deleteFavorite(String doctorId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (doctorId != null && doctorId.isNotEmpty) {
        // Delete from Firestore only if doctorId is not null or empty
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .collection('favorites')
            .doc(doctorId)
            .delete();

        // Remove from the list
        setState(() {
          favoriteDoctors.removeWhere((doctor) => doctor['id'] == doctorId);
        });
      } else {
        // Handle case where doctorId is null or empty
        print('Doctor ID is null or empty');
      }
    }
  }


  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not make the phone call';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
        backgroundColor: Colors.blue[500],
      ),
      body: ListView.builder(
        itemCount: favoriteDoctors.length,
        itemBuilder: (context, index) {
          final doctor = favoriteDoctors[index];
          bool isEven = index % 2 == 0;

          // Check if doctor['contact']['phone'] is a List and get the first phone number
          String phone = '';
          if (doctor['contact'] != null && doctor['contact']['phone'] is List) {
            phone = doctor['contact']['phone'][0]; // Get the first phone number if it's a list
          } else if (doctor['contact'] != null && doctor['contact']['phone'] is String) {
            phone = doctor['contact']['phone']; // If it's already a string, use it directly
          }

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isEven ? Colors.blue[50] : Colors.white,
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                doctor['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      doctor['specialization'] ?? 'Specialization not available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (phone.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.phone, color: Colors.green),
                      onPressed: () => _makePhoneCall(phone),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[600],
                ),
                onPressed: () {
                  // Confirm delete action
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Favorite'),
                        content: Text('Are you sure you want to delete this doctor from your favorites?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Check if doctor['id'] is not null or empty before calling _deleteFavorite
                              if (doctor['id'] != null && doctor['id'].isNotEmpty) {
                                _deleteFavorite(doctor['id']);
                              } else {
                                print('Doctor ID is null or empty');
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

            ),
          );
        },
      ),
    );
  }
}
