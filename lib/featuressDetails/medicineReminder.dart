import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main.dart';
import 'addPills.dart';
import 'package:timezone/timezone.dart' as tz;

class MedicineReminder extends StatefulWidget {
  const MedicineReminder({super.key});

  @override
  State<MedicineReminder> createState() => _MedicineReminderState();
}

class _MedicineReminderState extends State<MedicineReminder> {
  @override
  void initState() {
    super.initState();
    fetchAllStoredTimes();
    //Noti().initNotifications();

    timer = Timer.periodic(Duration(days: 1), (Timer t) {
      setState(() {});
    });
  }

  bool morningAlarm = false;
  bool noonAlarm = false;
  bool nightAlarm = false;
  bool additionalAlarm = false; // Additional alarm
  String? morningTime;
  String? noonTime;
  String? nightTime;
  String? additionalTime; // Time for the new alarm

  final currentUser = FirebaseAuth.instance.currentUser;
  Timer? timer;

  Future<void> fetchAllStoredTimes() async {
    if (currentUser == null) return;

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.email)
          .collection('alarmTimes')
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        for (var doc in docSnapshot.docs) {
          final data = doc.data();
          final timeOfDay = doc.id;
          if (timeOfDay == 'Morning') {
            morningTime = data['time'];
            morningAlarm = data['alarmState'] ?? false;
          } else if (timeOfDay == 'Noon') {
            noonTime = data['time'];
            noonAlarm = data['alarmState'] ?? false;
          } else if (timeOfDay == 'Night') {
            nightTime = data['time'];
            nightAlarm = data['alarmState'] ?? false;
          } else if (timeOfDay == 'Additional') { // Handle additional alarm
            additionalTime = data['time'];
            additionalAlarm = data['alarmState'] ?? false;
          }
        }
      }
    } catch (e) {
      print('Error fetching times: $e');
    }

    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> selectTime(String timeOfDay) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        if (timeOfDay == 'Morning') {
          morningTime = formattedTime;
          morningAlarm = true;
        } else if (timeOfDay == 'Noon') {
          noonTime = formattedTime;
          noonAlarm = true;
        } else if (timeOfDay == 'Night') {
          nightTime = formattedTime;
          nightAlarm = true;
        } else if (timeOfDay == 'Additional') {
          additionalTime = formattedTime;
          additionalAlarm = true;
        }
      });

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.email)
            .collection('alarmTimes')
            .doc(timeOfDay)
            .set({
          'time': formattedTime,
          'alarmState': true,
        });

        // Schedule the notification
        final now = DateTime.now();
        final notificationTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        print('Scheduling notification for $notificationTime');

        await flutterLocalNotificationsPlugin.zonedSchedule(
          timeOfDay.hashCode,
          'Medicine Reminder',
          'Time to take your medicine',
          tz.TZDateTime.from(notificationTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id',
              'your_channel_name',
              sound: RawResourceAndroidNotificationSound('ring'),
            ),
          ),
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exact, // Use exact scheduling mode
        );

        print('Notification scheduled');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving alarm time: $e')));
        print('Error scheduling notification: $e');
      }
    }
  }
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
  TextStyle headerStyle() => TextStyle(
      fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.blue[700]);
  TextStyle subtitleStyle() => TextStyle(fontSize: 18.sp, color: Colors.blue);
  TextStyle timeStyle() => TextStyle(fontSize: 16.sp, color: Colors.green);

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('No user is currently logged in.')),
      );
    }

    final userPillsCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.email)
        .collection('pills');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        title: Text("Schedule",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26.sp,
                color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set Notification for Medicine Times', style: headerStyle()),
            SizedBox(height: 16),
            alarmRow('Morning', morningAlarm, morningTime, (value) async {
              if (value) {
                await selectTime('Morning');
              } else {
                setState(() {
                  morningAlarm = false;
                  morningTime = null;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.email)
                    .collection('alarmTimes')
                    .doc('Morning')
                    .update({'alarmState': false, 'time': null});
              }
            }),
            alarmRow('Noon', noonAlarm, noonTime, (value) async {
              if (value) {
                await selectTime('Noon');
              } else {
                setState(() {
                  noonAlarm = false;
                  noonTime = null;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.email)
                    .collection('alarmTimes')
                    .doc('Noon')
                    .update({'alarmState': false, 'time': null});
              }
            }),
            alarmRow('Night', nightAlarm, nightTime, (value) async {
              if (value) {
                await selectTime('Night');
              } else {
                setState(() {
                  nightAlarm = false;
                  nightTime = null;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.email)
                    .collection('alarmTimes')
                    .doc('Night')
                    .update({'alarmState': false, 'time': null});
              }
            }),
            alarmRow('Others', additionalAlarm, additionalTime, (value) async {
              if (value) {
                await selectTime('Additional'); // Handle new alarm
              } else {
                setState(() {
                  additionalAlarm = false;
                  additionalTime = null;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.email)
                    .collection('alarmTimes')
                    .doc('Additional')
                    .update({'alarmState': false, 'time': null});
              }
            }),

            Divider(color: Colors.blue[700], thickness: 1, height: 20),
            Expanded(
              child: StreamBuilder(
                stream: userPillsCollectionRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(
                        child: Text(
                            'No pills scheduled. Add pills to get started.'));

                  final pillDocs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: pillDocs.length,
                    itemBuilder: (context, index) {
                      final pillData =
                      pillDocs[index].data() as Map<String, dynamic>;
                      final pillDocId = pillDocs[index].id;
                      final int duration = pillData['duration'] ?? 10;
                      final int remainingDays =
                          pillData['remainingDays'] ?? duration;
                      final String mealTiming = pillData['mealTiming'] ?? 'Not Set';

                      return Card(
                        color: Colors.white,
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(pillData['name'] ?? 'Unknown Pill',
                            style: subtitleStyle(),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Duration : $duration days',
                                  style: TextStyle(fontSize: 16.sp,color: Colors.red)),
                              Text('Meal Timing: $mealTiming', style: TextStyle(fontSize: 15.sp, color: Colors.red)),
                              timeRow(pillData['times'], 'Morning'),
                              timeRow(pillData['times'], 'Noon'),
                              timeRow(pillData['times'], 'Night'),
                              timeRow(pillData['times'], 'Additional'), // New alarm time
                            ],
                          ),
                          trailing:
                          pillActions(pillDocId, userPillsCollectionRef),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue[700],
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddPills(pillData: {}, docId: ''))),
      ),
    );
  }

  Widget alarmRow(String label, bool alarmState, String? time,
      Function(bool) onSwitchChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: subtitleStyle()),
        Row(
          children: [
            Switch(value: alarmState, onChanged: onSwitchChanged),
            time != null
                ? GestureDetector(
              onTap: () => onSwitchChanged(true),
              child: Text('Time: $time', style: timeStyle()),
            )
                : Text('Time: Not Set', style: timeStyle()),
          ],
        ),
      ],
    );
  }

  Widget timeRow(Map? times, String timeOfDay) {
    final time = times?[timeOfDay];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(timeOfDay, style: subtitleStyle()),
        time != null
            ? Text('Time: $time', style: timeStyle())
            : Text('No time set', style: timeStyle()),
      ],
    );
  }

  Widget pillActions(
      String pillDocId, CollectionReference userPillsCollectionRef) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            bool? confirmDelete = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Deletion"),
                  content: Text("Are you sure you want to delete this pill?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("No")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Yes")),
                  ],
                );
              },
            );
            if (confirmDelete == true) {
              await userPillsCollectionRef.doc(pillDocId).delete();
            }
          },
        ),
      ],
    );
  }
}