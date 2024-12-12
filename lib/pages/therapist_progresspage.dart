import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dropdown_search/dropdown_search.dart';

class TherapistProgressPage extends StatefulWidget {
  @override
  _TherapistProgressPageState createState() => _TherapistProgressPageState();
}

class _TherapistProgressPageState extends State<TherapistProgressPage> {
  // Example JSON Data
  final List<Map<String, dynamic>> data = [
    {
      "child": "Alice",
      "activity": "Drawing",
      "progress": [20, 40, 60, 80, 100]
    },
    {
      "child": "Bob",
      "activity": "Reading",
      "progress": [10, 30, 50, 70, 90]
    },
    {
      "child": "Alice",
      "activity": "Reading",
      "progress": [15, 35, 55, 75, 95]
    },
    {
      "child": "Charlie",
      "activity": "Math",
      "progress": [25, 45, 65, 85, 105]
    },
    {
      "child": "Daniel",
      "activity": "Music",
      "progress": [30, 50, 70, 90, 110]
    },
  ];

  String? selectedChild;
  String? selectedActivity;
  List<_ChartData> chartData = [];

  @override
  Widget build(BuildContext context) {
    // Get unique children and activities for dropdown
    List<String> children =
        data.map((item) => item['child'] as String).toSet().toList();
    List<String> activities =
        data.map((item) => item['activity'] as String).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Searchable Dropdown for selecting child
                Expanded(
                  flex: 1,
                  child: DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Search Child',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    items: children,
                    selectedItem: selectedChild,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Child',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        selectedChild = value;
                        updateChartData();
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                // Dropdown for selecting activity
                Expanded(
                  flex: 1,
                  child: DropdownButton<String>(
                    value: selectedActivity,
                    hint: Text("Select Activity"),
                    items: activities.map((String activity) {
                      return DropdownMenuItem<String>(
                        value: activity,
                        child: Text(activity),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedActivity = value;
                        updateChartData();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Chart Display
            Expanded(
              child: chartData.isNotEmpty
                  ? SfCartesianChart(
                      primaryXAxis: NumericAxis(
                        title: AxisTitle(text: 'Progress Steps'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Progress Value'),
                      ),
                      series: <LineSeries<_ChartData, int>>[
                        LineSeries<_ChartData, int>(
                          dataSource: chartData,
                          xValueMapper: (_ChartData data, _) => data.x,
                          yValueMapper: (_ChartData data, _) => data.y,
                          color: Colors.blue,
                          width: 2,
                          markerSettings: MarkerSettings(isVisible: true),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        "No Data Available",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Update chart data based on selected child and activity
  void updateChartData() {
    if (selectedChild != null && selectedActivity != null) {
      var filteredData = data.firstWhere(
        (item) =>
            item['child'] == selectedChild &&
            item['activity'] == selectedActivity,
        orElse: () => {},
      );
      setState(() {
        chartData = filteredData.isNotEmpty
            ? (filteredData['progress'] as List)
                .asMap()
                .entries
                .map((e) => _ChartData(e.key, e.value))
                .toList()
            : [];
      });
    } else {
      setState(() {
        chartData = [];
      });
    }
  }
}

// Chart data model
class _ChartData {
  final int x;
  final int y;
  _ChartData(this.x, this.y);
}
