import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glass_kit/glass_kit.dart';

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
      _matchedDonors = []; // Clear previous results
    });

    try {
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
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding donors: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[100]!, Colors.red[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${widget.user['username']}',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Need a blood donation? Tap below.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _findDonors,
                  icon: Icon(Icons.search, size: 28),
                  label: Text('Find Blood Donors'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: SpinKitFadingCircle(color: Colors.white, size: 50.0))
                  : _matchedDonors.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              'No donors found yet. Tap button to search.',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _matchedDonors.length,
                            itemBuilder: (context, index) {
                              final donor = _matchedDonors[index];
                              final distance = donor['distance_km']?.toString() ?? 'N/A';
                              return GlassContainer.clearGlass(
                                height: 120,
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                borderRadius: BorderRadius.circular(20),
                                borderColor: Colors.white.withOpacity(0.3),
                                blur: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        child: Text(
                                          donor['blood_type'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              donor['username'],
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on, color: Colors.white70, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  '$distance km away',
                                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Match Score', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                          Text(
                                            donor['score'].toStringAsFixed(1),
                                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
        ),
      ),
    );
  }
}