import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TherapistAppointmentView extends StatefulWidget {
  const TherapistAppointmentView({super.key});
  @override
  _TherapistAppointmentViewState createState() =>
      _TherapistAppointmentViewState();
}

class _TherapistAppointmentViewState extends State<TherapistAppointmentView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final String therapistUid = currentUser!.uid;
      var querySnapshot = await _firestore
          .collection('therapist_appointments')
          .where('_id', isEqualTo: therapistUid)
          .get();
          
      if (querySnapshot.docs.isNotEmpty) {
        var docSnapshot = querySnapshot.docs.first;
        var data = docSnapshot.data();
        var fetchedAppointments = data['appointments'] ?? [];

        List<Appointment> parsedAppointments = fetchedAppointments
            .where((appointment) => appointment['status'] == 'accepted')
            .map<Appointment>((appointment) {
          String startTime = appointment['time'].split(' - ')[0];
          String endTime = appointment['time'].split(' - ')[1];
          String date = appointment['date'];
          return Appointment(
            startTime: DateTime.parse("$date $startTime"),
            endTime: DateTime.parse("$date $endTime"),
            subject: "Parent: ${appointment['parent_id']}",
            color: Colors.blue,
          );
        }).toList();

        setState(() {
          appointments = parsedAppointments;
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Therapist Schedule')),
      body: SfCalendar(
        view: CalendarView.week,
        dataSource: AppointmentDataSource(appointments),
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 9,
          endHour: 18,
          nonWorkingDays: const <int>[DateTime.sunday],
        ),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
