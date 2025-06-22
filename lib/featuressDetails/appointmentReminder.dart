import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentReminder extends StatefulWidget {
  const AppointmentReminder({Key? key}) : super(key: key);

  @override
  State<AppointmentReminder> createState() => _AppointmentReminderState();
}

class _AppointmentReminderState extends State<AppointmentReminder> {
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();  // Added time controller
  DateTime? _selectedDate;

  final _firestore = FirebaseFirestore.instance;
  final String? _currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (_doctorController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _selectedDate != null &&
        _timeController.text.isNotEmpty) {  // Check if time is entered
      await _firestore
          .collection('users')
          .doc(_currentUserEmail)
          .collection('appointments')
          .add({
        'doctorName': _doctorController.text,
        'doctorPhone': _phoneController.text,
        'appointmentDate': _selectedDate,
        'appointmentTime': _timeController.text,  // Save time as well
        'notes': _notesController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearInputs();
      _showSuccessDialog('Appointment added successfully!');
    } else {
      _showErrorDialog('Please fill all the fields.');
    }
  }

  void _clearInputs() {
    _doctorController.clear();
    _phoneController.clear();
    _notesController.clear();
    _timeController.clear();  // Clear time input
    setState(() {
      _selectedDate = null;
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 40),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.error, color: Colors.red, size: 40),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppointment(String id) async {
    await _firestore
        .collection('users')
        .doc(_currentUserEmail)
        .collection('appointments')
        .doc(id)
        .delete();
    _showSuccessDialog('Appointment deleted.');
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
        const Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _deleteAppointment(id); // Call delete function
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _editAppointment(
      String id, Map<String, dynamic> appointmentData) async {
    _doctorController.text = appointmentData['doctorName'] ?? '';
    _phoneController.text = appointmentData['doctorPhone'] ?? '';
    _notesController.text = appointmentData['notes'] ?? '';
    _selectedDate = (appointmentData['appointmentDate'] as Timestamp).toDate();
    _timeController.text = appointmentData['appointmentTime'] ?? '';  // Get time for edit

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Appointment'),
        content: SizedBox(
          height: 350,
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_doctorController, 'Doctor Name', Icons.person),
                const SizedBox(height: 10),
                _buildTextField(_phoneController, 'Doctor Phone', Icons.phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _buildTextField(_notesController, 'Hospital', Icons.local_hospital),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Select Appointment Date'
                            : 'Selected: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTextField(_timeController, 'Appointment Time', Icons.access_time),  // Time input field
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_doctorController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty &&
                  _selectedDate != null &&
                  _timeController.text.isNotEmpty) {
                await _firestore
                    .collection('users')
                    .doc(_currentUserEmail)
                    .collection('appointments')
                    .doc(id)
                    .update({
                  'doctorName': _doctorController.text,
                  'doctorPhone': _phoneController.text,
                  'appointmentDate': _selectedDate,
                  'appointmentTime': _timeController.text,  // Save updated time
                  'notes': _notesController.text,
                });

                _clearInputs();
                Navigator.of(context).pop(); // Close the dialog
                _showSuccessDialog('Appointment updated successfully!');
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getAppointments() {
    return _firestore
        .collection('users')
        .doc(_currentUserEmail)
        .collection('appointments')
        .orderBy('appointmentDate')
        .snapshots();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          "Appointment Reminders",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                        _doctorController, 'Doctor Name', Icons.person),
                    const SizedBox(height: 10),
                    _buildTextField(
                        _phoneController, 'Doctor Phone', Icons.phone,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    _buildTextField(
                        _notesController, 'Hospital', Icons.local_hospital),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Select Appointment Date'
                                : 'Selected: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_timeController, 'Appointment Time', Icons.access_time),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveAppointment,
                      child: const Text(
                        'Add Appointment',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Appointments',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildAppointmentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(),
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No appointments added.'));
        }
        final appointments = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final appointmentData = appointment.data() as Map<String, dynamic>;
            return Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor: ${appointmentData['doctorName']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Phone: ${appointmentData['doctorPhone']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Date: ${appointmentData['appointmentDate']?.toDate().toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Time: ${appointmentData['appointmentTime'] ?? 'N/A'}', // Show time
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () =>
                              _makePhoneCall(appointmentData['doctorPhone']),
                          child: const Text(
                            'Call Doctor',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _editAppointment(
                                  appointment.id, appointmentData),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _showDeleteConfirmationDialog(appointment.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

