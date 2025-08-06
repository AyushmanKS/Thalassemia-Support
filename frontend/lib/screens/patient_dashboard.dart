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
                    child: ListView.builder(
                      itemCount: _matchedDonors.length,
                      itemBuilder: (context, index) {
                        final donor = _matchedDonors[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person), backgroundColor: Colors.redAccent),
                            title: Text(donor['username']),
                            subtitle: Text('Blood Type: ${donor['blood_type']}'),
                            trailing: Text('Score: ${donor['score'].toStringAsFixed(2)}'),
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