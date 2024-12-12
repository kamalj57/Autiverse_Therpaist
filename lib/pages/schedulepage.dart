import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/provider.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final Map<String, List<String>> _schedule = {
    'Sunday': [],
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
  };

  String? _selectedDay = 'Monday'; 
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  // Pick time helper
  void _pickTime(String timeType) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeType == 'start'
            ? _startTimeController.text = pickedTime.format(context)
            : _endTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _addTiming() {
    String startTime = _startTimeController.text;
    String endTime = _endTimeController.text;

    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      String timing = "$startTime - $endTime";

      setState(() {
        _schedule[_selectedDay]!.add(timing);
        _schedule[_selectedDay]!.sort(); // Order the timings
      });

      _startTimeController.clear();
      _endTimeController.clear();
    }
  }

  void _removeTiming(String timing) {
    setState(() {
      _schedule[_selectedDay]!.remove(timing);
    });
  }

  void _applyToOtherDays(List<String> selectedDays) {
    List<String> timingsToApply = _schedule[_selectedDay] ?? [];

    setState(() {
      for (String day in selectedDays) {
        _schedule[day]!.addAll(timingsToApply);
        _schedule[day] = _schedule[day]!.toSet().toList(); // Remove duplicates
        _schedule[day]!.sort();
      }
    });
  }

 void _showApplyDialog() {
  List<String> selectedDays = [];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Apply Schedule to Other Days",
              style: TextStyle(color: Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _schedule.keys
                  .where((day) => day != _selectedDay)
                  .map((day) {
                return CheckboxListTile(
                  title: Text(day, style: TextStyle(color: Colors.black)),
                  value: selectedDays.contains(day),
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyToOtherDays(selectedDays); // Apply schedule
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Apply"),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Weekly Schedule'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _showApplyDialog,
                  child: Text('Apply to Other Days'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final sucess = await authProvider.storeSchedule(_schedule);
                    if (sucess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Schedule Addedd Sucessfully"),
                        ),
                      );
                       Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Schedule added failed sucessfully"),
                        ),
                      );
                    }
                  },
                  child: Text('Apply Schedule'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedDay,
              isExpanded: true,
              items: _schedule.keys
                  .map(
                    (day) => DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    ),
                  )
                  .toList(),
              onChanged: (newDay) {
                setState(() {
                  _selectedDay = newDay!;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (_schedule[_selectedDay] != null)
                  ..._schedule[_selectedDay]!
                      .map(
                        (timing) => ListTile(
                          title: Text(timing),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTiming(timing),
                          ),
                        ),
                      )
                      .toList(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onTap: () => _pickTime('start'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onTap: () => _pickTime('end'),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTiming,
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
