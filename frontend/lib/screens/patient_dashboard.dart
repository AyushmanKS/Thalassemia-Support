import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
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
  late DateTime _nextDueDate;
  int _daysUntilDue = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDueDate(widget.user['next_transfusion_due_date']);
    // Timer to update the countdown every hour
    _timer = Timer.periodic(Duration(hours: 1), (Timer t) => _calculateDaysUntilDue());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important to cancel timer to avoid memory leaks
    super.dispose();
  }

  void _updateDueDate(String dateString) {
    setState(() {
      _nextDueDate = DateTime.parse(dateString);
      _calculateDaysUntilDue();
    });
  }

  void _calculateDaysUntilDue() {
    final now = DateTime.now();
    final difference = _nextDueDate.difference(now).inDays;
    setState(() {
      _daysUntilDue = difference > 0 ? difference : 0;
    });
  }

  Future<void> _findDonors() async {
    // This is the same as before
    setState(() { _isLoading = true; _matchedDonors = []; });
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/request_blood'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'patient_id': widget.user['id'], 'blood_type': widget.user['blood_type']}),
      );
      if (response.statusCode == 200) setState(() => _matchedDonors = json.decode(response.body));
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmTransfusion() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/confirm_transfusion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'patient_id': widget.user['id']}),
      );
      if (response.statusCode == 200) {
        final updatedUser = json.decode(response.body);
        _updateDueDate(updatedUser['next_transfusion_due_date']);
        setState(() => _matchedDonors = []); // Clear the donor list
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer Reset! Stay Healthy.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red[100]!, Colors.red[300]!], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Column(
            children: [
              // --- TIMER WIDGET ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GlassContainer.clearGlass(
                  height: 100,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next Transfusion Due In', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      SizedBox(height: 5),
                      Text('$_daysUntilDue Days', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // --- FIND DONORS BUTTON ---
              Center(child: ElevatedButton.icon(onPressed: _isLoading ? null : _findDonors, icon: Icon(Icons.search), label: Text('Find Trusted Donors'), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
              SizedBox(height: 20),
              // --- DONOR LIST ---
              _isLoading
                  ? Center(child: SpinKitFadingCircle(color: Colors.white, size: 50.0))
                  : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _matchedDonors.length,
                        itemBuilder: (context, index) {
                          final donor = _matchedDonors[index];
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 25, backgroundColor: Colors.redAccent, child: Text(donor['blood_type'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                      SizedBox(width: 12),
                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(donor['username'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text('${donor['distance_km']} km away', style: TextStyle(color: Colors.grey[600])),
                                      ]),
                                      Spacer(),
                                      Column(children: [
                                        Row(children: [Icon(Icons.shield, color: Colors.blueAccent, size: 16), SizedBox(width: 4), Text('Trust Score', style: TextStyle(color: Colors.blueAccent, fontSize: 12))]),
                                        Text(donor['trust_score'].toStringAsFixed(1), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                      ]),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // --- CONFIRM BUTTON ---
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.check_circle, size: 18),
                                    label: Text('Confirm Transfusion & Reset Timer'),
                                    onPressed: _confirmTransfusion,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 40)),
                                  )
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