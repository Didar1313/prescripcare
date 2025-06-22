import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DoctorSearch extends StatefulWidget {
  const DoctorSearch({super.key});

  @override
  State<DoctorSearch> createState() => _DoctorSearchState();
}

class _DoctorSearchState extends State<DoctorSearch> {
  List<Map<String, dynamic>> _allDoctors = []; // All doctors data
  List<Map<String, dynamic>> _filteredDoctors = []; // Filtered data for search
  String _searchQuery = ''; // Current search query

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  // Fetch doctor data from Firestore
  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('your_collection_name').get();
      List<Map<String, dynamic>> doctors =
      snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        _allDoctors = doctors;
        _filteredDoctors = doctors; // Initially, show all doctors
      });
    } catch (e) {
      print("Error fetching doctors: $e");
    }
  }

  // Filter doctors based on the search query
  void _filterDoctors(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredDoctors = _allDoctors.where((doctor) {
        final name = doctor['name']?.toLowerCase() ?? '';
        final specialization = doctor['specialization']?.toLowerCase() ?? '';
        return name.contains(_searchQuery) ||
            specialization.contains(_searchQuery);
      }).toList();
    });
  }

  // File picker for uploading files
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // File picked
      PlatformFile file = result.files.first;
      print("File path: ${file.path}");
      // You can now upload this file to Firebase Storage or process it further
    } else {
      print("No file selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _uploadFile, // Calling the file upload function
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterDoctors,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search doctors by name or specialization...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Suggestions or Doctor List
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSuggestions()
                : _buildDoctorList(), // Show suggestions if typing, otherwise full list
          ),
        ],
      ),
    );
  }

  // Build the list of suggestions while typing
  Widget _buildSuggestions() {
    return ListView.builder(
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return ListTile(
          title: Text(doctor['name'] ?? 'No name available'),
          subtitle: Text(doctor['specialization'] ?? 'No specialization available'),
          onTap: () {
            // Navigate to details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetailsScreen(doctor: doctor),
              ),
            );
          },
        );
      },
    );
  }

  // Build the full list of doctors when no search query
  Widget _buildDoctorList() {
    return ListView.builder(
      itemCount: _allDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _allDoctors[index];
        return ListTile(
          title: Text(doctor['name'] ?? 'No name available'),
          subtitle: Text(doctor['specialization'] ?? 'No specialization available'),
          onTap: () {
            // Navigate to details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetailsScreen(doctor: doctor),
              ),
            );
          },
        );
      },
    );
  }
}

// Doctor Details Page
class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor['name'] ?? 'No name available',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Specialization: ${doctor['specialization'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Chamber: ${doctor['chamber'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${doctor['address'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${doctor['phone'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Mobile: ${doctor['mobile'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Visiting Hours: ${doctor['visiting_hours'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
