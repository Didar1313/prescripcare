import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

String getCurrentTimeZone() {
  return DateTime.now().timeZoneName; // This gives the current time zone name.
}

class AddPills extends StatefulWidget {
  const AddPills({super.key, required Map<String, dynamic> pillData, required String docId});

  @override
  State<AddPills> createState() => _AddPillsState();
}

class _AddPillsState extends State<AddPills> {
  TextEditingController pillsController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  // Map to store whether a time is selected (true or false) for Morning, Noon, Night
  Map<String, bool> selectedTimes = {
    'Morning': false,
    'Noon': false,
    'Night': false,
    'Additional': false,
  };

  // Variable to store the meal timing preference
  String mealTiming = "Before Meal";

  // Function to save the pill data to Firestore
  Future<void> savePill() async {
    String pillName = pillsController.text;

    // Check if the pill name or duration is empty
    if (pillName.isEmpty || durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Try to parse the duration, show error if not a valid number
    int duration;
    try {
      duration = int.parse(durationController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duration must be a valid number')),
      );
      return;
    }

    // Ensure that at least one time is selected
    if (selectedTimes.values.every((time) => !time)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one time')),
      );
      return;
    }

    // Get the current user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return; // If no user is logged in, stop the function
    }

    // Get the current time zone
    String currentTimeZone = getCurrentTimeZone();

    // Create a map to store the pill data in Firestore
    Map<String, dynamic> pillData = {
      'name': pillName,
      'times': selectedTimes,  // Store the selected times (true/false)
      'duration': duration,
      'timeZone': currentTimeZone,  // Store the current time zone here
      'mealTiming': mealTiming,  // Store the meal timing preference
    };

    // Save the pill data to Firestore under the current user's document
    await FirebaseFirestore.instance
        .doc('users/${currentUser.email}')
        .collection('pills')
        .add(pillData);

    // Clear the input fields and reset the selected times
    pillsController.clear();
    durationController.clear();
    setState(() {
      selectedTimes.updateAll((key, value) => false); // Reset the times
    });

    // Show a confirmation message after saving
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pill added successfully with time zone and meal timing!')),
    );
  }

  // Function to toggle the time selection
  void toggleTime(String period) {
    setState(() {
      selectedTimes[period] = !selectedTimes[period]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        title: Text(
          "Add Pills",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26.sp,
              color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pill Name",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900]),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: pillsController,
                        decoration: InputDecoration(
                          hintText: "Enter Pill Name",
                          prefixIcon: Icon(FontAwesomeIcons.pills,
                              color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Pick Your Pills Schedule",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900]),
                      ),
                      // Checkboxes for Morning, Noon, Night
                      CheckboxListTile(
                        title: Text('Morning'),
                        value: selectedTimes['Morning'],
                        onChanged: (value) => toggleTime('Morning'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text('Noon'),
                        value: selectedTimes['Noon'],
                        onChanged: (value) => toggleTime('Noon'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text('Night'),
                        value: selectedTimes['Night'],
                        onChanged: (value) => toggleTime('Night'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text('Additional'),
                        value: selectedTimes['Additional'],
                        onChanged: (value) => toggleTime('Additional'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "When to Take (Before or After Meal)",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900]),
                      ),
                      // Dropdown to select Before or After Meal
                      DropdownButton<String>(
                        value: mealTiming,
                        onChanged: (String? newValue) {
                          setState(() {
                            mealTiming = newValue!;
                          });
                        },
                        items: <String>['Before Meal', 'After Meal']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Duration (Days)",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900]),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                        decoration: InputDecoration(
                          hintText: "Enter Duration in Days",
                          prefixIcon: Icon(FontAwesomeIcons.calendar,
                              color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Center(
                child: ElevatedButton(
                  onPressed: savePill,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: 14.h, horizontal: 40.w),
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Save Pill',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
