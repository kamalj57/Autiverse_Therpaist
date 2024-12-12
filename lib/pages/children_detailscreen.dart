import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChildrensDetailScreen extends StatefulWidget {
  const ChildrensDetailScreen({
    super.key,
    required this.childDetails,
    required this.recentActivities,
  });

  final Map<String, dynamic>? childDetails;
  final List<Map<String, dynamic>>? recentActivities;

  @override
  State<ChildrensDetailScreen> createState() => _ChildrensDetailScreenState();
}

class _ChildrensDetailScreenState extends State<ChildrensDetailScreen> {
  double screenWidth = 0;
  double screenHeight = 0;

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  String calculateDuration(String startTime, String endTime) {
    DateFormat timeFormat = DateFormat("h:mm a");
    try {
      DateTime startDateTime = timeFormat.parse(startTime);
      DateTime endDateTime = timeFormat.parse(endTime);
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(Duration(days: 1));
      }
      Duration difference = endDateTime.difference(startDateTime);
      int hours = difference.inHours;
      int minutes = difference.inMinutes % 60;

      return "${hours}h ${minutes}m";
    } catch (e) {
      return "Invalid time format";
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    final child = widget.childDetails ?? {};
    final activities = widget.recentActivities ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Children Detail",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth / 20,
              vertical: 20,
            ),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      // Child's Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile image and name in the same column
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      (child['profileImage'] != null &&
                                              child['profileImage'] != '')
                                          ? NetworkImage(child['profileImage']!)
                                          : null,
                                  child: (child['profileImage'] == null)
                                      ? const Icon(
                                          Icons.perm_identity,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  child['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    fontSize: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Age and gender in the row
                            Row(
                              children: [
                                Text(
                                  'Age: ${child['age'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Gender: ${child['gender'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    final mobile = child['mobile_number'] ?? '';
                                    if (mobile.isNotEmpty) {
                                      _launchDialer(mobile);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        child['mobile_number'] ??
                                            'No phone number',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.blue,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth / 20,
              vertical: 5,
            ),
            child: const Text(
              "Recent Activities",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: screenWidth / 20),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];

                return Card(
                  color: Colors.white, // Set background color to white
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Rounded corners for a modern look
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Activity: ${activity['activity_name'] ?? ''}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time_filled_outlined,
                                    color: Colors.green,
                                    size: 20), // Recent indicator
                                const SizedBox(width: 4),
                                const Text(
                                  "Recent",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Date: ${activity['date'] ?? ''}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.access_time,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Time: ${activity['start_time']} - ${activity['end_time']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.score,
                                color: Colors.purple, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Score: ${activity['status']['score']}/ ${activity['status']['score']}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.percent,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 3),
                            Text(
                              "Percentage: ${activity['status']['percentage']}%",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
