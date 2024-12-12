import 'package:app/pages/children_detailscreen.dart';
import 'package:app/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TherapistHomePage extends StatefulWidget {
  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getChildrenDetails();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userDetail = userProvider.userData;
    final childrenDetails = userProvider.childrenDetails;

    // Filtering children based on search query
    final filteredChildren = childrenDetails.where((child) {
      return child['childDetails']?['name'] != null &&
          child['childDetails']!['name']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Children',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: childrenDetails.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : filteredChildren.isEmpty
                      ? Center(
                          child: Text(
                            'No children found',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredChildren.length,
                          itemBuilder: (context, index) {
                            final child = filteredChildren[index];
                            final childDetails = child['childDetails'];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildrensDetailScreen(
                                      childDetails: childDetails ?? {},
                                      recentActivities:
                                          List<Map<String, dynamic>>.from(
                                              child['recentActivities'] ?? []),
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: (childDetails !=
                                                    null &&
                                                childDetails['profileImage'] !=
                                                    null &&
                                                childDetails['profileImage'] !=
                                                    '')
                                            ? NetworkImage(
                                                childDetails['profileImage']!)
                                            : null,
                                        child: (childDetails == null ||
                                                childDetails['profileImage'] ==
                                                    null)
                                            ? Icon(Icons.perm_identity,
                                                color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              childDetails?['name'] ??
                                                  'Unknown',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    'Age: ${childDetails?['age'] ?? 'N/A'}'),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                    'Gender: ${childDetails?['gender'] ?? 'N/A'}'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
