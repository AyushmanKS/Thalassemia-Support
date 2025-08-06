import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class PatientDashboard extends StatefulWidget {
  final Map<String, dynamic> user;
  PatientDashboard({required this.user});

  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  List<dynamic> _matchedDonors = [];
  bool _isLoading = false;

  void _findDonors() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/request_blood'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'patient_id': widget.user['id'],
        'blood_type': widget.user['blood_type'],
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _matchedDonors = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[400]!, Colors.red[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _findDonors,
              child: Text('Find Blood Donors'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? SpinKitFadingCircle(color: Colors.red)
                : Expanded(
                    child: // In frontend/lib/screens/patient_dashboard.dart

// ... inside the build method, after the SizedBox ...

_isLoading
    ? SpinKitFadingCircle(color: Colors.red)
    : Expanded(
        child: ListView.builder(
          itemCount: _matchedDonors.length,
          itemBuilder: (context, index) {
            final donor = _matchedDonors[index];
            // NEW: Safely get the distance, provide a default if it doesn't exist
            final distance = donor['distance_km']?.toString() ?? 'N/A';

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.bloodtype, color: Colors.white),
                  backgroundColor: Colors.redAccent,
                ),
                title: Text(
                  donor['username'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // THIS IS THE NEW SUBTITLE
                subtitle: Text(
                  'Distance: $distance km away',
                  style: TextStyle(color: Colors.black54),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Match Score',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      donor['score'].toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
                  ),
          ],
        ),
      ),
    );
  }
}