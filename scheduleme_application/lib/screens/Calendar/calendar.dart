import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final CollectionReference _profileCollection =
      FirebaseFirestore.instance.collection("Profile");

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final String day = DateTime.now().day.toString();
  final int numDay = DateTime.now().weekday;
  final int numMonth = DateTime.now().month;
  final int years = DateTime.now().year;

  void _loadPreviousEvents() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Profile')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (doc.exists) {
        final eventsMap = Map<String, dynamic>.from(doc.data()!['events'] as Map);
        setState(() {
          mySelectedEvents = eventsMap.cast<String, List<dynamic>>();
        });
      }
    } catch (e) {
      print('Error loading previous events: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    _loadPreviousEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(_showWeekDay(numDay)),
                        subtitle: Text(_showMonth(numMonth) + " " + years.toString()),
                      ),
                    )
                  ],
                ),
              ),
              TableCalendar(
                firstDay: DateTime(2022),
                lastDay: DateTime(2025),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDate, selectedDay)) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _listOfDayEvents,
              ),
              ..._listOfDayEvents(_selectedDate!).map(
                (myEvents) => Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, bottom: 5, top: 20),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffC5BDBD),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.adjust,
                        color: Colors.teal,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          "Event: " + myEvents['eventTitle'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        "Description: " + myEvents['description'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: Icon(Icons.add),
        backgroundColor: Color(0xff392AAB),
      ),
    );
  }

  _showAddEventDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Add Todo",
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Event Title",
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: "Description",
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final eventTitle = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (eventTitle.isEmpty || description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Required Event and Description."),
                  duration: Duration(seconds: 2),
                ));
                return;
              }

              final String formattedDate =
                  DateFormat('yyyy-MM-dd').format(_selectedDate!);
              if (mySelectedEvents[formattedDate] != null) {
                mySelectedEvents[formattedDate]!.add({
                  "eventTitle": eventTitle,
                  "description": description,
                });
              } else {
                mySelectedEvents[formattedDate] = [
                  {
                    "eventTitle": eventTitle,
                    "description": description,
                  }
                ];
              }

              try {
                await _profileCollection.doc(auth.currentUser!.uid).update({
                  "events":
                      mySelectedEvents.map((key, value) => MapEntry(key, value.toList())),
                });
                setState(() {});
              } catch (e) {
                print(e);
              }

              Navigator.of(context).pop();
            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  String _showWeekDay(int numDay) {
    Map<int, String> weekday = {
      1: "Monday",
      2: "Tuesday",
      3: "Wednesday",
      4: "Thursday",
      5: "Friday",
      6: "Saturday",
      7: "Sunday"
    };
    return weekday[numDay].toString();
  }

  String _showMonth(int numMonth) {
    Map<int, String> months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December"
    };
    return months[numMonth].toString();
  }
}
