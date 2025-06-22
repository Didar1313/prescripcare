import 'package:prescripcare/featuressDetails/appointmentReminder.dart';
import 'package:prescripcare/featuressDetails/medicalHistory.dart';
import 'package:prescripcare/featuressDetails/medicineReminder.dart';
import 'package:prescripcare/findDoctor/doctorSearchScreen.dart';
import 'package:prescripcare/findHospital/hospitalSearchScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../featuressDetails/emergency_services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Health Routine',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        //centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20.w,
            mainAxisSpacing: 20.h,
            children: [
              buildCard(
                icon: FontAwesomeIcons.pills,
                text: "Medicine Reminder",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MedicineReminder()),
                  );
                },
              ),
              buildCard(
                icon: Icons.calendar_today,
                text: "Appointment Reminder",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AppointmentReminder()),
                  );
                },
              ),
              buildCard(
                icon: FontAwesomeIcons.userMd,
                text: "Find Doctor",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoctorSearchScreen()),
                  );
                },
              ),
              buildCard(
                icon: FontAwesomeIcons.fileMedical,
                text: "Medical History",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MedicalHistory()),
                  );
                },
              ),
              buildCard(
                icon: FontAwesomeIcons.hospital,
                text: "Find Hospital",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HospitalSearchScreen()),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 50,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
